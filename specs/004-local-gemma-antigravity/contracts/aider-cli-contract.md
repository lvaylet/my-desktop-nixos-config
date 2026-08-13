# Contract: Aider CLI Developer Environment Contract

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Updated**: 2026-08-13 | **Spec**: [spec.md](../spec.md)

## 1. Home Manager Module Contract

The user-level configuration must be declared in `modules/home-manager/aider.nix`:

```nix
{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      aider-chat
    ];

    file.".aider.conf.yml".text = ''
      model: ollama/gemma4:12b
      dark-mode: true
      auto-commits: true
      show-diffs: true
      set-env:
        - OLLAMA_API_BASE=http://127.0.0.1:11434
    '';

    file.".aider.model.settings.yml".text = ''
      - name: ollama/gemma4:12b
        extra_params:
          num_ctx: 8192
      - name: ollama_chat/gemma4:12b
        extra_params:
          num_ctx: 8192
    '';

    file.".aider.model.metadata.json".text = ''
      {
        "ollama/gemma4:12b": {
          "max_tokens": 8192,
          "max_input_tokens": 8192,
          "max_output_tokens": 8192,
          "input_cost_per_token": 0.0,
          "output_cost_per_token": 0.0,
          "litellm_provider": "ollama",
          "mode": "chat"
        },
        "ollama_chat/gemma4:12b": {
          "max_tokens": 8192,
          "max_input_tokens": 8192,
          "max_output_tokens": 8192,
          "input_cost_per_token": 0.0,
          "output_cost_per_token": 0.0,
          "litellm_provider": "ollama",
          "mode": "chat"
        }
      }
    '';

    sessionVariables = {
      OLLAMA_API_BASE = "http://127.0.0.1:11434";
    };
  };
}
```

---

## 2. Environment Variables & Defaults Contract

| Variable / Config Key | Default Value | Description |
|---|---|---|
| `model` in `.aider.conf.yml` | `ollama/gemma4:12b` | Default local model target for code completion and pair programming |
| `OLLAMA_API_BASE` | `http://127.0.0.1:11434` | Base URL for local Ollama API requests |
| `dark-mode` | `true` | Terminal UI theme matching dark shell themes |
| `auto-commits` | `true` | Automatically creates git commits with generated descriptions |
| Context window budget | `8192` tokens (8k) | Supported context length for prompt and repository map ingestion |

---

## 3. CLI Command & Execution Semantics

| Command | Action | Expected Outcome |
|---|---|---|
| `aider --version` | Version check | Outputs Aider version string |
| `aider` | Interactive pair-programming session | Starts TUI with repository map and connects to `ollama/gemma4:12b` |
| `aider <file1> <file2>` | File-scoped editing session | Adds files to chat context within the 8k token budget |
| `just aider` | Task runner launch recipe | Runs `aider` in current workspace directory |
| `just aider-architect` | Architect/editor mode | Runs `aider --architect` for complex multi-step reasoning |
