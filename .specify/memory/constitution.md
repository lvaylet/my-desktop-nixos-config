<!--
Sync Impact Report:
- Version change: initial template -> 1.0.0
- List of modified principles:
  - [PRINCIPLE_1_NAME] -> I. Declarative & Hermetic Configuration (NON-NEGOTIABLE)
  - [PRINCIPLE_2_NAME] -> II. Modular Separation of Concerns & DRY Parameterization
  - [PRINCIPLE_3_NAME] -> III. Shift-Left Quality, Formatting & Static Analysis
  - [PRINCIPLE_4_NAME] -> IV. Zero-Secrets Leakage & Security First
  - [PRINCIPLE_5_NAME] -> V. Rigorous Verification & Safe Deployment Workflow
- Added sections:
  - Structural & Architectural Constraints
  - Quality Gates & Verification Workflow
- Removed sections: None
- Follow-up TODOs: None (all placeholder tokens populated)
-->

# my-nixos-configurations Constitution

## Core Principles

### I. Declarative & Hermetic Configuration (NON-NEGOTIABLE)
All system infrastructure, machine configurations, and user environments MUST be declared purely and reproducibly via Nix flakes, NixOS modules, and Home Manager. Imperative, ad-hoc state changes in `$HOME` or `/etc` are strictly prohibited unless managed by Nix or explicitly documented as transient runtime data. Flake inputs MUST be strictly managed and pinned via `flake.lock`, with auxiliary inputs (`home-manager`, `nvf`, `git-hooks`) configured to follow `nixpkgs` whenever supported.

*Rationale*: Guarantees total reproducibility across physical and virtual targets (`desktop-pc`, `homelab`, `iso`) and eliminates configuration drift across boots and reinstalls.

### II. Modular Separation of Concerns & DRY Parameterization
Configurations MUST maintain a strict separation between machine-specific host definitions (`machines/<host>/`), system-wide NixOS modules (`modules/nixos/`), and user-level Home Manager modules (`modules/home-manager/`). Host configurations MUST only assemble modules and define machine-unique hardware attributes; they MUST NOT contain inline service definitions or duplicate common logic. Shared user parameters (usernames, email addresses, SSH public keys) MUST be centralized in `vars.nix` and passed via `specialArgs` and `extraSpecialArgs`.

*Rationale*: Keeps machine entrypoints concise, maximizes modular reusability across hosts, and guarantees consistent updates to shared identity properties.

### III. Shift-Left Quality, Formatting & Static Analysis
All Nix expressions MUST format cleanly with `alejandra` (`nix fmt`) and pass static linting (`statix check`) and dead-code detection (`deadnix`) with zero errors or warnings. Pre-commit hooks (`git-hooks.nix`) MUST run hermetically in isolated Nix sandbox checks (`nix flake check`). File hygiene rules—including trailing whitespace elimination, mixed line ending prevention, case-conflict checks, and proper script permissions—are mandatory and non-negotiable.

*Rationale*: Enforces consistent code style across the repository, eliminates unreferenced bindings early, and prevents build errors before commits are made.

### IV. Zero-Secrets Leakage & Security First
Secrets, credentials, and private keys MUST NEVER be committed to version control in plaintext. All commits MUST pass automated secret detection filters (`ripsecrets`, `trufflehog`, `detect-private-keys`, and `pre-commit-hook-ensure-sops`). Password hashes for declarative user accounts MUST be created with strong cryptographic algorithms (e.g. `mkpasswd -m sha-512`) or referenced via secure runtime secrets mechanisms (e.g., SOPS / `sops-nix`).

*Rationale*: Protects personal credentials, private keys, and infrastructure tokens against accidental leakage in local and public repositories.

### V. Rigorous Verification & Safe Deployment Workflow
Every configuration change MUST be verified prior to permanent activation. Changes MUST pass flake evaluation checks (`just check` / `nix flake check`) and safe non-switching activation testing (`just test` / `nh os test`) before switching the live profile (`just switch` / `nh os switch`). `justfile` serves as the single source of truth for all operational recipes. State versions (`system.stateVersion` and `home.stateVersion`) MUST remain pinned to their initial deployment release and MUST NOT be bumped without reviewing upstream release notes.

*Rationale*: Prevents unbootable systems, broken desktop sessions, and unintentional data migrations or regressions.

## Structural & Architectural Constraints

The repository adheres to a standardized hierarchy that MUST be respected:

1. **Root Flake (`flake.nix`)**:
   - Defines inputs, `nixosConfigurations`, multi-system `checks`, `formatter`, and `devShells`.
   - Uses `forAllSystems` helper for system-agnostic outputs.
2. **Machine Definitions (`machines/<host>/`)**:
   - Each host contains a `configuration.nix` and corresponding `hardware-configuration.nix`.
   - Imports required modules from `modules/nixos/` and delegates user configuration to Home Manager modules.
3. **NixOS Modules (`modules/nixos/`)**:
   - Encapsulates system services (e.g., `desktop.nix`, `nvidia.nix`, `sound.nix`, `ssh.nix`, `base.nix`).
   - Packages shared at the system level reside in `_packages.nix`.
4. **Home Manager Modules (`modules/home-manager/`)**:
   - Encapsulates user packages, shells, and desktop tool configurations (e.g., `git.nix`, `ghostty.nix`, `vscode.nix`, `_zsh.nix`).
   - Static dotfiles reside in `modules/home-manager/dotfiles/`.
5. **Variables (`vars.nix`)**:
   - Stores global identity and SSH credentials consumed across system and user modules.

## Quality Gates & Verification Workflow

All contributions and configuration changes MUST pass through the following quality gates:

1. **Formatting**: Run `just fmt` (or `nix fmt .`) to apply `alejandra` formatting to all `.nix` files.
2. **Linting & Diagnostics**: Run `just lint` (`deadnix` and `statix check`). Auto-fixable issues can be addressed with `just fix`.
3. **Flake Integrity & Checks**: Run `just check` (`nix flake check`) to validate syntax, evaluate derivations, and execute pre-commit sandbox checks.
4. **Activation Testing**: Run `just test configuration="<host>"` (`nh os test .#<host>`) to activate and test configuration changes safely without setting a new bootloader entry.
5. **Deployment & Switch**: Run `just switch configuration="<host>"` (`nh os switch .#<host>`) or `just boot` to finalize system generation updates.

## Governance

This constitution defines the supreme operational and code standards for `my-nixos-configurations`. All feature additions, module refactoring, and AI-assisted workflows (Spec Kit) MUST adhere to these non-negotiable principles.

- **Amendments**: Amending this constitution requires modifying `.specify/memory/constitution.md`, explaining the rationale in the Sync Impact Report, and updating the version and date headers.
- **Versioning Policy**:
  - **MAJOR (X.0.0)**: Incompatible architectural shifts, principle deletions, or restructuring of core workflows.
  - **MINOR (0.X.0)**: Addition of new principles, new machine architectures, or expanded governance rules.
  - **PATCH (0.0.X)**: Wording clarifications, typo fixes, or documentation refinements.
- **Compliance**: All generated specifications (`/speckit-*`), plans, and tasks MUST verify alignment with these core principles during review and convergence.

**Version**: 1.0.0 | **Ratified**: 2026-08-12 | **Last Amended**: 2026-08-12
