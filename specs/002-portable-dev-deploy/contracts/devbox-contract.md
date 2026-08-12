# Devbox & Environment Interface Contract

**Feature**: Portable Multi-Environment Development, Testing, and Deployment (`002-portable-dev-deploy`)
**Date**: 2026-08-12
**Status**: Completed

## 1. Devbox Schema Specification (`devbox.json`)

The `devbox.json` file at repository root MUST conform to the Jetify Devbox specification:

```json
{
  "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.13.0/.schema/devbox.schema.json",
  "packages": [
    "alejandra@latest",
    "deadnix@latest",
    "statix@latest",
    "just@latest",
    "nh@latest",
    "ripsecrets@latest",
    "trufflehog@latest"
  ],
  "shell": {
    "init_hook": [
      "echo '🚀 Devbox environment loaded: all NixOS development & verification tools ready.'"
    ],
    "scripts": {
      "check": "just check",
      "lint": "just lint",
      "fmt": "just fmt",
      "build": "just build",
      "test": "just test"
    }
  }
}
```

---

## 2. Toolchain Parity Matrix

The following table defines guaranteed tool versions and availability across the dual developer environments:

| Tool | Devbox (`devbox.json`) | Nix DevShell (`nix develop`) | Purpose |
| :--- | :--- | :--- | :--- |
| **`just`** | Included in `packages` | Included in `devShells.default` | Operational task orchestration |
| **`alejandra`** | Included in `packages` | Included via `checks.pre-commit` | Declarative Nix formatter |
| **`statix`** | Included in `packages` | Included via `checks.pre-commit` | Static analysis & anti-pattern linter |
| **`deadnix`** | Included in `packages` | Included via `checks.pre-commit` | Unused/dead code scanner |
| **`ripsecrets`** | Included in `packages` | Included via `checks.pre-commit` | Secret leak detection |
| **`trufflehog`**| Included in `packages` | Included via `checks.pre-commit` | Deep credential scanner |
| **`nh`** | Included in `packages` | Included in `devShells.default` | Nix helper CLI for fast local builds |
| **Git Pre-commit** | Available via `devbox run` | Hook installed on shell entry | Shift-left commit hygiene |

---

## 3. Platform Compatibility Guarantees

| Platform | Native Nix DevShell | Devbox Shell | Deployment Mode Supported |
| :--- | :--- | :--- | :--- |
| **NixOS (x86_64-linux)** | Fully Supported | Supported | Local + Remote SSH Deployment |
| **Generic Linux (x86_64-linux)** | Fully Supported | Supported | Local Build + Remote SSH Deployment |
| **Generic Linux (aarch64-linux)** | Fully Supported | Supported | Local Build + Remote SSH Deployment |
| **macOS (x86_64-darwin / aarch64-darwin)** | Fully Supported | Supported | Flake Check / Lint / Dev Only |
| **Windows (WSL2)** | Fully Supported | Supported | Local Build + Remote SSH Deployment |
