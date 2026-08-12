# Interface Contract: VS Code Home Manager Module

**Module**: `modules/home-manager/vscode.nix` | **Date**: 2026-08-12

This contract defines the declarative interface, option bindings, extension lists, and user settings schema exposed by `modules/home-manager/vscode.nix`.

---

## 1. Module Input Contract

The module is a standard Home Manager function accepting:

```nix
{ pkgs, ... }: {
  programs.vscode = { ... };
}
```

---

## 2. Extension Set Contract

The default profile extension list (`programs.vscode.profiles.default.extensions`) MUST include the following attributes within `with pkgs.vscode-extensions; [ ... ]`:

```nix
# Linters and LSPs
# ---
davidanson.vscode-markdownlint # Markdown Linting and Style Checking
timonwong.shellcheck           # Integrates ShellCheck into VS Code

# Debuggers
# ---
vadimcn.vscode-lldb            # Native debugger based on LLDB

# Code Runners
# ---
formulahendry.code-runner      # Run code snippet or code file for multiple languages

# Dependencies & Manifests
# ---
fill-labs.dependi              # Dependency management for Cargo.toml, package.json, etc.
```

---

## 3. User Settings (`settings.json`) Contract

The `programs.vscode.profiles.default.userSettings` attribute set MUST generate a valid `settings.json` containing the following keys:

```json
{
  "code-runner.runInTerminal": true,
  "code-runner.saveFileBeforeRun": true,
  "code-runner.clearPreviousOutput": true
}
```

---

## 4. Output Artifacts

Upon activation via Home Manager:
1. Symlinks are established in `~/.vscode/extensions/` or equivalent Nix-managed extension store.
2. JSON settings are written to `~/.config/Code/User/settings.json`.
