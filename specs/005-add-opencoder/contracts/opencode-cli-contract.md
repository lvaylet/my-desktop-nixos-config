# Interface Contract: OpenCoder Home Manager Module & CLI

**Feature Branch**: `005-add-opencoder` | **Date**: 2026-08-13 | **Spec**: [spec.md](../spec.md)

## 1. Home Manager Module Interface

### Module Path: `modules/home-manager/opencode.nix`

- **Input Attributes**: `{pkgs, ...}`
- **Exported Packages**: `pkgs.opencode` added to `home.packages`.
- **Exported Files**:
  - `~/.config/opencode/config.json` (via `xdg.configFile."opencode/config.json".text` or `home.file.".config/opencode/config.json".text`)

### Configuration Content Schema:

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

## 2. CLI Invocation Contract

- **Binary Name**: `opencode`
- **Interactive Session**: `opencode` (opens interactive TUI in current working directory)
- **One-off Prompt**: `opencode run "<prompt>"`
- **List Models**: `opencode models`
- **Debug Configuration**: `opencode debug config`
