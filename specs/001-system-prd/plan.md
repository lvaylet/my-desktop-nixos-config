# Implementation Plan: Core System Product Requirements Document (PRD)

**Branch**: `001-system-prd` | **Date**: 2026-08-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from [`specs/001-system-prd/spec.md`](spec.md)

## Summary

This plan reverse-engineers and formalizes the architecture, module hierarchy, operational interfaces, and quality standards of the `my-nixos-configurations` repository. The technical approach uses Nix Flakes for top-level multi-machine composition, a strict modular taxonomy separating system services (`modules/nixos/`) and user environments (`modules/home-manager/`), centralized identity injection (`vars.nix`), declarative secret encryption via SOPS/Age, hermetic pre-commit checks via `git-hooks.nix`, and unified task automation via `just`.

## Technical Context

**Language/Version**: Nix Expression Language (2.18+ / 2.24+ Flakes), POSIX Shell/Bash, Just (1.x)

**Primary Dependencies**: `nixpkgs` (`nixos-unstable`), `home-manager`, `nvf` (Neovim configuration system), `git-hooks.nix` (Cachix pre-commit suite), `nh` (Nix helper CLI)

**Storage**: Immutable `/nix/store`, persistent application directories (`/var/lib/<service>`), user home (`/home/laurent`), UEFI ESP (`/boot`)

**Testing**: Hermetic evaluation tests via `nix flake check` (`git-hooks.nix`: `alejandra`, `deadnix`, `statix`, `ripsecrets`, `trufflehog`, `detect-private-keys`, `pre-commit-hook-ensure-sops`), dry-run activation tests via `nh os test`

**Target Platform**: x86_64-linux (UEFI boot targets: `desktop-pc`, `homelab`, `iso`)

**Project Type**: Declarative Infrastructure as Code (IaC) & Multi-Host System Configuration Repository

**Performance Goals**: Rescue ISO boots to interactive SSH shell in <2m; system rollback via bootloader in <60s; local flake check evaluation <30s

**Constraints**: Offline build capability with cached store paths; zero plaintext secrets in version control; immutable user accounts (`mutableUsers = false`); pinned release versions (`stateVersion = "26.05"`)

**Scale/Scope**: 3 distinct machine profiles (`desktop-pc`, `homelab`, `iso`), 21 NixOS system modules, 23 Home Manager user modules, unified task runner recipes

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle / Rule | Gate Status | Compliance Verification |
| :--- | :--- | :--- |
| **I. Declarative & Hermetic Configuration** | **PASS** | Entire infrastructure defined in Nix Flakes with pinned `flake.lock`. All auxiliary inputs (`home-manager`, `nvf`) follow `nixpkgs`. |
| **II. Modular Separation & DRY Parameterization** | **PASS** | Separation of `machines/`, `modules/nixos/`, `modules/home-manager/` strictly maintained. Identity centralized in `vars.nix` and passed via `specialArgs`. |
| **III. Shift-Left Quality & Linting** | **PASS** | `alejandra` formatting, `deadnix`, and `statix` checks integrated into `just` recipes and hermetic `nix flake check` sandbox. |
| **IV. Zero-Secrets Leakage & Security First** | **PASS** | Pre-commit scanners (`trufflehog`, `ripsecrets`, `detect-private-keys`, `pre-commit-hook-ensure-sops`) active. SOPS/Age defined for encrypted secrets. |
| **V. Rigorous Verification & Safe Deployment** | **PASS** | Verification workflow (`just check` -> `just test` -> `just switch`) and bootloader multi-generation rollback (<60s) fully operationalized. |

## Project Structure

### Documentation (this feature)

```text
specs/001-system-prd/
├── checklists/
│   └── requirements.md    # Specification quality checklist
├── contracts/
│   ├── cli-contract.md    # Operational task runner interface contract
│   └── module-contract.md # Nix module & argument passing contract
├── data-model.md          # Domain entities, attributes, and lifecycle state transitions
├── plan.md                # This implementation plan
├── quickstart.md          # Step-by-step runnable validation guide
├── research.md            # Architectural decisions and trade-off analysis
└── spec.md                # Product Requirements Document (PRD) specification
```

### Source Code (repository root)

```text
.
├── flake.lock             # Deterministically pinned input hashes
├── flake.nix              # Root flake entrypoint (outputs, checks, devShells)
├── justfile               # Standardized operational task runner recipes
├── vars.nix               # Centralized user identity and SSH keys
│
├── machines/              # Host composition entrypoints
│   ├── desktop-pc/        # Interactive graphical developer workstation
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── homelab/           # Headless 24/7 home infrastructure server
│   │   ├── configuration.nix
│   │   └── hardware-configuration-dummy.nix
│   └── iso/               # Minimal bootable rescue & installation media
│       └── configuration.nix
│
└── modules/               # Reusable configuration modules
    ├── nixos/             # System-level modules & service definitions
    │   ├── _packages.nix  # System-level default packages
    │   ├── base.nix       # Core boot, locale, user, and nix settings
    │   ├── desktop.nix    # Display manager & graphical desktop
    │   ├── neovim.nix     # Declarative editor config via nvf
    │   ├── network.nix    # Networking & firewall configuration
    │   ├── nvidia.nix     # GPU hardware acceleration
    │   ├── podman.nix     # Container orchestration engine
    │   ├── ssh.nix        # Hardened OpenSSH daemon
    │   ├── tailscale.nix  # Mesh overlay networking
    │   └── ... (adguardhome, jellyfin, filebrowser, home-automation, etc.)
    │
    └── home-manager/      # User-level environment & dotfile modules
        ├── _packages.nix  # User CLI and GUI tools
        ├── _zsh.nix       # Interactive Zsh shell configuration
        ├── base.nix       # User profile base & sd-switch service manager
        ├── dotfiles/      # Managed configuration files
        ├── git.nix        # Git configuration & helper workflows
        ├── ghostty.nix    # Terminal emulator settings
        ├── starship.nix   # Shell prompt configuration
        ├── vscode.nix     # Visual Studio Code extensions & settings
        └── ... (bat, direnv, eza, fd, fzf, jq, lazygit, ripgrep, yazi, etc.)
```

**Structure Decision**: Preserves the established NixOS Flake multi-host architecture with modular separation of system concerns (`modules/nixos/`) and user concerns (`modules/home-manager/`).

## Complexity Tracking

*No constitutional violations or unjustified architectural complexities detected.*
