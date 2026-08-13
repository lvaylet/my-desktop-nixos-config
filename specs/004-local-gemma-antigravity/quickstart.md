# Quickstart: Local Gemma 4 & Aider CLI Validation Guide

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Updated**: 2026-08-13 | **Spec**: [spec.md](spec.md)

This guide documents runnable validation scenarios to verify that the local 8-bit quantized Gemma 4 12B model acceleration (with 8k context window) and Aider CLI integration function correctly end-to-end on the `desktop-pc` workstation.

---

## Prerequisites

- Physical machine: `desktop-pc` with 32 GB RAM and NVIDIA GeForce RTX 5070 Ti (16 GB VRAM).
- NVIDIA proprietary/open drivers active (`nvidia-smi` displays GPU details).
- Local Git repository on branch `004-local-gemma-antigravity`.

---

## Scenario 1: Static Analysis & Flake Evaluation (Pre-Flight)

Verify that the new NixOS and Home Manager modules pass all static analysis, dead code checks, formatting, and flake integrity gates:

```bash
# 1. Format Nix code
just fmt

# 2. Run static linting (deadnix, statix)
just lint

# 3. Hermetic sandbox evaluation check
just check
```

**Expected Outcome**: All checks exit with code `0`.

---

## Scenario 2: Safe Test Activation on Workstation

Activate the new configuration in temporary testing mode without updating default bootloader entries:

```bash
just test configuration="desktop-pc"
```

**Expected Outcome**: The system applies the new generation in memory, starts `ollama.service`, installs `pkgs.aider-chat`, and configures `~/.aider.conf.yml` and user environment variables without errors or long download delays.

---

## Scenario 3: Ollama Service Status & On-Demand Model Download

Verify that the systemd service is active, and download the Gemma 4 12B model on demand:

```bash
# 1. Check service status
just ollama-status

# 2. Verify Ollama is listening on loopback
curl -s http://127.0.0.1:11434/

# 3. Download Gemma 4 12B model weights on demand
just download-model model="gemma4:12b"

# 4. Verify model is installed
just ollama-models
```

**Expected Outcome**:
- `just ollama-status` reports `active (running)`.
- `curl` returns `"Ollama is running"`.
- `just ollama-models` lists `gemma4:12b`.

---

## Scenario 4: Direct Local Model Inference & VRAM Allocation

Issue a direct completion request to the model with 8k context support and observe GPU VRAM allocation:

```bash
# In a separate terminal, monitor GPU usage:
just gpu-status

# Issue a test prompt to the local model:
just test-inference prompt="Write a short Nix flake snippet."
```

**Expected Outcome**:
- `nvidia-smi` shows ~14–15 GB VRAM allocated to the Ollama process (weights + KV cache).
- Response JSON is returned with valid code generation.
- Response time demonstrates low latency and fast token generation (~40–50 tokens/sec).

---

## Scenario 5: Aider CLI Interactive Pair-Programming Workflow

Launch an interactive Aider pair-programming session:

```bash
# 1. Verify Aider version
aider --version

# 2. Launch Aider pair-programming session via just recipe
just aider
```

Inside the Aider session:
```text
> /add README.md
> Summarize the local AI development setup configured in this repository.
```

**Expected Outcome**:
- Aider starts with the rich terminal TUI, connects to `ollama/gemma4:12b` via `http://127.0.0.1:11434`, and builds the repository map within the 8k context window.
- Generated code explanations and file edits stream in real time.
- Changes produce clear diffs and optional auto-commits.

---

## Scenario 6: Desktop Multi-Tasking & Memory Stability

While a large coding prompt is generating in the background:
1. Move graphical windows, switch desktop workspaces, and browse web pages in a browser.
2. Verify display fluidness using `nvtop` or `just gpu-status`.

**Expected Outcome**:
- Desktop display remains fluid with ~1.5–2.0 GB VRAM available for display compositing.
- Zero GUI crashes, display driver resets, or kernel out-of-memory errors.
