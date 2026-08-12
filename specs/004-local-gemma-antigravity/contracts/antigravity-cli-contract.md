# Contract: Antigravity CLI Developer Environment Contract

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Spec**: [spec.md](../spec.md)

## 1. Home Manager Module Contract

The user-level configuration must be declared in `modules/home-manager/antigravity.nix`:

```nix
{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Latest Antigravity CLI package / wrapper
    antigravity-cli # or equivalent custom package / devShell tool
  ];

  home.sessionVariables = {
    ANTIGRAVITY_API_BASE = "http://127.0.0.1:11434/v1";
    ANTIGRAVITY_MODEL = "gemma4:12b";
    ANTIGRAVITY_OFFLINE = "1";
  };
}
```

---

## 2. Environment Variables & Defaults Contract

| Variable | Default Value | Description |
|---|---|---|
| `ANTIGRAVITY_API_BASE` | `http://127.0.0.1:11434/v1` | URL base for local OpenAI-compatible chat completion requests |
| `ANTIGRAVITY_MODEL` | `gemma4:12b` | Default local model target for code completion and agentic tasks |
| `ANTIGRAVITY_OFFLINE` | `1` | Disables telemetry and external cloud routing |

---

## 3. CLI Command & Execution Semantics

| Command | Action | Expected Outcome |
|---|---|---|
| `antigravity --version` | Version check | Outputs latest version string and build details |
| `antigravity check` | Environment diagnostic | Confirms connection to `http://127.0.0.1:11434/v1` and reports model `gemma4:12b` ready |
| `antigravity chat "Explain this module"` | Interactive prompt | Streams code explanation tokens directly to standard output |
| `antigravity task --file <path>` | Code refactoring / synthesis | Modifies targeted file context locally using Gemma 4 12B |
