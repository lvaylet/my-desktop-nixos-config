# Feature Specification: Local Gemma 4 Model Acceleration & Antigravity CLI Integration

**Feature Branch**: `004-local-gemma-antigravity`

**Created**: 2026-08-12

**Status**: Draft

**Input**: User description: "I want to leverage the 32 GB of RAM and the nvidia GeForce RTX 5070 Ti with 16 GB of RAM on the `desktop` machine, with the latest version of Antigravity CLI and a local Gemma 4 12B model."

## Clarifications

### Session 2026-08-12

- Q: Which local inference backend should serve the Gemma 4 12B model on the desktop workstation? → A: Ollama with CUDA acceleration (`services.ollama`) providing a native NixOS system service and OpenAI-compatible API endpoint (Option A).
- Q: Which model quantization precision profile should be targeted for running Gemma 4 12B on the 16 GB RTX 5070 Ti? → A: 8-bit quantization (`q8_0`) targeting ~13–14 GB VRAM footprint for near-FP16 fidelity while fully fitting within the 16 GB GPU VRAM (Option B).
- Q: How should the Antigravity CLI configuration and its default local model endpoint be provisioned in the user environment? → A: Dedicated declarative Home Manager module (`modules/home-manager/antigravity.nix`) configuring the CLI package, local model endpoint, and default runtime settings (Option A).
- Q: How should the Gemma 4 12B model weights be initialized and pulled onto the workstation? → A: Declarative service loading via `services.ollama.loadModels` ensuring automatic download and preparation on service activation (Option A).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Local Hardware-Accelerated Model Inference (Priority: P1)

A developer working on the desktop workstation needs a local large language model inference service (Ollama with CUDA) capable of running an 8-bit quantized Gemma 4 12B model (`q8_0`) entirely offline. The service must automatically load the model on activation and fully utilize the NVIDIA GeForce RTX 5070 Ti (16 GB VRAM) and system RAM (32 GB) to achieve near-FP16 precision, fast token generation, and minimal response latency without sending any private code or prompts across external networks.

**Why this priority**: Foundational requirement. Without a functioning, GPU-accelerated local model execution environment on the workstation, downstream developer tools and coding assistants cannot function offline.

**Independent Test**: Start the local Ollama service on the desktop workstation, issue a prompt via the local inference interface, and verify that the 8-bit Gemma 4 12B model generates coherent responses while actively utilizing dedicated GPU VRAM (~13–14 GB) and processing the workload with low latency.

**Acceptance Scenarios**:

1. **Given** the desktop workstation is running with an NVIDIA GeForce RTX 5070 Ti GPU, **When** the local Ollama service starts, **Then** the 8-bit Gemma 4 12B model (`q8_0`) is automatically loaded via `loadModels` into memory with model layers offloaded to the GPU's 16 GB VRAM for accelerated computation via CUDA.
2. **Given** the local model is loaded and ready, **When** a user or client application submits a prompt, **Then** the model streams generated responses locally with zero outbound network traffic.
3. **Given** the workstation is disconnected from the internet, **When** inference requests are submitted, **Then** the local model continues to generate completions without degradation or external connectivity errors.
4. **Given** the local inference service is enabled, **When** the workstation boots or user logs in, **Then** the Ollama service starts reliably in the background without requiring manual terminal startup commands.

---

### User Story 2 - Antigravity CLI Local AI Pair-Programming (Priority: P1)

A developer needs the latest version of Antigravity CLI available in their terminal environment via a declarative Home Manager module, pre-configured to communicate seamlessly with the local Ollama Gemma 4 12B model endpoint. The developer can invoke agentic code generation, context analysis, and pair programming directly from their workstation command line without manual endpoint configuration.

**Why this priority**: Core developer-facing interface. Antigravity CLI provides the primary interactive workflow for AI-assisted programming using the local model.

**Independent Test**: Open a terminal session on the desktop machine, run the Antigravity CLI with a coding query, and verify that it connects directly to the local Ollama Gemma 4 12B model endpoint, executes the request, and displays the response in the terminal.

**Acceptance Scenarios**:

1. **Given** a user terminal session on the desktop workstation, **When** invoking the Antigravity CLI, **Then** the latest binary is immediately executable from the standard user PATH via Home Manager.
2. **Given** Antigravity CLI is executed with a coding or explanation prompt, **When** it dispatches the request, **Then** it automatically routes the request to the local Ollama Gemma 4 12B model service.
3. **Given** an interactive or multi-turn coding session in Antigravity CLI, **When** contextual code snippets and instructions are provided, **Then** the local model processes the context and streams responses back to the CLI in real time.
4. **Given** the local Ollama service is temporarily unreachable, **When** Antigravity CLI is invoked, **Then** it presents a clear, actionable diagnostic error explaining the local service status rather than failing silently or attempting unauthorized cloud fallbacks.

---

### User Story 3 - Workstation Memory Budgeting & System Responsiveness (Priority: P2)

The local Ollama runtime must operate within designated resource boundaries on the desktop workstation (16 GB dedicated GPU VRAM, 32 GB system RAM) so that concurrent graphical user interface operations, code editors, web browsers, and desktop multitasking remain smooth and unhindered during active model inference.

**Why this priority**: Prevents resource starvation and system freezes. Running an 8-bit 12B model (~13–14 GB VRAM) leaves ~2–3 GB VRAM and substantial system RAM (32 GB) to maintain desktop compositor fluidness.

**Independent Test**: Initiate a sustained heavy inference task while running a graphical desktop session with active applications (browser, text editor, terminal) and verify that the desktop remains responsive with zero application crashes or display driver resets.

**Acceptance Scenarios**:

1. **Given** the desktop workstation with 16 GB VRAM and 32 GB RAM running graphical applications, **When** loading the 8-bit Gemma 4 12B model, **Then** VRAM allocation is managed to leave sufficient display memory (~2–3 GB VRAM) for desktop compositing and graphical windows.
2. **Given** active continuous inference generating long completions, **When** the user interacts with graphical windows and switches tasks, **Then** user input (typing, window movement, cursor tracking) remains fluid without stutter or desktop lockups.
3. **Given** large prompt context windows that exceed dedicated VRAM margins, **When** memory spills over, **Then** system RAM (32 GB) handles the overflow gracefully without triggering out-of-memory kernel termination.

---

### User Story 4 - Model Diagnostics & Resource Monitoring (Priority: P3)

The system operator needs clear visibility into the status of the local model runtime, GPU compute utilization, VRAM allocation, and CLI connectivity to easily verify system health and diagnose performance bottlenecks.

**Why this priority**: Operational transparency and maintainability. Allows the user to quickly confirm that hardware acceleration is active and verify system resource headroom.

**Independent Test**: Run system monitoring and health check commands on the desktop workstation to inspect GPU utilization, VRAM allocation, model loading state, and client connection health.

**Acceptance Scenarios**:

1. **Given** the local Ollama service is active, **When** the operator checks GPU status, **Then** dedicated VRAM usage (~13–14 GB) and GPU compute utilization reflect the active model workload.
2. **Given** the developer environment, **When** running a diagnostic or health check, **Then** the system reports model readiness, model version (Gemma 4 12B q8_0), and CLI client endpoint reachability.

---

### Edge Cases

- What happens when available VRAM is partially occupied by other graphical applications? The Ollama runtime dynamically manages layer offloading between the 16 GB VRAM and 32 GB system RAM so the model loads without crashing the display server.
- What happens when network connectivity is lost completely? Both the Ollama inference service and Antigravity CLI operate 100% locally with zero cloud dependencies, ensuring continuous offline productivity.
- What happens when multiple concurrent CLI or client requests are submitted to the local model? The inference service queues or serializes concurrent requests cleanly without memory leaks or process crashes.
- What happens if the model weights are not present or corrupted on first initialization? The system alerts the operator with clear diagnostic messages detailing the missing model asset and steps to populate it.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a declarative local Ollama inference service (`services.ollama` via a modular NixOS module `modules/nixos/ollama.nix`) on the `desktop` (`desktop-pc`) machine profile.
- **FR-002**: The inference service MUST declaratively load and serve the 8-bit quantized (`q8_0`) local Gemma 4 12B model on startup via `services.ollama.loadModels`.
- **FR-003**: The inference service MUST leverage NVIDIA GPU hardware acceleration (CUDA), offloading model computation to the 16 GB VRAM of the NVIDIA GeForce RTX 5070 Ti.
- **FR-004**: The system MUST allocate and balance memory usage across the 16 GB VRAM (~13–14 GB model footprint) and 32 GB system RAM to ensure the graphical desktop environment remains responsive during active inference.
- **FR-005**: The system MUST provide the latest version of Antigravity CLI installed in the user's environment on the desktop workstation via a dedicated Home Manager module (`modules/home-manager/antigravity.nix`).
- **FR-006**: Antigravity CLI MUST be pre-configured by Home Manager to communicate by default with the local Ollama Gemma 4 12B model service endpoint (OpenAI-compatible API format at `http://127.0.0.1:11434/v1`).
- **FR-007**: The local inference workflow and Antigravity CLI MUST operate entirely offline with zero outbound network calls for model inference or code completion.
- **FR-008**: The system MUST provide diagnostic capabilities to inspect model service health, GPU/VRAM utilization, and CLI connectivity.
- **FR-009**: The local model configuration, inference service, and user CLI tooling MUST be declared hermetically and reproducibly within the repository's modular NixOS and Home Manager architecture.
- **FR-010**: System updates and generation switches MUST preserve persistent model weight assets without requiring re-downloading across rebuilds.

### Key Entities

- **Ollama Inference Service**: The background system service responsible for loading model weights into GPU VRAM and serving inference requests over a local communication socket or loopback interface (`http://127.0.0.1:11434`).
- **Gemma 4 12B Model Asset**: The locally stored 8-bit quantized (`q8_0`) model weights and parameters declared for automatic loading via `services.ollama.loadModels`.
- **Antigravity CLI Client**: The terminal-based developer assistance tool configured via Home Manager to interact with the local model for code generation, agentic tasks, and query resolution.
- **Hardware Resource Budget**: The physical compute profile (GeForce RTX 5070 Ti with 16 GB VRAM and 32 GB system RAM) governing execution boundaries and performance tuning.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Antigravity CLI successfully dispatches prompts to and receives completed responses from the local 8-bit Gemma 4 12B model via Ollama with 100% local processing.
- **SC-002**: Token generation begins streaming within 2 seconds of prompt submission on the desktop workstation under normal operating conditions.
- **SC-003**: 100% of model inference requests, code context transfers, and completions occur locally without transmitting data over external networks.
- **SC-004**: The desktop graphical environment maintains smooth interactivity (no desktop freezes or compositor crashes) during sustained continuous model inference.
- **SC-005**: The entire local model inference and Antigravity CLI configuration evaluates and builds cleanly through standard declarative system configuration commands.

## Assumptions

- The target workstation is the `desktop-pc` profile with an NVIDIA GeForce RTX 5070 Ti (16 GB VRAM) and 32 GB of system RAM.
- GPU drivers and graphics subsystems on `desktop-pc` are managed via the existing declarative NVIDIA module (`modules/nixos/nvidia.nix`).
- The Gemma 4 12B model weights are stored in a persistent local directory on the host filesystem (`/var/lib/ollama/models`) and are not wiped during system generation rollbacks or switches.
- Antigravity CLI supports connecting to standard local API endpoints (such as Ollama's OpenAI-compatible endpoint).
- Local inference service enablement is scoped specifically to the `desktop-pc` profile and omitted from headless server (`homelab`) and installer (`iso`) profiles.
