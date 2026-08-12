# Research & Architectural Decisions: Local Gemma 4 Model Acceleration & Antigravity CLI Integration

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Spec**: [spec.md](spec.md)

## Decision 1: Local Inference Engine & Service Architecture

### Decision
Implement the local inference runtime using NixOS native `services.ollama` with explicit CUDA hardware acceleration (`acceleration = "cuda"`) in a dedicated modular file `modules/nixos/ollama.nix`, imported directly by `machines/desktop-pc/configuration.nix`.

### Rationale
- **Native NixOS Module**: NixOS provides upstream support for `services.ollama` with out-of-the-box systemd daemon management, log rotation, and dynamic library linking against NVIDIA CUDA drivers.
- **OpenAI-Compatible API Interface**: Ollama serves an OpenAI-compatible API endpoint on loopback (`http://127.0.0.1:11434/v1`) in addition to its native API, allowing Antigravity CLI and standard developer tooling to interface with local models without custom adapter proxies.
- **Dynamic Model Management & Layer Offloading**: Ollama automatically detects NVIDIA compute capabilities (Compute Capability 12.x on Blackwell / RTX 5070 Ti) and offloads 100% of transformer layers to GPU VRAM while maintaining graceful CPU/system RAM overflow protection.
- **Local Isolation**: Binds by default to `127.0.0.1:11434`, ensuring that the service is never exposed to external LAN interfaces without intentional firewall modification.

### Alternatives Considered
- *llama.cpp server (`llama-cpp`)*: Lightweight and performant, but requires writing custom systemd service units, manual GGUF file management, and manual endpoint proxy configuration in NixOS.
- *vLLM*: Excellent for high-concurrency batching, but has heavy Python/Torch closure dependencies, high build times in Nix, and high idle VRAM consumption that hinders everyday desktop application usage.
- *LocalAI*: Heavier multi-backend wrapper with unnecessary complexity for a dedicated single-workstation local model workflow.

---

## Decision 2: Model Quantization & Memory Budgeting on RTX 5070 Ti

### Decision
Target 8-bit quantized Gemma 4 12B (`gemma4:12b` / `q8_0`) utilizing ~13–14 GB VRAM on the NVIDIA GeForce RTX 5070 Ti (16 GB dedicated VRAM), reserving ~2–3 GB VRAM and 32 GB system RAM for the Wayland/X11 desktop compositor, browsers, and application buffers.

### Rationale
- **Near-FP16 Precision**: 8-bit quantization (`q8_0`) retains >99% of original unquantized model reasoning and code synthesis capability, avoiding degradation in complex multi-turn coding tasks.
- **100% GPU Layer Offload**: With an active weight footprint of ~13–14 GB, all transformer attention and feed-forward layers fit entirely within the 16 GB physical VRAM of the RTX 5070 Ti, maximizing token generation throughput and minimizing time-to-first-token.
- **Desktop Interactivity Buffer**: Retaining ~2–3 GB of unallocated VRAM prevents display server stutter, OpenGL/Vulkan compositor frame drops, and browser GPU acceleration crashes during active model inference.
- **System Memory Headroom**: The host's 32 GB of system RAM provides ample buffer for operating system processes, language servers, build tasks, and extended context window allocations.

### Alternatives Considered
- *Unquantized FP16 (16-bit)*: Requires ~24 GB of VRAM. Would force ~8 GB of model weights into system RAM across PCIe bus, drastically reducing generation speed from ~40+ tokens/sec to <5 tokens/sec.
- *4-bit Quantization (`q4_k_m`)*: Requires only ~7.5–8 GB VRAM with fast execution, but exhibits minor quality loss in nuanced syntax generation compared to 8-bit.

---

## Decision 3: Antigravity CLI Provisioning & Configuration

### Decision
Create a dedicated Home Manager module `modules/home-manager/antigravity.nix` imported by the desktop user profile, which installs the latest Antigravity CLI package and declaratively exports default environment variables pointing to the local Ollama service (`ANTIGRAVITY_API_BASE=http://127.0.0.1:11434/v1` and `ANTIGRAVITY_MODEL=gemma4:12b`).

### Rationale
- **Hermetic User Tooling**: Adheres to Principle II (Modular Separation of Concerns) by keeping user developer utilities inside Home Manager while keeping systemd daemons in NixOS system modules.
- **Zero-Config Developer Experience**: When the user opens Ghostty, VS Code terminal, or standard shell, the environment variables and CLI binary are pre-configured in their PATH with zero manual configuration steps.
- **Offline & Private by Default**: Configured to direct all completion traffic to the loopback interface, completely eliminating accidental cloud telemetry or third-party credential dependencies.

### Alternatives Considered
- *Imperative user installation (`curl | sh` or npm global)*: Violates Principle I (Declarative & Hermetic Configuration) and causes environment drift across machine reinstalls.
- *System-wide package in `_packages.nix` without environment defaults*: Requires the user to manually pass CLI flags (`--endpoint http://localhost:11434`) on every command execution.

---

## Decision 4: Declarative Model Pre-Loading & Persistent Storage

### Decision
Configure `services.ollama.loadModels = [ "gemma4:12b" ];` within `modules/nixos/ollama.nix` with persistent model weight storage located at `/var/lib/ollama/models`.

### Rationale
- **Declarative System State**: Using `loadModels` instructs the NixOS activation and systemd service to ensure that the specified model tag is downloaded, validated, and ready in the local model store on service startup.
- **Persistence Across Generations**: Model weights reside in `/var/lib/ollama`, which is persistent state outside the ephemeral Nix store. System generation switches (`just switch`) and rollbacks (`just boot`) will not delete or re-download model blobs.
- **Zero Large Binary Blobs in Version Control**: Avoids committing multi-gigabyte GGUF/checkpoint binaries into the Git repository, preserving fast repository cloning and clean CI workflows.

### Alternatives Considered
- *Manual imperative download (`ollama pull gemma4:12b` after boot)*: Leaves the machine in an incomplete state after initial declarative deployment.
- *Packaging model weights as Nix derivations in Nix store*: Causes excessive store bloat, slows down Nix evaluation, and is impractical for multi-gigabyte models with binary cache limits.
