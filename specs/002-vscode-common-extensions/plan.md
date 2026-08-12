# Implementation Plan: Common Multi-Language VS Code Extensions and Tooling

**Branch**: `002-vscode-common-extensions` | **Date**: 2026-08-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from [`specs/002-vscode-common-extensions/spec.md`](spec.md)

## Summary

This plan defines the declarative configuration updates required to add five common multi-language Visual Studio Code extensions (Code Runner, CodeLLDB, Dependin, markdownlint, ShellCheck) and their supporting CLI dependencies (`shellcheck`). The technical approach modifies `modules/home-manager/vscode.nix` to declare extension derivations from `pkgs.vscode-extensions` and configure terminal execution for Code Runner, while adding `pkgs.shellcheck` to `modules/home-manager/_packages.nix` for dual IDE and CLI terminal availability.

## Technical Context

**Language/Version**: Nix Expression Language (2.18+ / 2.24+ Flakes), JSON (VS Code Settings schema)

**Primary Dependencies**: `nixpkgs` (`pkgs.vscode-extensions.*`, `pkgs.shellcheck`), `home-manager` (`programs.vscode`), Visual Studio Code

**Storage**: `$HOME/.config/Code/User/settings.json`, `$HOME/.vscode/extensions/` (declaratively managed by Home Manager symlinks)

**Testing**: Hermetic evaluation tests via `just check` (`nix flake check`), static analysis via `just lint` (`statix check`, `deadnix`), and safe non-switching activation testing via `just test configuration="desktop-pc"` (`nh os test`)

**Target Platform**: x86_64-linux (Interactive developer workstation: `desktop-pc`)

**Project Type**: Declarative Editor Module & User Tooling Configuration (Home Manager)

**Performance Goals**: Flake evaluation <10s; user environment activation in <30s; real-time in-editor diagnostics (<2s)

**Constraints**: Pure hermetic Nix expressions; zero imperative extension management; dual CLI/IDE parity for `shellcheck`; strict `alejandra` formatting

**Scale/Scope**: 2 Home Manager modules (`modules/home-manager/vscode.nix`, `modules/home-manager/_packages.nix`), 5 VS Code extensions, 1 CLI binary package, declarative user settings

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle / Rule | Gate Status | Compliance Verification |
| :--- | :--- | :--- |
| **I. Declarative & Hermetic Configuration** | **PASS** | All extensions and CLI packages are declared purely via Nix flakes and Home Manager with deterministic pinning in `flake.lock`. |
| **II. Modular Separation & DRY Parameterization** | **PASS** | Editor extensions and settings are encapsulated in `modules/home-manager/vscode.nix`, while shared user CLI utilities are centralized in `modules/home-manager/_packages.nix`. |
| **III. Shift-Left Quality & Linting** | **PASS** | Code formats cleanly with `alejandra` (`just fmt`) and passes `statix check` and `deadnix` (`just lint`) with zero warnings. |
| **IV. Zero-Secrets Leakage & Security First** | **PASS** | No credentials, private keys, or API tokens are introduced in the declarative editor configuration. |
| **V. Rigorous Verification & Safe Deployment** | **PASS** | Follows the prescribed verification cycle: `just check` → `just test` before `just switch`. |

## Project Structure

### Documentation (this feature)

```text
specs/002-vscode-common-extensions/
├── checklists/
│   └── requirements.md    # Specification quality checklist
├── contracts/
│   ├── user-packages-contract.md  # Home Manager packages contract
│   └── vscode-module-contract.md  # VS Code module & settings contract
├── data-model.md          # Extension entities, schemas, and lifecycle states
├── plan.md                # This implementation plan
├── quickstart.md          # Step-by-step runnable validation guide
├── research.md            # Technical research and design decisions
└── spec.md                # Clarified feature specification
```

### Source Code (repository root)

```text
modules/
└── home-manager/
    ├── _packages.nix      # Added pkgs.shellcheck for CLI & IDE parity
    └── vscode.nix         # Added extensions & code-runner.runInTerminal settings
```

**Structure Decision**: Preserves existing Home Manager modular layout by updating `modules/home-manager/vscode.nix` for editor profile settings and `modules/home-manager/_packages.nix` for the supporting `shellcheck` CLI tool.

## Complexity Tracking

*No constitutional violations or unjustified architectural complexities detected.*
