# Tasks: Common Multi-Language VS Code Extensions and Tooling

**Input**: Design documents from `/specs/002-vscode-common-extensions/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4, US5)
- Exact file paths are included in all descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Baseline inspection and prerequisite checks

- [ ] T001 Inspect current VS Code configuration and user package lists in `modules/home-manager/vscode.nix` and `modules/home-manager/_packages.nix`
- [ ] T002 Verify `pkgs.vscode-extensions` and `pkgs.shellcheck` derivation attributes in `flake.nix` and `flake.lock`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Provide underlying CLI binaries required across user stories and terminal workflows

**⚠️ CRITICAL**: Must be completed before User Story 1 testing

- [ ] T003 [P] Add `shellcheck` package to `home.packages` in `modules/home-manager/_packages.nix`

**Checkpoint**: Foundation ready — supporting CLI binaries declared for system and editor usage.

---

## Phase 3: User Story 1 - Shell Script Linting & Diagnostics (Priority: P1) 🎯 MVP

**Goal**: Enable real-time inline shell script static analysis and diagnostic warnings in VS Code via ShellCheck.

**Independent Test**: Open a shell script containing unquoted variables; verify inline SC2086 diagnostic warnings appear in the editor and Problems pane, and verify `shellcheck --version` runs in the CLI.

### Implementation for User Story 1

- [ ] T004 [US1] Add `timonwong.shellcheck` extension to `programs.vscode.profiles.default.extensions` in `modules/home-manager/vscode.nix`
- [ ] T005 [US1] Validate ShellCheck CLI binary availability and in-editor diagnostics per `specs/002-vscode-common-extensions/quickstart.md`

**Checkpoint**: User Story 1 is fully functional and testable independently (MVP complete).

---

## Phase 4: User Story 2 - Markdown Document Quality & Formatting (Priority: P2)

**Goal**: Ensure markdown linting, formatting, and style rules are enforced in the editor.

**Independent Test**: Open a Markdown file with non-standard heading levels (e.g. jumping from H1 to H3) and verify markdownlint displays `MD001` diagnostic warnings.

### Implementation for User Story 2

- [ ] T006 [US2] Verify and organize `davidanson.vscode-markdownlint` extension under Linters section in `modules/home-manager/vscode.nix`
- [ ] T007 [US2] Validate markdownlint diagnostic highlights on `.md` documents per `specs/002-vscode-common-extensions/quickstart.md`

**Checkpoint**: User Stories 1 and 2 are functional independently.

---

## Phase 5: User Story 3 - Multi-Language Quick Code Execution (Priority: P3)

**Goal**: Enable one-click / shortcut execution of code snippets across multiple programming languages in the integrated terminal.

**Independent Test**: Open a standalone script (Python, Bash, or Rust), trigger "Run Code" (`Ctrl+Alt+N`), and verify output streams to the integrated terminal with interactive `stdin` support.

### Implementation for User Story 3

- [ ] T008 [US3] Add `formulahendry.code-runner` extension to `programs.vscode.profiles.default.extensions` in `modules/home-manager/vscode.nix`
- [ ] T009 [US3] Configure `code-runner.runInTerminal`, `code-runner.saveFileBeforeRun`, and `code-runner.clearPreviousOutput` in `programs.vscode.profiles.default.userSettings` in `modules/home-manager/vscode.nix`
- [ ] T010 [US3] Validate Code Runner execution in the integrated terminal per `specs/002-vscode-common-extensions/quickstart.md`

**Checkpoint**: User Stories 1, 2, and 3 are functional independently.

---

## Phase 6: User Story 4 - Native Systems & Compiled Code Debugging (Priority: P4)

**Goal**: Enable native visual debugging (LLDB) for compiled and systems languages (C, C++, Rust, Zig) in VS Code.

**Independent Test**: Open the Run & Debug panel (`Ctrl+Shift+D`) and verify the CodeLLDB adapter initializes without dynamic linker or missing library errors.

### Implementation for User Story 4

- [ ] T011 [US4] Add `vadimcn.vscode-lldb` extension to `programs.vscode.profiles.default.extensions` in `modules/home-manager/vscode.nix`
- [ ] T012 [US4] Validate CodeLLDB debug adapter initialization per `specs/002-vscode-common-extensions/quickstart.md`

**Checkpoint**: User Stories 1 through 4 are functional independently.

---

## Phase 7: User Story 5 - Package Dependency Version Checking (Priority: P5)

**Goal**: Provide inline dependency version analysis and upgrade indicators in project manifest files (`Cargo.toml`, `package.json`).

**Independent Test**: Open a `Cargo.toml` or `package.json` file and verify inline version status lenses appear for declared dependencies.

### Implementation for User Story 5

- [ ] T013 [US5] Add `fill-labs.dependi` extension to `programs.vscode.profiles.default.extensions` in `modules/home-manager/vscode.nix`
- [ ] T014 [US5] Validate Dependin manifest lens annotations per `specs/002-vscode-common-extensions/quickstart.md`

**Checkpoint**: All 5 user stories are functional independently.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Code hygiene, formatting, static analysis, flake evaluation, and system activation.

- [ ] T015 [P] Format all modified Nix files using `just fmt` (or `nix fmt .`) across `modules/home-manager/`
- [ ] T016 [P] Run static linting with `just lint` (`deadnix` and `statix check`) on `modules/home-manager/`
- [ ] T017 Run hermetic flake checks with `just check` (`nix flake check`)
- [ ] T018 Execute safe non-switching activation test with `just test configuration="desktop-pc"` per `specs/002-vscode-common-extensions/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion — blocks User Story 1 (ShellCheck binary dependency).
- **User Stories (Phases 3–7)**: Can proceed in priority order (P1 → P2 → P3 → P4 → P5) or in parallel once Phase 2 is complete.
- **Polish (Phase 8)**: Depends on completion of all desired user stories.

### User Story Dependencies

- **User Story 1 (P1)**: Depends on `T003` (CLI binary in `_packages.nix`).
- **User Story 2 (P2)**: Independent of other stories.
- **User Story 3 (P3)**: Independent of other stories.
- **User Story 4 (P4)**: Independent of other stories.
- **User Story 5 (P5)**: Independent of other stories.

### Parallel Opportunities

- `T003` (modifying `_packages.nix`) and `T004` (modifying `vscode.nix`) touch different files and can be prepared concurrently.
- `T015` and `T016` (formatting and linting) can run concurrently during the Polish phase.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (`T001`–`T002`).
2. Complete Phase 2: Foundational (`T003`).
3. Complete Phase 3: User Story 1 (`T004`–`T005`).
4. **STOP and VALIDATE**: Test ShellCheck in terminal and editor (`just test configuration="desktop-pc"`).

### Incremental Delivery

1. Apply Phase 2 + Phase 3 → Deliver ShellCheck (MVP).
2. Apply Phase 4 → Deliver Markdownlint.
3. Apply Phase 5 → Deliver Code Runner with terminal execution.
4. Apply Phase 6 → Deliver CodeLLDB debugging.
5. Apply Phase 7 → Deliver Dependin manifest inspection.
6. Apply Phase 8 → Full formatting, static analysis, and flake check.
