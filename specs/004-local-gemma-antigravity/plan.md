# Implementation Plan: Local Gemma 4 Model Acceleration & Antigravity CLI Integration

**Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from [`specs/004-local-gemma-antigravity/spec.md`](spec.md)

## Summary

This implementation plan provisions an offline, hardware-accelerated local large language model inference environment on the `desktop-pc` workstation (32 GB RAM, NVIDIA GeForce RTX 5070 Ti with 16 GB VRAM) running an 8-bit quantized Gemma 4 12B model (`gemma4:12b`), and integrates the latest Antigravity CLI into the user's terminal environment.

The architecture introduces:
1. A declarative NixOS module (`modules/nixos/ollama.nix`) enabling `services.ollama` with CUDA acceleration, loopback network binding (`127.0.0.1:11434`), and declarative model pre-loading (`services.ollama.loadModels = [ "gemma4:12b" ]`).
2. A declarative Home Manager module (`modules/home-manager/antigravity.nix`) provisioning the latest Antigravity CLI and pre-configuring environment variables (`ANTIGRAVITY_API_BASE=http://127.0.0.1:11434/v1`, `ANTIGRAVITY_MODEL=gemma4:12b`, `ANTIGRAVITY_OFFLINE=1`).
3. Host assembly updates in `machines/desktop-pc/configuration.nix` and task runner verification recipes in `justfile`.

## Technical Context

**Language/Version**: Nix Expression Language (2.18+ / 2.24+ Flakes), Shell / Bash

**Primary Dependencies**: `services.ollama` (NixOS module with CUDA acceleration), `antigravity-cli`, `pkgs.linuxPackages_latest.nvidiaPackages.latest`

**Storage**: Persistent host storage at `/var/lib/ollama/models` (survives system generation switches and rollbacks)

**Testing**: Hermetic static analysis (`nix flake check` / `just check`), local test activation (`just test configuration="desktop-pc"`), HTTP loopback API checks (`curl`), and interactive CLI validation

**Target Platform**: Physical workstation `desktop-pc` (`x86_64-linux`) with 32 GB RAM and NVIDIA GeForce RTX 5070 Ti (16 GB VRAM)

**Project Type**: Declarative NixOS Infrastructure & Developer Tooling

**Performance Goals**: 100% GPU layer offloading into 16 GB VRAM; generation latency <2s time-to-first-token; ~40+ tokens/sec sustained throughput; ~2–3 GB VRAM reserved for desktop compositing

**Constraints**: 100% offline inference capability; zero cloud telemetry or third-party token requirements; loopback-only network binding (`127.0.0.1`); zero large binary blobs stored in Git

**Scale/Scope**: 1 new NixOS module (`modules/nixos/ollama.nix`), 1 new Home Manager module (`modules/home-manager/antigravity.nix`), host integration in `machines/desktop-pc/configuration.nix`, and operational recipes in `justfile`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle / Rule | Gate Status | Compliance Verification |
| :--- | :---: | :--- |
| **I. Declarative & Hermetic Configuration** | **PASS** | All services, package packages, and environment settings are declared purely via Nix expressions. Dependencies are pinned via `flake.lock`. Model weights persist in standard runtime paths (`/var/lib/ollama`) without polluting Git or Nix store derivations. |
| **II. Modular Separation & DRY Parameterization** | **PASS** | Host entrypoint (`machines/desktop-pc/configuration.nix`) only imports modules. System daemon is isolated in `modules/nixos/ollama.nix`, and user tooling is isolated in `modules/home-manager/antigravity.nix`. Shared variables (`vars.userName`) reused consistently. |
| **III. Shift-Left Quality & Linting** | **PASS** | All new Nix expressions will format cleanly with `alejandra` (`nix fmt`), pass static analysis (`statix check`, `deadnix`), and succeed in hermetic pre-commit checks (`nix flake check`). |
| **IV. Zero-Secrets Leakage & Security First** | **PASS** | Inference service is strictly bound to local loopback (`127.0.0.1:11434`). Zero cloud API tokens or external credentials are used or committed. Prompts and code context remain 100% private to the physical machine. |
| **V. Rigorous Verification & Safe Deployment** | **PASS** | Follows the verification pipeline: `just check` → `just test configuration="desktop-pc"` → `just switch configuration="desktop-pc"`. State versions are unchanged. |

## Project Structure

### Documentation (this feature)

```text
specs/004-local-gemma-antigravity/
├── checklists/
│   └── requirements.md            # Specification quality checklist
├── contracts/
│   ├── antigravity-cli-contract.md# Antigravity CLI Home Manager interface contract
│   └── ollama-service-contract.md # Ollama NixOS service & OpenAI-compatible API contract
├── data-model.md                  # Entity relationships, memory budgeting, and state transitions
├── plan.md                        # This implementation plan
├── quickstart.md                  # Step-by-step runnable validation guide
├── research.md                    # Architectural decisions and trade-off analysis
└── spec.md                        # Feature specification
```

### Source Code (repository root)

```text
.
├── justfile                                   # Operational task runner recipes (e.g. ollama-status, check)
├── machines/
│   └── desktop-pc/
│       └── configuration.nix                  # Host assembly importing ollama and antigravity modules
├── modules/
│   ├── home-manager/
│   │   └── antigravity.nix                    # Declarative Home Manager user module for Antigravity CLI
│   └── nixos/
│       ├── nvidia.nix                         # Existing NVIDIA GPU graphics & driver configuration
│       └── ollama.nix                         # Declarative NixOS module for Ollama CUDA service
└── vars.nix                                   # Shared user and machine variables
```

**Structure Decision**:
- Creates `modules/nixos/ollama.nix` for the system-level inference service with CUDA acceleration.
- Creates `modules/home-manager/antigravity.nix` for the developer CLI package and local endpoint environment defaults.
- Updates `machines/desktop-pc/configuration.nix` to import both modules.
- Extends `justfile` with operational health and diagnostic recipes.

## Complexity Tracking

*No constitutional violations or unjustified architectural complexities detected.*
