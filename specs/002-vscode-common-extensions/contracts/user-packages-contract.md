# Interface Contract: User Packages Home Manager Module

**Module**: `modules/home-manager/_packages.nix` | **Date**: 2026-08-12

This contract defines the package additions and binary export expectations for `modules/home-manager/_packages.nix`.

---

## 1. Module Input Contract

The module accepts standard Home Manager arguments:

```nix
{
  lib,
  pkgs,
  osConfig,
  ...
}:
```

---

## 2. Package Addition Contract

The `home.packages` list MUST include `pkgs.shellcheck` under the `# Development` section:

```nix
home.packages = with pkgs; [
  # Development
  # ---
  antigravity # Experience liftoff with the next-gen agent platform
  shellcheck  # Shell script analysis tool - https://www.shellcheck.net/

  # ...
];
```

---

## 3. Exported Binaries & PATH Contract

Upon activation via Home Manager:
- The binary `shellcheck` is linked into `$HOME/.nix-profile/bin/shellcheck`.
- `$HOME/.nix-profile/bin` is in the user's `$PATH`.
- Executing `shellcheck --version` returns exit code 0 and displays the installed version.
