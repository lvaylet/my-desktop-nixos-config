# Tasks: Local Gemma 4 Model Acceleration & Aider CLI Integration

**Input**: Design documents from [`specs/004-local-gemma-antigravity/`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/specs/004-local-gemma-antigravity/)
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/ollama-service-contract.md](contracts/ollama-service-contract.md), [contracts/aider-cli-contract.md](contracts/aider-cli-contract.md), [quickstart.md](quickstart.md)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`, `[US4]`)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Module scaffolding and directory structure for local model serving and Aider CLI tooling

- [X] T001 Create module files scaffolding for local Ollama service at [`modules/nixos/ollama.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/nixos/ollama.nix) and Aider CLI at [`modules/home-manager/aider.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/home-manager/aider.nix)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Verify host hardware configuration and NVIDIA GPU prerequisites for CUDA acceleration

**⚠️ CRITICAL**: Must complete before user story module implementations

- [X] T002 Verify NVIDIA driver and graphics module compatibility in [`modules/nixos/nvidia.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/nixos/nvidia.nix) for CUDA acceleration on `desktop-pc`

**Checkpoint**: Foundation ready — GPU driver prerequisites verified.

---

## Phase 3: User Story 1 - Local Hardware-Accelerated Model Inference (Priority: P1) 🎯 MVP

**Goal**: Implement declarative NixOS Ollama service with CUDA acceleration, 8k context window support, and loopback binding, and configure on-demand model acquisition (`just download-model`) on `desktop-pc`.

**Independent Test**: Evaluate and test `desktop-pc` configuration, verify `ollama.service` starts with CUDA acceleration, and confirm `just download-model model="gemma4:12b"` pulls model into `/var/lib/ollama/models`.

### Implementation for User Story 1

- [X] T003 [US1] Implement declarative Ollama system service with CUDA acceleration (`pkgs.ollama-cuda`) and loopback network binding (`127.0.0.1:11434`) in [`modules/nixos/ollama.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/nixos/ollama.nix) per [`contracts/ollama-service-contract.md`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/specs/004-local-gemma-antigravity/contracts/ollama-service-contract.md)
- [X] T004 [US1] Configure on-demand model download recipe (`just download-model model="gemma4:12b"`) in [`justfile`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile) to avoid build-time delays
- [X] T005 [US1] Import [`modules/nixos/ollama.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/nixos/ollama.nix) into the host configuration at [`machines/desktop-pc/configuration.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/machines/desktop-pc/configuration.nix)
- [X] T006 [P] [US1] Verify NixOS Ollama module evaluation and syntax with `nix flake check`

**Checkpoint**: User Story 1 complete — local CUDA-accelerated Ollama inference service operational on `desktop-pc` with on-demand model pulling and 8k context capacity.

---

## Phase 4: User Story 2 - Aider TUI CLI Local AI Pair-Programming (Priority: P1)

**Goal**: Provision Aider (`pkgs.aider-chat`), configure `~/.aider.conf.yml` with `model: ollama/gemma4:12b`, and set session environment variables in Home Manager.

**Independent Test**: Invoke `aider --version` and `just aider` in a user shell session and verify it reaches `http://127.0.0.1:11434` and initiates pair programming using `gemma4:12b`.

### Implementation for User Story 2

- [X] T007 [US2] Implement Home Manager module for Aider CLI package (`pkgs.aider-chat`), configuration file (`~/.aider.conf.yml`), and session environment variable (`OLLAMA_API_BASE`) in [`modules/home-manager/aider.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/home-manager/aider.nix) per [`contracts/aider-cli-contract.md`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/specs/004-local-gemma-antigravity/contracts/aider-cli-contract.md)
- [X] T008 [US2] Import [`modules/home-manager/aider.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/home-manager/aider.nix) into the desktop user profile in [`machines/desktop-pc/configuration.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/machines/desktop-pc/configuration.nix)
- [X] T009 [US2] Add convenient Aider task runner recipe (`just aider`) in [`justfile`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile)
- [X] T010 [P] [US2] Remove outdated [`modules/home-manager/antigravity.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/home-manager/antigravity.nix)

**Checkpoint**: User Story 2 complete — Aider CLI configured and connected to local Ollama Gemma 4 model endpoint.

---

## Phase 5: User Story 3 - Workstation Memory Budgeting & System Responsiveness (Priority: P2)

**Goal**: Ensure Ollama memory allocation is budgeted (~14–15 GB VRAM peak including 8k KV cache) so the Wayland/X11 desktop compositor and graphical applications remain fluid during active inference.

**Independent Test**: Run a sustained completion generation task with 8k context while actively interacting with graphical desktop windows and monitor VRAM headroom using `nvidia-smi` / `nvtop`.

### Implementation for User Story 3

- [X] T011 [US3] Configure Ollama runtime environment options (`OLLAMA_NUM_PARALLEL`, `OLLAMA_KEEP_ALIVE`) in [`modules/nixos/ollama.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/nixos/ollama.nix) to protect desktop VRAM headroom
- [X] T012 [P] [US3] Verify seamless GPU resource sharing between graphical desktop subsystems in [`modules/nixos/nvidia.nix`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/modules/nixos/nvidia.nix) and the CUDA inference service

**Checkpoint**: User Story 3 complete — memory budgeting and desktop stability confirmed with 8k context window.

---

## Phase 6: User Story 4 - Model Diagnostics & Resource Monitoring (Priority: P3)

**Goal**: Add operational task runner recipes to `justfile` for inspecting Ollama service health, viewing active models, downloading models on demand, and monitoring GPU VRAM allocation.

**Independent Test**: Execute `just ollama-status`, `just download-model`, `just aider`, and `just gpu-status` on the workstation and verify accurate service and GPU metrics.

### Implementation for User Story 4

- [X] T013 [US4] Add diagnostic task runner recipes for Ollama service status, systemd logs, model listing, and on-demand model download (`just ollama-status`, `just ollama-logs`, `just ollama-models`, `just download-model`) in [`justfile`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile)
- [X] T014 [P] [US4] Add GPU resource monitoring and local inference smoke-test recipes (`just gpu-status`, `just test-inference`) in [`justfile`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile)

**Checkpoint**: User Story 4 complete — operational observability and diagnostic recipes available.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Code formatting, static linting, end-to-end quickstart validation, and documentation updates

- [X] T015 [P] Apply `alejandra` formatting and verify static linters (`statix check`, `deadnix`) across all modified Nix modules via `just fmt` and `just lint`
- [X] T016 Run hermetic sandbox verification via `just check` (`nix flake check`)
- [X] T017 Validate end-to-end execution scenarios per [`quickstart.md`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/specs/004-local-gemma-antigravity/quickstart.md)
- [X] T018 [P] Document local Gemma 4 model acceleration, on-demand downloading, and Aider CLI workflow in [`README.md`](file:///usr/local/google/home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/README.md)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion (MVP)
- **User Story 2 (Phase 4)**: Depends on User Story 1 completion (connects to Ollama service)
- **User Story 3 (Phase 5)**: Depends on User Story 1 completion (tunes Ollama memory parameters)
- **User Story 4 (Phase 6)**: Depends on User Story 1 & 2 completion (adds operational recipes)
- **Polish (Phase 7)**: Depends on all user story implementations

### User Story Dependencies

```mermaid
graph TD
    P1[Phase 1: Setup] --> P2[Phase 2: Foundational Prerequisites]
    P2 --> US1[Phase 3: US1 - Local CUDA Ollama & On-Demand Gemma 4 12B with 8k Context]
    US1 --> US2[Phase 4: US2 - Aider CLI Integration]
    US1 --> US3[Phase 5: US3 - Memory Budgeting & Responsiveness]
    US1 --> US4[Phase 6: US4 - Diagnostics & Justfile Recipes]
    US2 --> US4
    US1 --> Polish[Phase 7: Polish, Linting & Quickstart Validation]
    US2 --> Polish
    US3 --> Polish
    US4 --> Polish
```

---

## Parallel Execution Opportunities

- **T006** ran in parallel with **T003–T005** (evaluates flake checks while module integration proceeds).
- **T010** ran in parallel with **T007–T009** (removes outdated module file).
- **T012** ran in parallel with **T011** (checks NVIDIA module compatibility).
- **T014** ran in parallel with **T013** (adds GPU recipes in `justfile`).
- **T015** (formatting/linting) and **T018** (documentation) ran in parallel in Phase 7.

---

## Implementation Strategy & MVP Scope

1. **MVP (Phases 1–3)**: Delivered `modules/nixos/ollama.nix` with CUDA acceleration (`pkgs.ollama-cuda`) on `desktop-pc` and on-demand model download via `just download-model`.
2. **Incremental Delivery (Phases 4–6)**:
   - Delivered `modules/home-manager/aider.nix` for seamless terminal AI pair programming (User Story 2).
   - Tuned memory limits and parallel parameters to preserve desktop GUI fluidness (User Story 3).
   - Added convenient `just` task runner recipes for health monitoring, model downloads, Aider launcher, and smoke testing (User Story 4).
3. **Final Polish (Phase 7)**: Formatted all expressions (`just fmt`), linted (`just lint`), ran full sandbox checks (`just check`), and validated with `quickstart.md`.
