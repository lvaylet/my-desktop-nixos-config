# Research & Architectural Decisions: OpenCoder AI Assistant Integration

**Feature Branch**: `005-add-opencoder` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Summary of Decisions

This document details the architectural choices, package evaluation, provider configuration, and coexistence strategy for integrating OpenCoder (`opencode`) into the declarative NixOS / Home Manager environment on `desktop-pc` alongside Aider.

---

## Decision 1: Packaging & Tool Selection (`pkgs.opencode`)

- **Context**: The user requested adding "OpenCoder" in addition to Aider as an AI coding assistant in their terminal environment.
- **Decision**: Use `pkgs.opencode` (version 1.18.x) from `nixpkgs` (unstable channel), packaged via a dedicated Home Manager module `modules/home-manager/opencode.nix`.
- **Rationale**:
  - `opencode` is actively maintained in `nixpkgs-unstable`, built as a terminal-native AI coding agent.
  - It provides a modern TUI interface, multi-file code editing, agentic workflows, MCP (Model Context Protocol) support, and flexible provider configurations.
  - It installs cleanly into the user profile without requiring global root privileges or imperative npm/pip installations.
- **Alternatives Considered**:
  - *Imperative installation via npm/bun*: Rejected because it violates Constitution Principle I (Declarative & Hermetic Configuration).
  - *Running in a container / devbox only*: Rejected because the developer needs OpenCoder globally available across all projects from their standard shell.

---

## Decision 2: Local Model Provider & API Integration

- **Context**: OpenCoder must use the existing local 8-bit quantized Gemma 4 12B model served by Ollama on the desktop workstation (`desktop-pc`).
- **Decision**: Configure OpenCoder to connect to Ollama's OpenAI-compatible HTTP API endpoint (`http://127.0.0.1:11434/v1`) using the `@ai-sdk/openai` provider definition in `~/.config/opencode/config.json`:
  ```json
  {
    "$schema": "https://opencode.ai/config.json",
    "model": "ollama/gemma4:12b",
    "provider": {
      "ollama": {
        "npm": "@ai-sdk/openai",
        "options": {
          "baseURL": "http://127.0.0.1:11434/v1"
        },
        "models": {
          "gemma4:12b": {
            "name": "gemma4:12b",
            "limit": {
              "context": 8192,
              "output": 8192
            }
          }
        }
      }
    }
  }
  ```
- **Rationale**:
  - Ollama natively exposes a standard OpenAI-compatible API at `/v1` (e.g. `/v1/chat/completions` and `/v1/models`).
  - OpenCoder's `@ai-sdk/openai` provider seamlessly communicates with any OpenAI-compatible endpoint.
  - Setting `limit.context = 8192` and `limit.output = 8192` aligns perfectly with the 8k context window budgeted for the 8-bit Gemma 4 12B model on the 16 GB RTX 5070 Ti GPU.
- **Alternatives Considered**:
  - *Native Ollama SDK / provider*: Currently OpenCoder uses AI SDK OpenAI compatibility for custom local endpoints; the OpenAI adapter works reliably out of the box with zero additional runtime plugins.

---

## Decision 3: Declarative Configuration Placement

- **Context**: OpenCoder searches for configuration at `~/.config/opencode/config.json`.
- **Decision**: Manage the configuration file declaratively via Home Manager `xdg.configFile."opencode/config.json"` (or `home.file.".config/opencode/config.json"`).
- **Rationale**:
  - Follows standard XDG configuration standards.
  - Ensures the configuration is reproducible, version-controlled, and immutable against accidental drift.
  - Aligns with the existing repository pattern used for Aider (`modules/home-manager/aider.nix`).
- **Alternatives Considered**:
  - *CLI command-line flags only*: Requires typing lengthy options on every invocation; fragile and inconvenient.

---

## Decision 4: Coexistence with Aider

- **Context**: The user has not yet decided whether to use Aider or OpenCoder and wants both available simultaneously for comparison.
- **Decision**:
  - Maintain `modules/home-manager/aider.nix` and create `modules/home-manager/opencode.nix` as peer modules.
  - Both modules are imported in `machines/desktop-pc/configuration.nix`.
  - Both tools query the same local Ollama service (`127.0.0.1:11434`), allowing the developer to switch between them instantaneously in different terminal tabs.
- **Rationale**:
  - Zero namespace conflicts between `aider` (`~/.aider.conf.yml`) and `opencode` (`~/.config/opencode/config.json`).
  - Allows side-by-side evaluation of diff rendering, prompting capabilities, and interactive workflows.

---

## Decision 5: Operational Task Runner Recipes (`justfile`)

- **Context**: Ergonomic task runner shortcuts for running coding assistants.
- **Decision**: Add a `just opencode` recipe in `justfile`:
  ```just
  # Run OpenCoder interactive terminal session
  opencode *args:
      opencode {{args}}
  ```
- **Rationale**:
  - Matches the existing `just aider` recipe.
  - Allows easy invocation from any project root.
