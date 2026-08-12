# Quickstart: Local Gemma 4 & Antigravity Validation Guide

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Spec**: [spec.md](spec.md)

This guide documents runnable validation scenarios to verify that the local Gemma 4 12B model acceleration and Antigravity CLI integration function correctly end-to-end on the `desktop-pc` workstation.

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

**Expected Outcome**: The system applies the new generation in memory, starts `ollama.service`, and configures user environment variables without errors or long download delays.

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

Issue a direct completion request to the model and observe GPU VRAM allocation:

```bash
# In a separate terminal, monitor GPU usage:
just gpu-status

# Issue a test prompt to the local model:
just test-inference prompt="Write a short Nix flake snippet."
```

**Expected Outcome**:
- `nvidia-smi` shows ~13–14 GB VRAM allocated to the Ollama process.
- Response JSON is returned with valid code generation.
- Response time demonstrates low latency and fast token generation.

---

## Scenario 5: Antigravity CLI Developer Workflow

Open a new terminal shell session to verify the Antigravity CLI integration:

```bash
# 1. Verify environment variables
echo $ANTIGRAVITY_API_BASE
# Expected: http://127.0.0.1:11434/v1

echo $ANTIGRAVITY_MODEL
# Expected: gemma4:12b

# 2. Run CLI health check
antigravity check

# 3. Execute interactive coding prompt
antigravity chat "Write a function in Rust that parses JSON strings safely."
```

**Expected Outcome**:
- Antigravity CLI connects to `127.0.0.1:11434/v1` without errors.
- Streaming responses render smoothly in the terminal session.

---

## Scenario 6: Desktop Multi-Tasking & Memory Stability

While a large coding prompt is generating in the background:
1. Move graphical windows, switch desktop workspaces, and browse web pages in a browser.
2. Verify display fluidness using `nvtop` or `just gpu-status`.

**Expected Outcome**:
- Desktop display remains fluid with ~2–3 GB VRAM available for display compositing.
- Zero GUI crashes, display driver resets, or kernel out-of-memory errors.
