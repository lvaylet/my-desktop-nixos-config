# Feature Specification: Common Multi-Language VS Code Extensions and Tooling

**Feature Branch**: `002-vscode-common-extensions`

**Created**: 2026-08-12

**Status**: Draft

**Input**: User description: "Ajoute des extensions VS Code communes à plusieurs langages dans le service/module dédié : Code Runner (de Jun Han), CodeLLDB (de Vadim Chugunov), Dependin (de Fill Labs), markdownlint (de David Anson), ShellCheck (de Timon Wong). Ajoute aussi les binaires ou dépendances requises par ces extensions. Travaille en anglais dans les documents, le code, les commentaires, même si je te parle en français."

## Clarifications

### Session 2026-08-12

- Q: Where should supporting CLI binaries required by these extensions (such as `shellcheck`) be declared within the configuration? → A: Declared in the user packages module (`modules/home-manager/_packages.nix`) to provide dual availability across both the editor and the user's interactive CLI/terminal environment.
- Q: Should Code Runner be configured to execute code in the integrated terminal or in the output panel by default? → A: Integrated terminal (`code-runner.runInTerminal: true`) to support interactive user input (`stdin`), proper TTY handling, and terminal styling.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Shell Script Linting & Diagnostics (Priority: P1)

As a developer writing and maintaining shell scripts (Bash, POSIX sh, Zsh), I want automatic static analysis and diagnostic warnings highlighted in the editor as I type, backed by an integrated linter engine, so that I can catch syntax errors, portability issues, and bad practices early without running external CLI tools manually.

**Why this priority**: Shell scripts are foundational across system configuration, deployment scripts, and automation tasks. Immediate inline feedback prevents runtime scripting failures and potential security vulnerabilities before scripts are executed.

**Independent Test**: Open any shell script containing known linting warnings (such as unquoted variables or deprecated syntax). Verify that squiggly underlines and diagnostic messages appear in the Problems panel and inline editor view, with clear diagnostic explanations.

**Acceptance Scenarios**:

1. **Given** a workspace with a `.sh` or `.bash` file containing syntax or style pitfalls, **When** the file is opened or modified in the editor, **Then** ShellCheck diagnostic markers and rule explanations are displayed inline and in the Problems pane within 2 seconds.
2. **Given** a shell script with highlighted diagnostic warnings, **When** the issue is fixed according to the recommendation, **Then** the diagnostic marker clears automatically without requiring an editor reload.

---

### User Story 2 - Markdown Document Quality & Formatting (Priority: P2)

As a developer or technical writer maintaining project documentation, specifications, and notes in Markdown, I want continuous linting and style validation so that formatting remains clean, consistent, and adheres to standard Markdown guidelines across all documents.

**Why this priority**: Documentation quality directly impacts team collaboration and maintainability. Automated markdown checks catch broken structures, inconsistent headers, and formatting issues early.

**Independent Test**: Open a Markdown file containing formatting irregularities (such as inconsistent header levels or missing blank lines around lists). Verify that markdownlint highlights these style issues and offers automated quick-fix actions where supported.

**Acceptance Scenarios**:

1. **Given** a `.md` document with style violations (e.g., inconsistent heading increments or improper list indentation), **When** the document is opened or edited, **Then** markdownlint displays diagnostic hints and warnings.
2. **Given** a markdown diagnostic with an available automatic fix, **When** applying the quick fix action, **Then** the document formatting is corrected automatically.

---

### User Story 3 - Multi-Language Quick Code Execution (Priority: P3)

As a developer prototyping algorithms or testing standalone scripts across various programming languages, I want to execute the active file or selected code snippet with a single shortcut or click and see the output directly in the integrated terminal, without manually switching tabs and crafting execution commands.

**Why this priority**: Fast execution loops accelerate exploratory programming, small script verification, and multi-language learning workflows while supporting interactive input.

**Independent Test**: Open a standalone code file (e.g., Python, Bash, Node, or Rust), trigger the Code Runner action ("Run Code"), and verify that execution runs in the integrated terminal panel.

**Acceptance Scenarios**:

1. **Given** an open source file in a supported language, **When** invoking the Run Code command, **Then** the code runs within the integrated terminal panel, supporting interactive user input (`stdin`) and displaying output with full terminal styling.
2. **Given** a highlighted segment of code, **When** triggering Run Selected Code, **Then** only the selected block is executed in the terminal.

---

### User Story 4 - Native Systems & Compiled Code Debugging (Priority: P4)

As a developer working with compiled or systems languages (such as C, C++, Rust, Zig), I want to set breakpoints, step through executions, inspect variables and memory, and evaluate expressions in the visual debugger using CodeLLDB without complex external debugger wiring.

**Why this priority**: Native debugging is essential for troubleshooting memory issues, concurrency defects, and complex logic in compiled codebases.

**Independent Test**: Launch a debug session on a compiled binary with debug symbols using a launch configuration targeting CodeLLDB. Verify that execution pauses at an active breakpoint and variable values can be inspected.

**Acceptance Scenarios**:

1. **Given** a native executable compiled with debug symbols, **When** launching a debug session via CodeLLDB, **Then** execution halts at configured breakpoints and displays call stacks and variable values.
2. **Given** an active debugging session halted at a breakpoint, **When** stepping over or stepping into instructions, **Then** execution advances and variable states update smoothly in the debug view.

---

### User Story 5 - Package Dependency Version Checking (Priority: P5)

As a developer managing project manifest files (such as Cargo.toml or package.json), I want inline dependency annotations and latest version information via Dependin so that I can easily identify outdated packages, security patches, and version upgrades.

**Why this priority**: Streamlines dependency maintenance and keeps packages secure and updated without requiring context switching to external web package registries.

**Independent Test**: Open a project manifest file declaring external dependencies. Verify that inline lens annotations appear indicating the current and latest available versions.

**Acceptance Scenarios**:

1. **Given** a supported dependency manifest file, **When** opened in the editor, **Then** Dependin displays the latest available package versions inline alongside declared dependencies.
2. **Given** an outdated dependency in a manifest file, **When** inspecting the version tooltip or action, **Then** available update versions and documentation/changelog links are accessible.

---

### Edge Cases

- **Missing Language Toolchains for Code Runner**: If a user attempts to run a file in a language whose compiler or interpreter is not installed on the system, Code Runner displays a clear error message in the terminal indicating that the executable is not found on PATH, rather than crashing or freezing the editor.
- **Offline / Rate-Limited Package Registries for Dependin**: When working offline or when upstream registries rate-limit requests, Dependin falls back to cached metadata or suppresses annotations cleanly without degrading editor responsiveness or blocking file editing.
- **Non-Standard Shell Dialects / Custom Directives in ShellCheck**: ShellCheck respects inline directive comments (`# shellcheck disable=...`, `# shellcheck shell=...`) and handles large scripts without causing editor UI lag.
- **Non-Standard Markdown Flavors & Embedded Code Blocks**: markdownlint accommodates embedded code blocks (e.g. Nix, Mermaid, JSON) and frontmatter headers without triggering false positive syntax errors.
- **Debug Target Lacking Debug Symbols**: When attempting to debug an optimized or stripped binary lacking DWARF/debug symbols with CodeLLDB, the debugger provides informative feedback indicating missing symbols while allowing disassembly/register inspection if supported.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide integrated shell script static analysis and linting (ShellCheck) within the user's editor configuration.
- **FR-002**: The system MUST install requisite background CLI binaries (such as `shellcheck`) in the user package environment (`modules/home-manager/_packages.nix`) so they are available out-of-the-box for both VS Code extensions and standalone terminal sessions.
- **FR-003**: The system MUST provide Markdown linting and style validation (markdownlint) for all markdown documents opened in the editor.
- **FR-004**: The system MUST provide multi-language code execution capabilities (Code Runner) configured to execute within the integrated terminal by default to support interactive stdin workflows and terminal styling.
- **FR-005**: The system MUST provide native LLDB-based debugging support (CodeLLDB) for compiled systems languages.
- **FR-006**: The system MUST ensure all necessary background helper binaries and debug adapter components required for CodeLLDB are provided and operational in the environment.
- **FR-007**: The system MUST provide dependency version visualization and update checks (Dependin) in supported package manifest files.
- **FR-008**: All specified extensions MUST be declared in the dedicated VS Code module (`modules/home-manager/vscode.nix`), with associated CLI tooling managed in the user packages module (`modules/home-manager/_packages.nix`).

### Key Entities

- **Editor Configuration Profile**: The declarative configuration state defining active extensions, runtime arguments, and settings for the user's IDE environment.
- **Static Linter Engine**: The background analyzer executable (e.g. ShellCheck) invoked by the editor to inspect source code against security, correctness, and style rules.
- **Debug Adapter**: The protocol adapter (CodeLLDB / LLDB) that interfaces between the editor's visual debugging UI and the running target process.
- **Dependency Inspector**: The extension service that parses manifest files and queries package registries for version metadata.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Inline diagnostic warnings appear on shell scripts with intentional syntax or style issues within 2 seconds of opening or editing the file.
- **SC-002**: Multi-language code snippets execute in the integrated terminal panel within 1 second of triggering the execution command.
- **SC-003**: Developers can trigger a native debug session and hit an active breakpoint in a compiled binary with zero manual configuration of external debugger paths.
- **SC-004**: Package manifests display package version annotations within 3 seconds of file load when online.
- **SC-005**: Markdown style errors and warnings are flagged in the editor immediately upon opening any non-conforming markdown file.
- **SC-006**: 100% of the specified extensions and underlying binaries are active and functional after applying the configuration, requiring zero manual imperative steps.

## Assumptions

- VS Code is used as the editor platform, configured declaratively via the user's Home Manager profile.
- The standard development host environment is Linux (x86_64-linux).
- Language-specific compilers and interpreters (e.g., `gcc`, `rustc`, `python3`, `node`) for executing specific languages via Code Runner are available in the user environment or per-project development shells (`nix develop` / `direnv`).
- Internet connectivity is available when Dependin queries public package registries.
