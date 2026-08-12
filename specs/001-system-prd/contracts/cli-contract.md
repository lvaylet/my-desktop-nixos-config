# Operational CLI Interface Contract (`justfile`)

**Feature**: `001-system-prd`
**Status**: Active Contract

## Overview

The operational interface is provided via `just` as the standardized entrypoint for managing configurations, quality checks, builds, and lifecycle operations across all target systems.

---

## Command Groups & Recipes

### 1. Group: `(re)build`

| Recipe | Parameters & Defaults | Description | Underlying Execution |
| :--- | :--- | :--- | :--- |
| `build` | `configuration="desktop-pc"` | Rebuild the specified host configuration derivation | `nh os build .#<config>` |
| `switch` | `configuration="desktop-pc"` | Rebuild and switch live system to new generation | `nh os switch .#<config>` |
| `boot` | `configuration="desktop-pc"` | Rebuild and set as default for next boot | `nh os boot .#<config>` |
| `test` | `configuration="desktop-pc"` | Rebuild and activate in current session without switching bootloader | `nh os test .#<config>` |
| `build-iso` | None | Build minimal standalone rescue ISO image | `nix build .#nixosConfigurations.iso.config.system.build.isoImage` |

---

### 2. Group: `dev-utils`

| Recipe | Parameters | Description | Underlying Execution |
| :--- | :--- | :--- | :--- |
| `fmt` | None | Recursively format all Nix source files | `nix fmt .` (`alejandra`) |
| `lint` | None | Run static analysis and dead-code checks | `deadnix && statix check` |
| `fix` | None | Automatically fix linting and dead-code warnings | `deadnix --edit && statix fix` |

---

### 3. Group: `flake-management`

| Recipe | Parameters | Description | Underlying Execution |
| :--- | :--- | :--- | :--- |
| `check` | None | Evaluate flake and run all hermetic checks in sandbox | `nix flake check` |
| `show` | None | Display all outputs exposed by the flake | `nix flake show` |
| `up` | None | Update all flake inputs and rewrite `flake.lock` | `nix flake update` |

---

### 4. Group: `garbage-collection`

| Recipe | Parameters & Defaults | Description | Underlying Execution |
| :--- | :--- | :--- | :--- |
| `clean` | `keep="1"` | Clean old generations for current user | `nh clean user --keep <keep>` |
| `clean-all` | `keep="1"` | Clean all system and user profile generations | `nh clean all --keep <keep>` |
| `collect-garbage` | None | Delete unreachable store objects | `nix-collect-garbage` |
| `delete-old-generations` | None | Delete all old profile generations and purge unreachable store objects | `nix-collect-garbage --delete-old` |

---

## Error Handling & Exit Codes

- **Exit Code 0**: Recipe completed successfully.
- **Exit Code 1+**: Nix evaluation error, pre-commit check failure, or insufficient permissions (e.g. `nh os switch` requiring `sudo`).
