# Feature Specification: OpenCoder AI Assistant Integration alongside Aider

**Feature Branch**: `005-add-opencoder`

**Created**: 2026-08-13

**Status**: Ready

**Input**: User description: "Ajoute OpenCoder en plus d'Aider. Je n'ai pas encore décidé lequel utiliser. Configure OpenCoder pour qu'il utilise le même modèle Gemma 4 12B 8-bit servi par Ollama. Met à jour la spécification et va jusqu'à l'implémentation avec les étapes recommandées de Spec Kit."

## Clarifications

### Session 2026-08-13

- Q: How should OpenCoder be integrated into the system configuration alongside Aider? → A: Dedicated declarative Home Manager module (`modules/home-manager/opencode.nix`) providing `pkgs.opencode`, declarative configuration (`~/.config/opencode/config.json`), and importing it in `machines/desktop-pc/configuration.nix` in parallel to `aider.nix`.
- Q: How should OpenCoder connect to the local Ollama Gemma 4 12B 8-bit model? → A: Configured with local OpenAI-compatible endpoint (`http://127.0.0.1:11434/v1`) using `@ai-sdk/openai` provider targeting `ollama/gemma4:12b` with matching 8k context window limits (`context: 8192`, `output: 8192`).
- Q: How should the user invoke OpenCoder conveniently? → A: Direct CLI execution via `opencode` in terminal plus a `just opencode` recipe in `justfile` mirroring the existing `just aider` workflow.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Declarative OpenCoder CLI Installation & Local Gemma 4 Model Integration (Priority: P1)

A developer on the desktop workstation needs OpenCoder (`opencode`) available in their terminal environment through declarative configuration. OpenCoder must be pre-configured to communicate seamlessly with the local Ollama instance running the 8-bit quantized Gemma 4 12B model (`gemma4:12b`) via the local HTTP endpoint (`http://127.0.0.1:11434/v1`) with an 8,192 token context window.

**Why this priority**: Core functionality. Without a properly packaged and pre-configured OpenCoder CLI pointing to the local hardware-accelerated model, the developer cannot test or evaluate OpenCoder as an alternative pair-programming assistant.

**Independent Test**: On `desktop-pc`, verify `opencode` is available in PATH, launch `opencode run "hello"` (or interactive TUI), and verify it connects directly to local Ollama, queries `gemma4:12b`, and receives a coherent local completion without external cloud calls.

**Acceptance Scenarios**:

1. **Given** a user terminal session on the desktop workstation, **When** invoking `opencode`, **Then** the binary is executable from the standard user PATH.
2. **Given** OpenCoder is launched, **When** it initializes, **Then** it reads the declarative configuration file (`~/.config/opencode/config.json`) with `ollama/gemma4:12b` as the active model and `http://127.0.0.1:11434/v1` as the local provider endpoint.
3. **Given** a prompt is submitted to OpenCoder, **When** inference executes, **Then** responses stream directly from the local Ollama service using GPU hardware acceleration.

---

### User Story 2 - Coexistence and Tool Switching between Aider and OpenCoder (Priority: P1)

A developer evaluates both Aider and OpenCoder concurrently on the workstation to compare their ergonomics, multi-file code editing abilities, tool calling, and TUI workflows without either tool interfering with the other's configuration, environment, or access to the local Ollama inference service.

**Why this priority**: Critical requirement. The user explicitly stated they have not yet decided between Aider and OpenCoder; both tools must coexist cleanly in the same user profile without conflicting settings or mutual exclusion.

**Independent Test**: Launch Aider in one terminal session and OpenCoder in another terminal session against the same local repository, verifying both operate normally and connect to the shared local Ollama service.

**Acceptance Scenarios**:

1. **Given** the desktop configuration, **When** both `aider.nix` and `opencode.nix` are imported in `machines/desktop-pc/configuration.nix`, **Then** both CLI binaries (`aider` and `opencode`) are installed and simultaneously accessible.
2. **Given** both tools are installed, **When** checking configuration files, **Then** Aider's config (`~/.aider.conf.yml`) and OpenCoder's config (`~/.config/opencode/config.json`) reside in distinct paths without namespace collisions.
3. **Given** both tools query the local Ollama server, **When** inference requests are made, **Then** Ollama serves both clients cleanly using the same loaded `gemma4:12b` model.

---

### User Story 3 - Context-Aware Offline AI Pair-Programming with OpenCoder (Priority: P2)

A developer uses OpenCoder in an isolated or offline terminal session to inspect repository files, review diffs, execute terminal commands, and perform iterative refactorings within the 8,192 token context budget.

**Why this priority**: Developer productivity and privacy. OpenCoder must function reliably offline within the local context limit of the 8-bit Gemma 4 12B model.

**Independent Test**: Run OpenCoder inside a git repository without internet access, prompt it to refactor a local code snippet, and verify it inspects files, generates valid diffs, and applies changes accurately.

**Acceptance Scenarios**:

1. **Given** an offline workspace, **When** OpenCoder is prompted to read and edit project files, **Then** it operates purely on local filesystem context and local model inference without outbound internet requests.
2. **Given** a multi-step coding task, **When** the developer reviews generated changes, **Then** OpenCoder presents formatted diffs and requests user confirmation prior to modifying disk state.

---

### User Story 4 - Operational Task Runner Recipes & Developer Ergonomics (Priority: P3)

The developer needs consistent command-line shortcuts via `justfile` to launch OpenCoder with local defaults, matching the ergonomics already established for Aider.

**Why this priority**: Ergonomic parity and usability. Standardizing commands in `justfile` simplifies onboarding and routine usage.

**Independent Test**: Run `just opencode` from the project repository root and verify it launches an interactive OpenCoder session configured with the local Gemma 4 model.

**Acceptance Scenarios**:

1. **Given** the repository root, **When** the user runs `just opencode`, **Then** the task runner executes `opencode` in the current working directory.
2. **Given** optional arguments provided via `just opencode args="..."`, **When** executed, **Then** the arguments are forwarded to the underlying CLI invocation.

---

### Edge Cases

- What happens if the local Ollama service is stopped or unreachable? OpenCoder displays a clear connection error pointing to `127.0.0.1:11434` without attempting unauthorized cloud API calls.
- What happens if the `gemma4:12b` model is not yet pulled in Ollama? The local service returns a model not found error, and the user can run `just download-model` to fetch it.
- What happens when large prompt context exceeds the 8,192 token limit? OpenCoder truncates or compacts previous turns gracefully according to the configured context limit.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide the OpenCoder CLI tool (`opencode`) in the user environment on `desktop-pc` via declarative Home Manager configuration (`modules/home-manager/opencode.nix`).
- **FR-002**: System MUST configure OpenCoder to target the local Ollama OpenAI-compatible API endpoint (`http://127.0.0.1:11434/v1`) using the 8-bit quantized `gemma4:12b` model.
- **FR-003**: System MUST configure OpenCoder context window boundaries matching the local model allocation (8,192 input tokens, 8,192 output tokens).
- **FR-004**: System MUST install and configure OpenCoder alongside Aider without replacing, disabling, or mutating existing Aider configuration.
- **FR-005**: System MUST manage OpenCoder user configuration declaratively via `~/.config/opencode/config.json` (or Home Manager XDG configuration).
- **FR-006**: System MUST provide a `just opencode` task runner recipe in `justfile` for launching interactive sessions.
- **FR-007**: System configuration MUST pass all flake integrity checks (`nix flake check` / `just check`), formatting (`nix fmt`), and linter validations (`statix`, `deadnix`) with zero errors.

### Key Entities

- **OpenCoder Configuration (`~/.config/opencode/config.json`)**: Declarative JSON file defining the active model (`ollama/gemma4:12b`), provider endpoint (`http://127.0.0.1:11434/v1`), model context limits (8,192 tokens), and agent options.
- **Ollama Provider Specification**: Endpoint definition mapping the local Ollama server to an OpenAI-compatible interface consumed by OpenCoder.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developer can launch OpenCoder from any terminal on `desktop-pc` in under 2 seconds.
- **SC-002**: 100% of OpenCoder queries are routed locally to the Ollama `gemma4:12b` instance with zero outbound internet network requests during inference.
- **SC-003**: Developer can switch seamlessly between `aider` and `opencode` in subsequent terminal commands with zero configuration changes or restart procedures.
- **SC-004**: 100% pass rate on repository static analysis, formatting, and flake checks (`just check`).

## Assumptions

- The host machine (`desktop-pc`) has the Ollama service configured and GPU acceleration enabled via `modules/nixos/ollama.nix` and `modules/nixos/nvidia.nix`.
- The `gemma4:12b` model is downloaded or can be pulled via `just download-model`.
- OpenCoder is packaged as `pkgs.opencode` in `nixpkgs-unstable`.
- Both Aider and OpenCoder operate as standalone CLI tools without shared runtime state.
