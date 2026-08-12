# Feature Specification: Portable Multi-Environment Development, Testing, and Deployment

**Feature Branch**: `002-portable-dev-deploy`

**Created**: 2026-08-12

**Status**: Draft

**Input**: User description: "This repository assumes that development, testing and deployment takes place on a NixOS machine, presumably the same machine the configuration is deployed to. Make it so development, testing and deployment can occur on any Linux machine, local, or remote, with or without NixOS. For machines running on another OS, make sure Devbox (that leverages the Nix package manager) is an option."

## Clarifications

### Session 2026-08-12

- Q: Should the deployment scope include managing standalone Home Manager configurations on non-NixOS Linux workstations, or is deployment strictly limited to full NixOS system configurations targeting dedicated NixOS machines? → A: NixOS systems only: Non-NixOS machines serve solely as development and deployment clients targeting NixOS hosts (standalone Home Manager on non-NixOS is out of scope).
- Q: Which deployment mechanism should be utilized for remote deployments to target NixOS machines from non-NixOS or remote Linux hosts? → A: Native `nixos-rebuild` with `--target-host` and remote build/sudo options wrapped in `justfile` recipes (no third-party deployment framework needed).
- Q: How should remote deployment operations be invoked within the `justfile` interface? → A: Unified recipes: Add an optional `target=""` parameter to `switch`, `test`, `boot`, and `build` (local behavior if empty, remote deployment over SSH if specified).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Developer Environment Portability & Onboarding Across Any OS (Priority: P1)

A developer working on any operating system (NixOS, non-NixOS Linux distributions such as Ubuntu, Debian, Fedora, Arch, or macOS/Windows via Devbox) can clone the repository and immediately enter a reproducible development environment with all required formatters, linters, pre-commit hooks, and task runners readily available without manual installation.

**Why this priority**: Foundational for all repository interactions. Contributors and operators on non-NixOS environments must be able to edit, format, and validate configurations with identical quality gates before any testing or deployment can occur.

**Independent Test**: On a clean non-NixOS Linux or non-Linux host, initialize the environment using either the native Nix developer environment or Devbox, and execute formatting and static analysis checks to confirm consistent behavior.

**Acceptance Scenarios**:

1. **Given** a non-NixOS Linux machine with Nix installed, **When** the developer enters the development environment, **Then** all repository management utilities, formatters, and linters are available in the shell path.
2. **Given** a workstation running an alternative operating system with Devbox installed, **When** the developer starts the Devbox shell, **Then** all repository tools, task runner recipes, and pre-commit hooks execute identically to native environments.
3. **Given** any supported development environment, **When** the developer runs code formatting or linting commands, **Then** all static analysis checks pass without requiring system-level configuration changes.

---

### User Story 2 - Remote Target Deployment from Any Linux Host (Priority: P2)

An operator working on a local or remote Linux machine (whether running NixOS or a non-NixOS Linux distribution) can build and deploy system configurations directly to remote target NixOS machines (such as `desktop-pc` and `homelab`) over SSH without needing to be logged into the physical target host.

**Why this priority**: Decouples the development workstation from the target hardware, enabling centralized administration, headless server updates, and CI/CD deployment pipelines.

**Independent Test**: Trigger a deployment from a non-NixOS Linux machine targeting a remote NixOS host, and verify that the target machine applies the new configuration generation and activates services over SSH.

**Acceptance Scenarios**:

1. **Given** an operator on a non-NixOS Linux host with network and SSH access to a target NixOS machine, **When** the operator initiates a deployment command specifying the target configuration and remote host (e.g., `just switch configuration="homelab" target="homelab"`), **Then** the configuration is evaluated, built, transferred, and activated on the remote target.
2. **Given** an operator deploying to a remote host, **When** the deployment fails due to unreachable hosts, authentication errors, or build issues, **Then** clear diagnostic errors are presented and the remote target's active system generation remains untouched.
3. **Given** an operator running locally on the target NixOS machine itself, **When** the operator initiates a local deployment command (omitting the target parameter), **Then** the local switch and boot workflows continue to work seamlessly without regression.

---

### User Story 3 - Remote and Local Testing & Verification Without Host OS Coupling (Priority: P3)

A developer or automated CI workflow running on any Linux machine can evaluate, test, and dry-run machine configurations (including building system closures and checking configuration validity) without requiring NixOS as the host operating system.

**Why this priority**: Enables continuous integration runners and non-NixOS workstations to catch configuration regressions, syntax errors, and broken module imports prior to pushing or deploying changes.

**Independent Test**: Execute validation and dry-run build commands on a standard Linux CI runner or non-NixOS machine, confirming that derivations evaluate and build without requiring local `/etc` modifications or root privileges.

**Acceptance Scenarios**:

1. **Given** a non-NixOS Linux environment or CI runner, **When** a developer executes configuration evaluation and flake integrity checks, **Then** all checks evaluate in an isolated sandbox without requiring root privileges or local NixOS system services.
2. **Given** a specific machine configuration, **When** a developer requests a test or dry-run evaluation, **Then** the configuration builds or generates evaluation results without altering the host machine's bootloader or system profile.

---

### Edge Cases

- **Unreachable Remote Host**: When a target machine is offline or unreachable over the network during remote deployment, the operation aborts early with a connection failure message without leaving partial state.
- **Authentication & Permission Failures**: If remote SSH keys lack administrative/activation privileges on the target host, deployment halts with a clear permission error.
- **Incompatible Host Architecture**: When building on a host whose CPU architecture differs from the target, the system supports remote building on the target host or cross-compilation without crashing.
- **Execution of Local NixOS Switch on Non-NixOS Linux**: If an operator accidentally attempts a local system switch on a non-NixOS machine, the command detects the unsupported environment and provides a helpful error pointing to remote deployment or build options.
- **Devbox on Non-Nix Environments**: When Devbox is executed on a machine without an existing Nix installation, Devbox's automated Nix package resolution initializes the required tooling cleanly.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a declarative Devbox configuration (`devbox.json`) providing environment parity for development tools across non-NixOS and non-Linux operating systems.
- **FR-002**: System MUST provide development shell definitions that automatically supply all required repository tooling (including task runner, code formatter, linters, and pre-commit hooks) on any Linux machine with Nix installed.
- **FR-003**: System MUST support remote deployment of NixOS configurations to remote target hosts over SSH from any Linux workstation.
- **FR-004**: System MUST allow specifying target host connection parameters (e.g., SSH hostname, user, port) with intuitive defaults matching existing machine hostnames.
- **FR-005**: System MUST maintain full backward compatibility for local build, test, switch, and boot workflows when running directly on the target NixOS machine.
- **FR-006**: System MUST enable non-destructive evaluation, syntax checking, and derivation builds on non-NixOS Linux hosts without requiring root privileges or modifying local host system state.
- **FR-007**: System MUST provide explicit, helpful error messaging when commands intended exclusively for local NixOS management are executed in non-NixOS environments.
- **FR-008**: System MUST support both local building with remote activation and remote building directly on the target host to handle resource-constrained or architecture-mismatched deployment hosts.
- **FR-009**: System deployment scope MUST be strictly limited to full NixOS system configurations (e.g., `desktop-pc`, `homelab`, `iso`); non-NixOS workstations function purely as development, testing, and deployment clients, with standalone Home Manager host deployment explicitly out of scope.
- **FR-010**: Remote deployment operations MUST utilize standard NixOS tooling (such as `nixos-rebuild` with `--target-host` and `--use-remote-sudo`) wrapped in `justfile` recipes, without introducing external third-party deployment framework dependencies.
- **FR-011**: Task runner recipes for system operations (`switch`, `test`, `boot`, `build`) MUST support an optional `target` parameter (defaulting to empty for local operations and triggering remote SSH deployment when a target hostname or IP address is provided).

### Key Entities

- **Development Environment Specification**: The declarative configuration defining tools, linters, formatters, and hooks required for repository development, exposed via both native Nix developer shells and Devbox.
- **Machine Target**: A declarative host configuration (e.g., `desktop-pc`, `homelab`, `iso`) defining system modules, hardware attributes, and optional remote deployment parameters.
- **Deployment Plan**: The sequence of evaluation, building, transferring, and activating a machine target's configuration either locally or across SSH to a remote destination host.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new contributor on any supported operating system (Linux, macOS, Windows) can enter the development environment and execute static checks in under 5 minutes from repository clone.
- **SC-002**: 100% of formatting, linting, secret detection, and flake evaluation checks execute successfully on non-NixOS Linux machines without requiring root or administrative privileges.
- **SC-003**: An operator can trigger a complete remote deployment to a designated NixOS host from a non-NixOS Linux machine in a single command.
- **SC-004**: 100% of failed remote connections or configuration evaluation errors fail safely, leaving the remote target host's active generation completely unaffected.
- **SC-005**: Existing local development and deployment operations on native NixOS installations continue to function with zero regression.

## Assumptions

- Target deployment hosts (`desktop-pc`, `homelab`) run NixOS with an SSH server enabled and accessible to authorized deployment keys with sudo/root privileges.
- Standalone Home Manager deployment to manage non-NixOS host user environments is explicitly out of scope.
- Non-NixOS Linux development workstations have a standard multi-user or single-user Nix installation with Flakes enabled.
- Workstations on alternative operating systems (macOS, Windows with WSL/terminal) utilize Devbox to manage Nix-backed developer tooling.
- Remote deployment uses SSH authentication (agent or key pair) without requiring interactive password prompts during automated phases.
- Non-NixOS host operating systems will not have their system-level directories (`/etc`, `/boot`) modified by any repository workflow commands.
