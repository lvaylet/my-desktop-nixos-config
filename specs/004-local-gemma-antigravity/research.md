# Research & Architectural Decisions: Local Gemma 4 Model Acceleration & Aider CLI Integration

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Updated**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Decision 1: AI Pair-Programming TUI Alternative to Antigravity CLI

### Decision
Replace Antigravity CLI with **Aider (`aider-chat`)** as the primary interactive terminal-based AI pair-programming tool, packaged via `pkgs.aider-chat` in a dedicated declarative Home Manager module `modules/home-manager/aider.nix`.

### Rationale
- **First-Class Local & Ollama Support**: Aider has mature, native integration with Ollama (`--model ollama/gemma4:12b` or `ollama_chat/...`), local OpenAI-compatible endpoints, and LiteLLM backends without requiring proprietary cloud token authentication or cloud proxies.
- **Superior TUI Experience**: Aider provides a rich, terminal-native interactive UI with syntax highlighting, live streaming, in-terminal diff inspection, multi-line prompts, voice-to-code, and readline history.
- **Git-Aware Multi-File Codebase Editing**: Aider automatically builds an AST-based repository map, tracks modified files, generates clean Git commits with meaningful commit messages, and allows interactive undo/redo (`/undo`, `/diff`, `/commit`).
- **Nixpkgs Availability**: `aider-chat` is directly packaged in `nixpkgs` (`pkgs.aider-chat`), allowing purely declarative provisioning in Home Manager without ad-hoc binaries or container wrappers.
- **Offline & Private by Default**: Configured to point to `http://127.0.0.1:11434` with zero telemetry or cloud dependencies.

---

## Decision 2: Context Window Sizing (8k / 8,192 Tokens) & VRAM Budgeting

### Decision
Configure the local inference runtime and Aider pair-programming sessions with an **8,192 (8k) token context window** for the 8-bit quantized Gemma 4 12B model (`q8_0`) on the 16 GB RTX 5070 Ti.

### Rationale
- **100% Dedicated VRAM Fit**:
  - Model weights (12B q8_0): ~12.5–13.0 GB VRAM.
  - 8k KV cache: ~1.2–1.5 GB VRAM.
  - Total inference footprint: ~14.0–14.5 GB VRAM.
  - Remaining unallocated VRAM: ~1.5–2.0 GB VRAM.
- **Zero PCIe Performance Throttling**: All transformer layers and KV cache allocations fit completely inside the physical 16 GB GDDR7 VRAM, preventing memory spillover across the PCIe bus and maintaining sustained token generation throughput of ~40–50 tokens/sec.
- **Display Server & Desktop Compositor Protection**: Retaining ~1.5–2.0 GB of free VRAM guarantees that Wayland/X11 compositors, 4K multi-monitor setups, and hardware-accelerated desktop applications (Ghostty, VS Code, Firefox) remain smooth and fluid without frame stutter or GPU driver resets during heavy multi-turn pair programming.
- **Optimized for Aider AST Repo Map**: Aider's AST repo map uses ~1k tokens, leaving ~7k tokens for conversation history and 2–4 full source code files in active context.

---

## Decision 3: Local Inference Engine & Service Architecture

### Decision
Implement the local inference runtime using NixOS native `services.ollama` with explicit CUDA hardware acceleration (`package = pkgs.ollama-cuda`) in a dedicated modular file `modules/nixos/ollama.nix`, imported directly by `machines/desktop-pc/configuration.nix`.

### Rationale
- **Native NixOS Module**: NixOS provides upstream support for `services.ollama` with out-of-the-box systemd daemon management, log rotation, and dynamic library linking against NVIDIA CUDA drivers.
- **OpenAI-Compatible & Native Ollama APIs**: Ollama serves an OpenAI-compatible API endpoint on loopback (`http://127.0.0.1:11434/v1`) and native Ollama API (`http://127.0.0.1:11434`), allowing Aider to interface natively with local models.
- **Dynamic Model Management & Layer Offloading**: Ollama automatically detects NVIDIA compute capabilities (Compute Capability on Blackwell / RTX 5070 Ti) and offloads 100% of transformer layers to GPU VRAM while maintaining graceful CPU/system RAM overflow protection.
- **Local Isolation**: Binds by default to `127.0.0.1:11434`, ensuring that the service is never exposed to external LAN interfaces without intentional firewall modification.

---

## Decision 4: Aider CLI Provisioning & Declarative Home Manager Configuration

### Decision
Create a dedicated Home Manager module `modules/home-manager/aider.nix` imported by the desktop user profile, which installs `pkgs.aider-chat`, declares default configuration in `~/.aider.conf.yml`, exports `OLLAMA_API_BASE=http://127.0.0.1:11434`, and provides a `just aider` recipe in `justfile`.

### Rationale
- **Hermetic User Tooling**: Adheres to Principle II (Modular Separation of Concerns) by keeping user developer utilities inside Home Manager while keeping systemd daemons in NixOS system modules.
- **Zero-Config Developer Experience**: Running `aider` or `just aider` automatically loads `~/.aider.conf.yml` specifying `model: ollama/gemma4:12b` and connects directly to the local Ollama instance.
- **Offline & Private by Default**: Configured to direct all completion traffic to the loopback interface, completely eliminating accidental cloud telemetry or third-party credential dependencies.

---

## Decision 5: On-Demand Model Download & Persistent Storage

### Decision
Configure the Ollama daemon without declarative `loadModels` in NixOS, allowing the system service to start empty, and provide an operational task runner recipe (`just download-model model="gemma4:12b"`) to download and store model weights into `/var/lib/ollama/models` on demand.

### Rationale
- **Fast System Builds & Switches**: Omitting `loadModels` prevents NixOS rebuilds (`just switch` / `just test`) from blocking or timing out during system activation while downloading multi-gigabyte model blobs.
- **Persistence Across Generations**: Model weights downloaded on demand reside in `/var/lib/ollama/models`, which is persistent state outside the ephemeral Nix store. System generation switches and rollbacks will not delete or re-download model blobs.
