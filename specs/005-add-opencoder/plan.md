# Implementation Plan: OpenCoder AI Assistant Integration alongside Aider

**Branch**: `005-add-opencoder` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from [`specs/005-add-opencoder/spec.md`](spec.md)

## Summary

This implementation plan integrates OpenCoder (`opencode`) as an additional terminal-native AI pair-programming assistant on the `desktop-pc` workstation alongside Aider (`aider-chat`). Both assistants share the local hardware-accelerated 8-bit quantized Gemma 4 12B model served via Ollama (`http://127.0.0.1:11434`), allowing the developer to evaluate and choose between them seamlessly.

The plan introduces:
1. A declarative Home Manager module (`modules/home-manager/opencode.nix`) providing `pkgs.opencode` and declarative configuration (`~/.config/opencode/config.json`) targeting the local Ollama Gemma 4 12B model with an 8,192 token context window.
2. Host integration in `machines/desktop-pc/configuration.nix` importing `opencode.nix` alongside `aider.nix`.
3. Task runner recipes in `justfile` (`just opencode`) providing convenient CLI shortcuts.

## Technical Context

**Language/Version**: Nix Expression Language (2.18+ / 2.24+ Flakes), JSON, Shell / Bash

**Primary Dependencies**: `pkgs.opencode` (nixpkgs-unstable), `services.ollama` (CUDA-accelerated Gemma 4 12B)

**Storage**: User configuration at `~/.config/opencode/config.json` (managed via Home Manager XDG)

**Testing**: Hermetic flake checks (`nix flake check` / `just check`), local evaluation, and interactive CLI invocation

**Target Platform**: Physical workstation `desktop-pc` (`x86_64-linux`)

**Project Type**: Declarative NixOS / Home Manager User Environment Module

**Performance Goals**: Fast CLI startup (<2s), instant model connectivity over local loopback (`http://127.0.0.1:11434/v1`), 8k context window support (8,192 tokens), zero conflicts with Aider

**Constraints**: 100% offline inference capability, zero external cloud telemetry/tokens required, pure declarative configuration via Nix

**Scale/Scope**: 1 new Home Manager module (`modules/home-manager/opencode.nix`), 1 host configuration update (`machines/desktop-pc/configuration.nix`), and 1 `justfile` recipe addition

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle / Rule | Gate Status | Compliance Verification |
| :--- | :---: | :--- |
| **I. Declarative & Hermetic Configuration** | **PASS** | Package `pkgs.opencode` and its configuration (`~/.config/opencode/config.json`) are fully declared in Home Manager. Zero imperative setup or untracked state mutations. |
| **II. Modular Separation & DRY Parameterization** | **PASS** | `opencode.nix` is encapsulated in `modules/home-manager/` and imported in `machines/desktop-pc/configuration.nix`. Aider and OpenCoder remain completely decoupled peer modules. |
| **III. Shift-Left Quality & Linting** | **PASS** | All Nix expressions format cleanly with `alejandra` (`nix fmt`), pass static analysis (`statix check`, `deadnix`), and pass pre-commit checks (`just check`). |
| **IV. Zero-Secrets Leakage & Security First** | **PASS** | OpenCoder targets local loopback Ollama endpoint (`127.0.0.1:11434/v1`). No API keys, credentials, or private data are committed or transmitted externally. |
| **V. Rigorous Verification & Safe Deployment** | **PASS** | Verified via `just check` before system activation testing (`just test configuration="desktop-pc"`). |

## Project Structure

### Documentation (this feature)

```text
specs/005-add-opencoder/
├── checklists/
│   └── requirements.md                          # Specification quality checklist
├── contracts/
│   ├── ollama-opencode-integration-contract.md  # Ollama OpenAI API integration contract
│   └── opencode-cli-contract.md                 # OpenCoder Home Manager module contract
├── data-model.md                                # Entity relationships and config schemas
├── plan.md                                      # This implementation plan
├── quickstart.md                                # Runnable validation guide
├── research.md                                  # Architectural decisions & trade-offs
└── spec.md                                      # Feature specification
```

### Source Code (repository root)

```text
.
├── justfile                                     # Added `just opencode` recipe
├── machines/
│   └── desktop-pc/
│       └── configuration.nix                    # Imported modules/home-manager/opencode.nix
└── modules/
    └── home-manager/
        ├── aider.nix                            # Existing Aider module (preserved untouched)
        └── opencode.nix                         # New OpenCoder Home Manager module
```

## Complexity Tracking

*No constitutional violations or unjustified architectural complexities detected.*
