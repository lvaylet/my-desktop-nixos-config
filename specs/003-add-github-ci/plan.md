# Implementation Plan: Modern Continuous Integration Pipeline

**Branch**: `003-add-github-ci` | **Date**: 2026-08-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from [`specs/003-add-github-ci/spec.md`](spec.md)

## Summary

This plan introduces a modern, high-performance continuous integration pipeline for the repository using GitHub Actions. The implementation defines a declarative `.github/workflows/ci.yml` workflow implementing a two-stage gated architecture: an initial fast `check` stage executing hermetic flake evaluation, code formatting checks, static analysis (`statix`, `deadnix`), and secret scanning filters (`trufflehog`, `ripsecrets`, `detect-private-keys`), followed by a parallel `build` matrix stage validating system closures for all declared targets (`desktop-pc`, `homelab`, `iso`). Build acceleration and store path persistence are handled transparently via Determinate Systems Nix Installer and Magic Nix Cache without requiring external secrets or third-party service tokens.

## Technical Context

**Language/Version**: GitHub Actions Workflow Schema (YAML), Nix Expression Language (2.18+ / 2.24+ Flakes), Bash

**Primary Dependencies**: `DeterminateSystems/nix-installer-action@v16`, `DeterminateSystems/magic-nix-cache-action@v9`, `actions/checkout@v4`, `nixpkgs` (`nixos-unstable`), `git-hooks.nix`

**Storage**: Ephemeral GitHub Actions runner disk (`/nix/store`), GitHub Actions Cache API (via Magic Nix Cache daemon)

**Testing**: Fast hermetic static analysis (`nix flake check`); top-level derivation builds (`.#nixosConfigurations.<host>.config.system.build.toplevel`, `.#nixosConfigurations.iso.config.system.build.isoImage`)

**Target Platform**: GitHub-hosted Linux runners (`ubuntu-latest` / `x86_64-linux`)

**Project Type**: Declarative CI/CD Automation & Infrastructure Quality Assurance

**Performance Goals**: Fast-gate `check` job completion <2 minutes; warm-cache matrix build reduction ≥60%; immediate cancellation of obsolete in-flight PR runs

**Constraints**: Least-privilege permissions (`contents: read`); zero external tokens or secrets required for PR validation; 100% parity between local `just check` and CI cloud execution

**Scale/Scope**: 1 new workflow file (`.github/workflows/ci.yml`), 1 README badge addition / CI documentation update

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle / Rule | Gate Status | Compliance Verification |
| :--- | :--- | :--- |
| **I. Declarative & Hermetic Configuration** | **PASS** | CI workflow is declared purely via version-controlled YAML (`.github/workflows/ci.yml`). Tools and dependencies are pinned via `flake.lock` and standard action versions. No imperative state changes. |
| **II. Modular Separation & DRY Parameterization** | **PASS** | Builds leverage existing machine modular definitions (`desktop-pc`, `homelab`, `iso`) directly from `flake.nix` without duplicating system definitions. |
| **III. Shift-Left Quality & Linting** | **PASS** | The CI `check` job executes `nix flake check`, enforcing the identical pre-commit hooks, `alejandra`, `statix`, and `deadnix` linters as local developer environments. |
| **IV. Zero-Secrets Leakage & Security First** | **PASS** | CI runs with least-privilege `contents: read` permissions. Secret detection (`trufflehog`, `ripsecrets`, `detect-private-keys`) is strictly enforced on every PR commit. Zero secrets or third-party auth tokens are needed for caching. |
| **V. Rigorous Verification & Safe Deployment** | **PASS** | CI evaluates and builds derivations safely without altering live system profiles or executing live machine deployments. Gating ensures unverified commits cannot merge. |

## Project Structure

### Documentation (this feature)

```text
specs/003-add-github-ci/
├── checklists/
│   └── requirements.md            # Specification quality checklist
├── contracts/
│   └── ci-workflow-contract.md    # GitHub Actions workflow interface contract
├── data-model.md                  # Entity relationships, states, and execution flow
├── plan.md                        # This implementation plan
├── quickstart.md                  # Step-by-step runnable validation guide
├── research.md                    # Architectural decisions and trade-off analysis
└── spec.md                        # Feature specification
```

### Source Code (repository root)

```text
.
├── .github/
│   └── workflows/
│       └── ci.yml                 # Declarative two-stage GitHub Actions CI workflow
├── flake.lock                     # Flake dependency lockfile
├── flake.nix                      # Flake inputs, outputs, checks, and devShells
├── justfile                       # Local developer task runner
├── machines/                      # Target machine configurations (desktop-pc, homelab, iso)
├── modules/                       # NixOS and Home Manager modular configurations
└── README.md                      # Repository documentation with CI status badge
```

**Structure Decision**: Creates `.github/workflows/ci.yml` in the root repository to define the declarative GitHub Actions pipeline. Updates `README.md` to add CI status indicators.

## Complexity Tracking

*No constitutional violations or unjustified architectural complexities detected.*
