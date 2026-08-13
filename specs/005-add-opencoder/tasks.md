# Tasks: OpenCoder AI Assistant Integration alongside Aider

**Input**: Design documents from `specs/005-add-opencoder/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Format: `- [ ] [ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., [US1], [US2], [US3], [US4])
- Includes exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Module structure and initial definitions

- [X] T001 Create Home Manager module file in `modules/home-manager/opencode.nix`
- [X] T002 [P] Verify `pkgs.opencode` availability in nixpkgs evaluation via `flake.nix`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core declarative configuration that MUST be complete before user story activation

- [X] T003 Define declarative OpenCoder configuration schema in `modules/home-manager/opencode.nix` targeting `ollama/gemma4:12b` via `@ai-sdk/openai` provider at `http://127.0.0.1:11434/v1` with 8,192 token context limits

---

## Phase 3: User Story 1 - Declarative OpenCoder CLI Installation & Local Gemma 4 Model Integration (Priority: P1) 🎯 MVP

**Goal**: Provision OpenCoder CLI and declarative configuration in the user environment on `desktop-pc`.

**Independent Test**: Evaluate `nixosConfigurations.desktop-pc` and verify `opencode` package and configuration file are declared.

- [X] T004 [US1] Implement `modules/home-manager/opencode.nix` provisioning `pkgs.opencode` and `xdg.configFile."opencode/config.json"`
- [X] T005 [US1] Import `./../../modules/home-manager/opencode.nix` into `machines/desktop-pc/configuration.nix`

---

## Phase 4: User Story 2 - Coexistence and Tool Switching between Aider and OpenCoder (Priority: P1)

**Goal**: Ensure clean coexistence and concurrent availability of both Aider and OpenCoder.

**Independent Test**: Verify both `aider.nix` and `opencode.nix` are imported in `machines/desktop-pc/configuration.nix` without mutual exclusion.

- [X] T006 [US2] Verify independent configuration paths for Aider (`~/.aider.conf.yml`) and OpenCoder (`~/.config/opencode/config.json`)
- [X] T007 [US2] Confirm `machines/desktop-pc/configuration.nix` retains both `aider.nix` and `opencode.nix` imports simultaneously

---

## Phase 5: User Story 3 - Context-Aware Offline AI Pair-Programming with OpenCoder (Priority: P2)

**Goal**: Ensure OpenCoder is configured with 100% offline local loopback settings and 8k context window limits.

**Independent Test**: Inspect generated `config.json` text to verify loopback binding and token limits.

- [X] T008 [US3] Verify offline provider settings and 8k context window boundaries in `modules/home-manager/opencode.nix`

---

## Phase 6: User Story 4 - Operational Task Runner Recipes & Developer Ergonomics (Priority: P3)

**Goal**: Provide convenient command-line recipes in `justfile` for running OpenCoder.

**Independent Test**: Check `justfile` contains `opencode` recipe and verify recipe syntax.

- [X] T009 [US4] Add `opencode` task runner recipe to `justfile`

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Formatting, static analysis, flake integrity, and validation

- [X] T010 [P] Format all modified Nix expressions using `alejandra` (`nix fmt .` / `just fmt`)
- [X] T011 Run static analysis and linting (`just lint` / `deadnix` / `statix check`)
- [X] T012 Run full hermetic checks (`just check` / `nix flake check`)
- [X] T013 Validate end-to-end against `specs/005-add-opencoder/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - starts immediately.
- **Foundational (Phase 2)**: Depends on Phase 1.
- **User Story 1 (Phase 3)**: Depends on Phase 2.
- **User Story 2 (Phase 4)**: Depends on Phase 3.
- **User Story 3 (Phase 5)**: Depends on Phase 3.
- **User Story 4 (Phase 6)**: Can run in parallel with User Story 2/3.
- **Polish (Phase 7)**: Depends on all implementation phases.

### Parallel Opportunities

- T001 and T002 can run in parallel.
- T009 can be developed in parallel with T006-T008.
- T010 can format all files in parallel.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Create `modules/home-manager/opencode.nix`.
2. Import in `machines/desktop-pc/configuration.nix`.
3. Verify configuration evaluation.

### Incremental Delivery

1. Foundation + US1: OpenCoder available on desktop-pc.
2. US2 + US3: Clean coexistence with Aider and verified 8k offline context settings.
3. US4: Justfile shortcuts.
4. Polish: Formatting, linting, and flake checks passing 100%.
