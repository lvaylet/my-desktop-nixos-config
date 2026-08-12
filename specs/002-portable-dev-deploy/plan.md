# Implementation Plan: Portable Multi-Environment Development, Testing, and Deployment

**Branch**: `002-portable-dev-deploy` | **Date**: 2026-08-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from [`specs/002-portable-dev-deploy/spec.md`](spec.md)

## Summary

This plan enables the repository to be developed, tested, and deployed from any Linux machine (local or remote, NixOS or non-NixOS) and introduces Devbox support for non-Linux platforms (macOS / Windows WSL). The technical approach introduces a declarative `devbox.json` environment definition for cross-platform onboarding, expands `systems` in `flake.nix` for multi-platform devShells, parameterizes `justfile` operational recipes (`switch`, `test`, `boot`, `build`) with an optional `target` host parameter backed by native `nixos-rebuild --target-host` and safety guards against non-NixOS local switches, and enables unprivileged local closure builds on non-NixOS Linux hosts.

## Technical Context

**Language/Version**: Nix Expression Language (2.18+ / 2.24+ Flakes), POSIX Shell/Bash, Just (1.x), JSON (Devbox Schema)

**Primary Dependencies**: `nixpkgs` (`nixos-unstable`), `home-manager`, `nvf`, `git-hooks.nix`, `nh`, `devbox` (Jetify CLI)

**Storage**: Immutable `/nix/store`, local workspace artifacts, remote `/nix/store` on target hosts

**Testing**: Hermetic flake checks via `nix flake check` on all supported architectures; unprivileged local builds via `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`; non-switching remote testing via `nixos-rebuild test --target-host <target> --use-remote-sudo`

**Target Platform**: Any Linux machine (`x86_64-linux`, `aarch64-linux`), macOS (`x86_64-darwin`, `aarch64-darwin`), Windows (WSL2 with Devbox); deployment targets remain dedicated NixOS machines (`desktop-pc`, `homelab`, `iso`)

**Project Type**: Declarative Infrastructure as Code (IaC) & Multi-Environment Developer Tooling

**Performance Goals**: Devbox shell onboarding <5m; local unprivileged syntax and derivation evaluation <30s; single-command remote deployment to target hosts

**Constraints**: Zero plaintext secrets committed to VCS; zero system modifications (`/etc`, `/boot`) on non-NixOS host machines; 100% backward compatibility for existing native NixOS local switch/test workflows

**Scale/Scope**: 1 new `devbox.json` file, multi-system expansion in `flake.nix`, updated `justfile` recipes with `target` parameterization and non-NixOS guards

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle / Rule | Gate Status | Compliance Verification |
| :--- | :--- | :--- |
| **I. Declarative & Hermetic Configuration** | **PASS** | `devbox.json` and `flake.nix` devShells declare all tools hermetically. No imperative host modifications. Target NixOS machines configured purely via Nix flakes. |
| **II. Modular Separation & DRY Parameterization** | **PASS** | Modular host definitions (`machines/`) and shared modules remain intact. Remote connection parameters decoupled via `target` parameter. |
| **III. Shift-Left Quality & Linting** | **PASS** | Identical linter/formatter toolchain (`alejandra`, `statix`, `deadnix`) guaranteed across native Nix and Devbox environments. |
| **IV. Zero-Secrets Leakage & Security First** | **PASS** | SSH authentication uses native SSH keys/agents without embedding credentials in code or version control. |
| **V. Rigorous Verification & Safe Deployment** | **PASS** | Non-NixOS safety guards prevent accidental host disruption; non-switching activation (`just test <config> <target>`) supported before permanent switch. |

## Project Structure

### Documentation (this feature)

```text
specs/002-portable-dev-deploy/
├── checklists/
│   └── requirements.md    # Specification quality checklist
├── contracts/
│   ├── cli-contract.md    # Operational task runner interface contract
│   └── devbox-contract.md # Devbox schema and tool parity contract
├── data-model.md          # Domain entities, attributes, and lifecycle state transitions
├── plan.md                # This implementation plan
├── quickstart.md          # Step-by-step runnable validation guide
├── research.md            # Architectural decisions and trade-off analysis
└── spec.md                # Feature specification
```

### Source Code (repository root)

```text
.
├── devbox.json            # Declarative cross-platform Devbox environment
├── flake.lock             # Deterministically pinned input hashes
├── flake.nix              # Root flake entrypoint (expanded multi-system devShells)
├── justfile               # Parameterized operational recipes (local + remote SSH)
├── vars.nix               # Centralized user identity and SSH keys
├── machines/              # Host composition entrypoints (desktop-pc, homelab, iso)
└── modules/               # NixOS and Home Manager configuration modules
```

**Structure Decision**: Adds `devbox.json` at root and extends `flake.nix` and `justfile` without altering machine definitions or module hierarchies.

## Complexity Tracking

*No constitutional violations or unjustified architectural complexities detected.*
