# Feature Specification: Local Gemma 4 Model Acceleration & Aider CLI Integration

**Feature Branch**: `004-local-gemma-antigravity`

**Created**: 2026-08-12 | **Updated**: 2026-08-13

**Status**: Ready

**Input**: User description: "I want to leverage the 32 GB of RAM and the NVIDIA GeForce RTX 5070 Ti with 16 GB of RAM on the `desktop` machine, with a modern local AI pair-programming TUI CLI (Aider) and an 8-bit quantized Gemma 4 12B model served via Ollama with CUDA acceleration and an 8,192 (8k) context window."

## Clarifications

### Session 2026-08-12

- Q: Which local inference backend should serve the Gemma 4 12B model on the desktop workstation? → A: Ollama with CUDA acceleration (`services.ollama`) providing a native NixOS system service and OpenAI-compatible API endpoint (Option A).
- Q: Which model quantization precision profile should be targeted for running Gemma 4 12B on the 16 GB RTX 5070 Ti? → A: 8-bit quantization (`q8_0`) targeting ~13–14 GB VRAM footprint for near-FP16 fidelity while fully fitting within the 16 GB GPU VRAM (Option B).
- Q: How should the Gemma 4 12B model weights be initialized and pulled onto the workstation? → A: Operational recipe on demand via task runner (`just download-model` / CLI) — the system service starts empty and the user triggers model downloads when ready (Option B).

### Session 2026-08-13

- Q: Which AI pair-programming CLI / TUI tool should replace Antigravity CLI for local third-party model support? → A: Aider (`aider-chat`), which provides first-class native Ollama support, rich interactive TUI, git repository mapping, multi-file editing, and full offline operation (Option A).
- Q: How should Aider CLI configuration and local Ollama endpoint defaults be provisioned in the user environment? → A: Dedicated declarative Home Manager module (`modules/home-manager/aider.nix`) providing `pkgs.aider-chat`, declarative configuration file (`~/.aider.conf.yml`), and environment variables (`OLLAMA_API_BASE=http://127.0.0.1:11434`) (Option A).
- Q: What context window size should be configured for the 8-bit Gemma 4 12B model on the 16 GB RTX 5070 Ti? → A: 8,192 tokens (8k), budgeting ~12.5–13.0 GB for model weights, ~1.2–1.5 GB for the KV cache, and reserving ~1.5–2.0 GB of VRAM for desktop compositing and graphical applications (Option A).
- Q: How should the user conveniently launch Aider with local model defaults? → A: Declarative user configuration in Home Manager plus a convenient `just aider` recipe in `justfile` for running interactive sessions directly in project directories (Option A).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Local Hardware-Accelerated Model Inference (Priority: P1)

A developer working on the desktop workstation needs a local large language model inference service (Ollama with CUDA) capable of running an 8-bit quantized Gemma 4 12B model (`q8_0`) with an 8k context window (8,192 tokens) entirely offline. The service must start quickly without blocking system rebuilds, allow on-demand model acquisition via task runner (`just download-model`), and fully utilize the NVIDIA GeForce RTX 5070 Ti (16 GB VRAM) and system RAM (32 GB) to achieve near-FP16 precision, fast token generation, and minimal response latency without sending any private code or prompts across external networks.

**Why this priority**: Foundational requirement. Without a functioning, GPU-accelerated local model execution environment on the workstation, downstream developer tools and coding assistants cannot function offline.

**Independent Test**: Start the local Ollama service on the desktop workstation, pull the model via `just download-model`, issue a prompt via the local inference interface, and verify that the 8-bit Gemma 4 12B model generates coherent responses with 8k context support while actively utilizing dedicated GPU VRAM (~14–15 GB total including KV cache) and processing the workload with low latency.

**Acceptance Scenarios**:

1. **Given** the desktop workstation is running with an NVIDIA GeForce RTX 5070 Ti GPU, **When** the local Ollama service starts, **Then** it starts immediately without blocking system build or activation on heavy model downloads.
2. **Given** the Ollama service is active, **When** the user runs `just download-model model="gemma4:12b"`, **Then** the model weights are retrieved and stored into persistent storage (`/var/lib/ollama/models`).
3. **Given** the local model is loaded, **When** a user or client application submits a prompt within the 8,192 token context window, **Then** the model streams generated responses locally with zero outbound network traffic and 100% GPU offload.
4. **Given** the workstation is disconnected from the internet, **When** inference requests are submitted for a downloaded model, **Then** the local model continues to generate completions without degradation or external connectivity errors.

---

### User Story 2 - Aider TUI CLI Local AI Pair-Programming (Priority: P1)

A developer needs Aider (`aider-chat`) available in their terminal environment via a declarative Home Manager module, pre-configured to communicate seamlessly with the local Ollama Gemma 4 12B model endpoint (`ollama/gemma4:12b` via `http://127.0.0.1:11434`) using an 8,192 token context window. The developer can invoke agentic multi-file code editing, git-aware commits, repository mapping, and interactive pair programming directly from their terminal with a rich TUI experience.

**Why this priority**: Core developer-facing interface. Aider provides an interactive, terminal-native pair-programming workflow with full offline third-party model support.

**Independent Test**: Open a terminal session on the desktop machine, launch `aider` (or `just aider`), prompt the assistant to inspect or edit local files, and verify that it connects directly to the local Ollama Gemma 4 12B model with 8k context, executes code changes, and renders formatted diffs in the terminal.

**Acceptance Scenarios**:

1. **Given** a user terminal session on the desktop workstation, **When** invoking `aider`, **Then** the `aider-chat` binary is immediately executable from the standard user PATH via Home Manager.
2. **Given** Aider is executed with a coding or explanation prompt, **When** it dispatches the request, **Then** it automatically routes the request to the local Ollama Gemma 4 12B model (`ollama/gemma4:12b` at `http://127.0.0.1:11434`).
3. **Given** an interactive or multi-turn coding session in Aider, **When** contextual code files (up to the 8k context budget) are added and instructions provided, **Then** the local model processes the repository context, generates diffs, and streams responses back to the TUI in real time.
4. **Given** the local Ollama service is temporarily unreachable or the model is not yet downloaded, **When** Aider is invoked, **Then** it presents a clear, actionable diagnostic error explaining the local service status rather than failing silently or attempting unauthorized cloud fallbacks.

---

### User Story 3 - Workstation Memory Budgeting & System Responsiveness (Priority: P2)

The local Ollama runtime and KV cache must operate within designated resource boundaries on the desktop workstation (16 GB dedicated GPU VRAM, 32 GB system RAM) so that concurrent graphical user interface operations, code editors, web browsers, and desktop multitasking remain smooth and unhindered during active 8k token inference.

**Why this priority**: Prevents resource starvation and system freezes. Budgeting 12.5–13.0 GB for model weights and 1.2–1.5 GB for 8k KV cache leaves ~1.5–2.0 GB VRAM and substantial system RAM (32 GB) to maintain desktop compositor fluidness.

**Independent Test**: Initiate a sustained heavy 8k inference task while running a graphical desktop session with active applications (browser, text editor, terminal) and verify that the desktop remains responsive with zero application crashes or display driver resets.

**Acceptance Scenarios**:

1. **Given** the desktop workstation with 16 GB VRAM and 32 GB RAM running graphical applications, **When** loading the 8-bit Gemma 4 12B model with 8k context, **Then** VRAM allocation is managed to leave sufficient display memory (~1.5–2.0 GB VRAM) for desktop compositing and graphical windows.
2. **Given** active continuous inference generating long completions, **When** the user interacts with graphical windows and switches tasks, **Then** user input (typing, window movement, cursor tracking) remains fluid without stutter or desktop lockups.
3. **Given** large prompt context windows that exceed dedicated VRAM margins, **When** memory spills over, **Then** system RAM (32 GB) handles the overflow gracefully without triggering out-of-memory kernel termination.

---

### User Story 4 - Model Diagnostics & Resource Monitoring (Priority: P3)

The system operator needs clear visibility into the status of the local model runtime, GPU compute utilization, VRAM allocation (weights + KV cache), and CLI connectivity to easily verify system health and diagnose performance bottlenecks.

**Why this priority**: Operational transparency and maintainability. Allows the user to quickly confirm that hardware acceleration is active and verify system resource headroom.

**Independent Test**: Run system monitoring and health check commands on the desktop workstation to inspect GPU utilization, VRAM allocation, model loading state, and client connection health.

**Acceptance Scenarios**:

1. **Given** the local Ollama service is active, **When** the operator checks GPU status, **Then** dedicated VRAM usage (~14–15 GB) and GPU compute utilization reflect the active model workload.
2. **Given** the developer environment, **When** running a diagnostic or health check, **Then** the system reports model readiness, model version (Gemma 4 12B q8_0), context window capacity (8,192 tokens), and CLI client endpoint reachability.

---

### Edge Cases

- What happens when available VRAM is partially occupied by other graphical applications? The Ollama runtime dynamically manages layer offloading between the 16 GB VRAM and 32 GB system RAM so the model loads without crashing the display server.
- What happens when network connectivity is lost completely? Both the Ollama inference service and Aider CLI operate 100% locally with zero cloud dependencies, ensuring continuous offline productivity.
- What happens when multiple concurrent CLI or client requests are submitted to the local model? The inference service queues or serializes concurrent requests cleanly without memory leaks or process crashes.
- What happens if the model weights are not yet downloaded? The system alerts the operator with clear diagnostic messages detailing how to pull the model on demand (`just download-model`).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a declarative local Ollama inference service (`services.ollama` via a modular NixOS module `modules/nixos/ollama.nix`) on the `desktop` (`desktop-pc`) machine profile.
- **FR-002**: The inference service MUST serve the 8-bit quantized (`q8_0`) local Gemma 4 12B model downloaded on demand via operational tooling.
- **FR-003**: The inference service MUST leverage NVIDIA GPU hardware acceleration (CUDA), offloading model computation to the 16 GB VRAM of the NVIDIA GeForce RTX 5070 Ti.
- **FR-004**: The system MUST allocate and balance memory usage across the 16 GB VRAM (~12.5–13.0 GB model footprint + ~1.2–1.5 GB 8k KV cache) and 32 GB system RAM to ensure the graphical desktop environment remains responsive during active inference.
- **FR-005**: The system MUST provide Aider (`pkgs.aider-chat`) installed in the user's environment on the desktop workstation via a dedicated Home Manager module (`modules/home-manager/aider.nix`).
- **FR-006**: Aider MUST be pre-configured by Home Manager to communicate by default with the local Ollama Gemma 4 12B model (`ollama/gemma4:12b` at `http://127.0.0.1:11434`) via declarative configuration (`~/.aider.conf.yml`) and environment variables (`OLLAMA_API_BASE=http://127.0.0.1:11434`).
- **FR-007**: The local inference workflow and Aider CLI MUST operate entirely offline with zero outbound network calls for model inference or code completion.
- **FR-008**: The system MUST provide diagnostic capabilities to inspect model service health, GPU/VRAM utilization, and CLI connectivity.
- **FR-009**: The local model configuration, inference service, and user CLI tooling MUST be declared hermetically and reproducibly within the repository's modular NixOS and Home Manager architecture.
- **FR-010**: System updates and generation switches MUST start the service cleanly and preserve persistent model weight assets in `/var/lib/ollama/models` without downloading large blobs during build or activation.
- **FR-011**: The system MUST provide an on-demand task runner recipe (`just download-model`) to pull model weights without requiring declarative rebuilds.
- **FR-012**: The system MUST provide a convenient task runner recipe (`just aider`) in `justfile` to launch interactive local pair-programming sessions.
- **FR-013**: The system MUST target an 8,192 (8k) token context window size for local pair-programming sessions to maximize context capability while guaranteeing 100% GPU residency on the 16 GB VRAM GPU.

### Key Entities

- **Ollama Inference Service**: The background system service responsible for loading model weights into GPU VRAM and serving inference requests over a local communication socket or loopback interface (`http://127.0.0.1:11434`).
- **Gemma 4 12B Model Asset**: The locally stored 8-bit quantized (`q8_0`) model weights and parameters downloaded on demand into `/var/lib/ollama/models`.
- **Aider CLI Client**: The terminal-based developer pair-programming tool (`aider-chat`) configured via Home Manager to interact with the local model for multi-file code editing, git commits, and interactive queries.
- **Hardware Resource Budget**: The physical compute profile (GeForce RTX 5070 Ti with 16 GB VRAM and 32 GB system RAM) governing execution boundaries (8k context window, ~14–15 GB VRAM peak).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Aider CLI successfully dispatches prompts to and receives completed code edits/responses from the local 8-bit Gemma 4 12B model with 8k context window via Ollama with 100% local processing.
- **SC-002**: Token generation begins streaming within 2 seconds of prompt submission on the desktop workstation under normal operating conditions.
- **SC-003**: 100% of model inference requests, code context transfers, and completions occur locally without transmitting data over external networks.
- **SC-004**: The desktop graphical environment maintains smooth interactivity (no desktop freezes or compositor crashes) during sustained continuous 8k model inference.
- **SC-005**: System rebuilds and profile switches complete rapidly without waiting on multi-gigabyte model downloads during Nix activation.

## Assumptions

- The target workstation is the `desktop-pc` profile with an NVIDIA GeForce RTX 5070 Ti (16 GB VRAM) and 32 GB of system RAM.
- GPU drivers and graphics subsystems on `desktop-pc` are managed via the existing declarative NVIDIA module (`modules/nixos/nvidia.nix`).
- The Gemma 4 12B model weights are stored in a persistent local directory on the host filesystem (`/var/lib/ollama/models`) and are not wiped during system generation rollbacks or switches.
- Aider CLI natively supports connecting to Ollama via model identifier `ollama/gemma4:12b` and environment variable `OLLAMA_API_BASE=http://127.0.0.1:11434`.
- Local inference service enablement is scoped specifically to the `desktop-pc` profile and omitted from headless server (`homelab`) and installer (`iso`) profiles.
