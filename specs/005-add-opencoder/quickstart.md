# Quickstart & Validation Guide: OpenCoder AI Assistant Integration

**Feature Branch**: `005-add-opencoder` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Overview

This guide provides step-by-step verification procedures to validate that OpenCoder (`opencode`) is correctly configured alongside Aider (`aider`), connects to the local Ollama instance running the 8-bit Gemma 4 12B model, and executes offline AI coding tasks without conflict.

---

## 1. Static Verification & Flake Checks

Run the flake integrity and linting checks:

```bash
# Run all pre-commit hooks, linters, and Nix flake checks hermetically
just check
```

**Expected Result**: All hooks (alejandra, deadnix, statix, trufflehog, ripsecrets, etc.) pass with exit code 0.

---

## 2. Declarative Module Verification

Check that OpenCoder is properly packaged and configured:

```bash
# Evaluate desktop-pc home-manager packages
nix eval .#nixosConfigurations.desktop-pc.config.home-manager.users.lvaylet.home.packages
```

---

## 3. Verify Local Model Connectivity

Ensure the Ollama service is active and the Gemma 4 12B model is available:

```bash
# Verify Ollama local models endpoint
curl -s http://127.0.0.1:11434/v1/models | jq .
```

---

## 4. Run OpenCoder Session

Launch an interactive OpenCoder session or one-off prompt using the `justfile` recipe:

```bash
# Run interactive OpenCoder TUI
just opencode

# Or run one-off command
opencode run "Explain what this repository does in two sentences"
```

---

## 5. Verify Coexistence with Aider

Verify both tools operate concurrently without interference:

```bash
# Check Aider configuration
aider --version

# Check OpenCoder configuration
opencode --version
```
