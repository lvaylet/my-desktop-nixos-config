# Technical Research & Architectural Decisions: Core System PRD

**Feature**: `001-system-prd`
**Status**: Completed

## Overview

This research document consolidates architectural decisions, technology selections, best practices, and evaluated alternatives for the `my-nixos-configurations` repository based on the ratified Constitution and Product Requirements Document (PRD).

---

## Technical Decisions

### 1. Modular Flake & Host Composition Pattern

- **Decision**: Adopt Nix Flakes as the top-level orchestration mechanism with a strict three-tier architecture:
  1. `machines/<host>/`: Host composition root importing hardware configuration, system modules, and user modules.
  2. `modules/nixos/`: Reusable, system-level service and subsystem configurations.
  3. `modules/home-manager/`: Reusable user environment, shell, and editor configurations.
  4. `vars.nix`: Centralized global identity and SSH credentials injected via `specialArgs` / `extraSpecialArgs`.
- **Rationale**: Directly aligns with Constitution Principle I (Declarative & Hermetic Configuration) and Principle II (Modular Separation of Concerns). Guarantees dry parameterization and eliminates configuration drift across target profiles (`desktop-pc`, `homelab`, `iso`).
- **Alternatives Considered**:
  - *Monolithic single-file configurations*: Rejected due to poor maintainability, code duplication, and inability to share module logic across machines.
  - *Separate repositories per host*: Rejected because it breaks shared user identity and prevents unified flake checks and task automation.

---

### 2. Declarative Secrets Management with SOPS and Age

- **Decision**: Implement in-repository declarative secret encryption using SOPS and Age asymmetric host keys (`sops-nix`), decrypting values strictly at activation runtime.
- **Rationale**: Satisfies Constitution Principle IV (Zero-Secrets Leakage) and Clarification Q1 (`FR-013`). Allows encrypted secret manifests to be version-controlled alongside system definitions while pre-commit checks (`pre-commit-hook-ensure-sops`, `ripsecrets`, `trufflehog`) prevent plaintext leaks.
- **Alternatives Considered**:
  - *Out-of-band manual provisioning (e.g. `/var/lib/secrets/`)*: Rejected due to loss of declarative reproducibility upon disaster recovery.
  - *External Vault / Cloud Secret Manager*: Rejected due to external network dependency during boot and unnecessary operational complexity for personal infrastructure.

---

### 3. Unified Developer Experience & Task Runner (`just` + `nh`)

- **Decision**: Centralize all operational recipes (build, switch, test, boot, check, lint, format, clean, update) into a root [`justfile`](../../justfile) wrapping `nh os` and `nix` CLI commands.
- **Rationale**: Fulfills Constitution Principle V and PRD `FR-007` (Measurable Outcome `SC-006`). Provides a single, discoverable command runner interface with grouped recipes and default parameters.
- **Alternatives Considered**:
  - *Raw `nixos-rebuild` and `nix` CLI commands*: Rejected due to complex flag combinations and lack of unified task discovery.
  - *Custom ad-hoc Bash scripts*: Rejected because `justfile` provides standard recipe listing (`just --list`), parameter passing, and cross-platform consistency.

---

### 4. Hermetic Quality Gates via `git-hooks.nix`

- **Decision**: Embed git hooks into `flake.nix` under `checks.${system}.pre-commit-check` and integrate them with the default `devShell` and `nix fmt`.
- **Rationale**: Fulfills Constitution Principle III (Shift-Left Quality) and Principle IV. Running checks via `nix flake check` executes in a sandboxed, read-only environment without internet access, ensuring exact reproducibility of linting (`statix`, `deadnix`), formatting (`alejandra`), and secret scanning (`trufflehog`, `ripsecrets`).
- **Alternatives Considered**:
  - *Imperative pre-commit installation via pip*: Rejected because it introduces non-hermetic system dependencies outside the Nix store.

---

### 5. Modern Bootloader & Rollback Strategy

- **Decision**: Configure the `Limine` UEFI bootloader with an explicit generation limit (`maxGenerations = 5`), last-entry memory, custom artwork, and dual-boot entries in `modules/nixos/base.nix`.
- **Rationale**: Satisfies PRD `FR-005` and `SC-005` (instant generation rollback in <60s). Limine provides a lightweight, clean UEFI interface with rapid boot times and multi-generation selection.
- **Alternatives Considered**:
  - *GRUB*: Functional but heavier, slower boot initialization, and more complex theming configuration.
  - *systemd-boot*: Fast but limited in styling and flexible custom multi-protocol boot entries.
