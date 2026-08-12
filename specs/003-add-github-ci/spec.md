# Feature Specification: Modern Continuous Integration Pipeline

**Feature Branch**: `003-add-github-ci`

**Created**: 2026-08-12

**Status**: Draft

**Input**: User description: "Add a proper and modern CI to this GitHub repository."

## Clarifications

### Session 2026-08-12

- Q: Which caching and Nix installation mechanism should the GitHub Actions CI pipeline use to accelerate builds and persist store paths across workflow runs? → A: Determinate Systems Nix Installer with Magic Nix Cache (zero-config, tokenless native GitHub Actions store caching).
- Q: How should the CI workflow pipeline structure the dependency between the quality checks and the machine configuration builds? → A: Two-stage gated pipeline (fast quality check job gates the downstream multi-configuration build matrix).
- Q: Should the CI scope include an automated scheduled workflow to create weekly pull requests for `flake.lock` updates, or remain strictly focused on validating existing branches and pull requests? → A: Validation-only scope (strictly validating pull requests, pushes to `main`, scheduled health checks, and manual dispatches with least-privilege read permissions).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automated Pull Request Quality & Security Gate (Priority: P1)

When a contributor or maintainer opens or updates a pull request against the repository, automated validation runs immediately in the cloud to verify code formatting, static analysis rules, flake syntax, and secret detection filters. Clear pass/fail status checks are posted directly to the pull request to prevent regressions and security issues from entering the main branch.

**Why this priority**: Core foundation of modern CI. Ensures that no invalid syntax, broken linters, formatting mismatches, or sensitive credentials can ever be merged into the main codebase without human maintainers needing to manually verify every commit locally.

**Independent Test**: Create a pull request containing changes (both conforming and intentionally violating style or static analysis rules) and observe that the CI runner automatically triggers, executes all quality checks, and blocks or approves the PR status accordingly.

**Acceptance Scenarios**:

1. **Given** a pull request with properly formatted Nix code and valid configurations, **When** the workflow executes, **Then** all static analysis, formatting, and flake evaluation checks succeed and report a green status.
2. **Given** a pull request containing formatting errors, dead code, or lint warnings, **When** the workflow executes, **Then** the check fails with actionable diagnostic logs pointing to the exact errors.
3. **Given** a pull request containing accidentally committed plaintext secrets or private keys, **When** the workflow executes, **Then** the security scanning stage fails immediately and blocks the pull request.
4. **Given** multiple rapid commits pushed to an active pull request, **When** a newer commit is pushed while a previous CI run is in progress, **Then** redundant in-flight runs are automatically cancelled to conserve runner resources and avoid stale results.

---

### User Story 2 - Automated Multi-Configuration Build Verification (Priority: P2)

When changes pass initial quality gates, the CI pipeline builds and validates the top-level derivations for all defined target configurations (such as desktop workstations, headless homelab servers, and installation media) in parallel matrix jobs to ensure that every system builds cleanly without broken dependencies or missing module inputs.

**Why this priority**: Prevents broken system configurations from being committed to main. Nix evaluation alone does not catch derivation build failures or missing runtime package dependencies.

**Independent Test**: Trigger a CI run on a branch with modifications to shared modules, and verify that the build jobs for all target machines execute independently in parallel only after the quality check stage succeeds.

**Acceptance Scenarios**:

1. **Given** a valid configuration change that passes the quality gate stage, **When** the downstream build stage executes, **Then** all defined machine configurations (`desktop-pc`, `homelab`, `iso`) build successfully to completion across parallel matrix runners.
2. **Given** a change that introduces a broken dependency or non-existent package in one specific target configuration, **When** the matrix build executes, **Then** that specific machine build fails with informative logs while other unaffected machine builds complete.
3. **Given** a change that fails static linting or formatting in the quality gate stage, **When** the workflow executes, **Then** the build matrix stage is skipped automatically to avoid wasting runner compute minutes.
4. **Given** a push or merge to the repository's default branch, **When** the workflow triggers, **Then** all configurations are verified and a successful build record is preserved.

---

### User Story 3 - High-Performance Build Acceleration & Remote Caching (Priority: P3)

Contributors and automated workflows experience fast CI execution times because identical Nix store paths, evaluation artifacts, and dependency derivations are automatically cached and reused between workflow runs using Magic Nix Cache.

**Why this priority**: Without caching, building multi-machine NixOS closures from scratch on cloud runners takes tens of minutes or hours, leading to slow feedback cycles and wasted compute quotas.

**Independent Test**: Run the CI pipeline twice consecutively on unchanged or incrementally modified branches and measure the execution time reduction on the second run.

**Acceptance Scenarios**:

1. **Given** a CI run where upstream dependencies have already been built in a previous run, **When** the job runs, **Then** cached store paths are retrieved automatically via Magic Nix Cache without re-downloading or re-compiling from source.
2. **Given** an incremental code change that touches only a single module, **When** the CI executes, **Then** only derivations affected by that change are re-evaluated and rebuilt.

---

### User Story 4 - Scheduled Pipeline Health & Upstream Compatibility Monitoring (Priority: P4)

The repository automatically checks on a scheduled basis (e.g., weekly) that all flake inputs and target machine configurations continue to evaluate and build cleanly against upstream changes, alerting maintainers proactively if bitrot or external breakages occur.

**Why this priority**: Upstream channels and flake dependencies evolve over time. Scheduled health runs ensure maintainers discover incompatibilities before attempting urgent deployments.

**Independent Test**: Trigger a scheduled run or manual workflow dispatch and confirm that full evaluation and build verification runs across all targets.

**Acceptance Scenarios**:

1. **Given** a scheduled execution trigger, **When** the workflow runs on the main branch, **Then** all evaluation checks and configuration builds are validated.
2. **Given** a scheduled run that encounters a failure due to upstream repository issues, **When** the failure occurs, **Then** repository maintainers are notified through standard platform notification channels.

---

### Edge Cases

- What happens when a pull request comes from a public repository fork (secrets access / cache permissions)? The workflow MUST run securely in untrusted pull request contexts without exposing write-access tokens or repository secrets; Magic Nix Cache operates natively in GitHub Actions cache storage without repository secrets.
- What happens when a runner runs out of disk space during multi-machine builds? The workflow MUST manage runner storage effectively (e.g. freeing unnecessary pre-installed tools or building targets concurrently across independent matrix jobs).
- What happens when a non-code change (e.g., markdown documentation only) is pushed? The workflow SHOULD skip heavy build jobs or run lightweight validation to save CI compute time.
- What happens when upstream network flake inputs are temporarily unreachable? The CI step should fail gracefully with clear network error messages rather than hanging indefinitely.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST automatically trigger CI validation workflows upon pull request creation, pull request updates, and direct pushes to the main branch.
- **FR-002**: The CI workflow MUST execute all static analysis checks (including syntax linting, dead code analysis, and style checks) defined in the repository's hermetic pre-commit checks.
- **FR-003**: The CI workflow MUST enforce strict zero-secret leakage policies by executing automated secret and credential scanning on all changed files.
- **FR-004**: The CI workflow MUST validate Nix flake syntax, inputs, and structure using standard flake integrity checks (`nix flake check`).
- **FR-005**: The CI workflow MUST verify that all system configurations (`desktop-pc`, `homelab`, and `iso`) evaluate and build successfully without errors.
- **FR-006**: The CI workflow MUST implement a two-stage gated pipeline where a fast quality check job gates the downstream concurrent matrix build jobs.
- **FR-007**: The system MUST implement automatic concurrency control to cancel in-progress runs when new commits are pushed to the same pull request.
- **FR-008**: The system MUST use Determinate Systems Nix Installer and Magic Nix Cache to automatically persist and restore Nix store paths across GitHub Actions workflow runs without requiring external secrets or third-party accounts.
- **FR-009**: The CI pipeline MUST support manual workflow dispatch triggers (`workflow_dispatch`) for on-demand verification and debugging.
- **FR-010**: The CI pipeline MUST support scheduled recurring runs to monitor repository health and detect configuration bitrot.
- **FR-011**: The CI workflow MUST report clear status check summaries and log outputs for each job directly within the pull request interface.
- **FR-012**: The CI configuration MUST operate with least-privilege permissions, allowing read-only access for untrusted pull request workflows.
- **FR-013**: Automated generation of `flake.lock` pull requests is explicitly OUT OF SCOPE; CI workflows are strictly dedicated to validation, verification, and health monitoring.

### Key Entities

- **CI Workflow**: The top-level automation pipeline containing trigger events, concurrency groups, permissions, and job graphs.
- **Quality Gate Job**: The initial verification stage responsible for formatting, linting, flake evaluation, and secret scanning.
- **Build Matrix Target**: A discrete machine configuration or derivation target (`desktop-pc`, `homelab`, `iso`) executed in parallel runner jobs gated by the quality gate stage.
- **Binary Cache**: The native Magic Nix Cache storage layer that persists Nix store paths between CI runs via GitHub Actions cache.
- **Pipeline Status Check**: The aggregate or per-job status reported to GitHub pull requests and commit statuses.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of pull requests and pushes to main automatically trigger CI verification without manual intervention.
- **SC-002**: Feedback for static analysis, linting, and formatting checks is delivered to pull requests within 3 minutes of push.
- **SC-003**: Incremental CI runs with warm cache achieve at least a 60% reduction in total build time compared to cold builds.
- **SC-004**: 100% of broken module syntax, failing linters, or leaked secret attempts in pull requests are flagged and blocked prior to merge.
- **SC-005**: Zero local tool installations required on CI runners beyond the declarative Nix installer and caching actions.

## Assumptions

- The repository is hosted on GitHub and uses GitHub Actions as its continuous integration platform.
- Public GitHub-hosted Linux runners (`ubuntu-latest` with x86_64 architecture) are available for executing workflow jobs.
- The standard machine targets (`desktop-pc`, `homelab`, `iso`) can be evaluated and built on x86_64 Linux runners.
- The existing pre-commit hooks and flake checks configured in `flake.nix` serve as the single source of truth for code quality and security standards.
- Secrets are not required to build open-source or public configurations; any private credentials use mock/dummy configurations or SOPS decryption at runtime rather than during CI evaluation.
- Automated dependency update pull requests (e.g. automated `flake.lock` updates) are excluded from this feature and can be introduced in a future maintenance enhancement.
