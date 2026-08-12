# Nix Module & Configuration Interface Contract

**Feature**: `001-system-prd`
**Status**: Active Contract

## Overview

This contract governs how system modules, user modules, and machine configurations communicate, receive shared variables, and expose options across the repository.

---

## 1. Top-Level Flake Interface (`flake.nix`)

The root `flake.nix` exports standard Nix Flake outputs:

```nix
{
  outputs = { self, nixpkgs, ... } @ inputs: {
    nixosConfigurations = {
      desktop-pc = ...; # mkNixOSConfig ./machines/desktop-pc/configuration.nix
      homelab = ...;    # mkNixOSConfig ./machines/homelab/configuration.nix
      iso = ...;        # Minimal bootable recovery ISO
    };

    checks."x86_64-linux" = {
      pre-commit-check = ...; # Cachix git-hooks.nix runner
    };

    formatter."x86_64-linux" = ...; # Alejandra wrapper script

    devShells."x86_64-linux" = {
      default = ...; # mkShell with git-hooks pre-commit tools
    };
  };
}
```

---

## 2. Injected Arguments (`specialArgs` & `extraSpecialArgs`)

Every NixOS and Home Manager module MUST accept or handle the standard argument bundle:

```nix
{
  inputs,   # Flake inputs (nixpkgs, home-manager, nvf, git-hooks)
  outputs,  # Self outputs reference
  vars,     # Global identity record imported from vars.nix
  pkgs,     # Nixpkgs package set configured with allowUnfree = true
  config,   # System/user configuration tree
  lib,      # Nixpkgs library functions
  ...
}:
```

---

## 3. Global Variables Schema (`vars.nix`)

The identity contract in `vars.nix` guarantees the presence of the following attributes:

```nix
{
  fullName = "<string>";             # e.g., "Laurent VAYLET"
  userName = "<string>";             # e.g., "laurent"
  userEmail = "<string>";            # e.g., "laurent.vaylet@gmail.com"
  sshPublicKeyPersonal = "<string>"; # e.g., "ssh-ed25519 AAAAC3NzaC..."
  sshPublicKeyWork = "<string>";     # e.g., "ssh-ed25519 AAAAC3NzaC..."
}
```

---

## 4. Machine Composition Rules (`machines/<host>/configuration.nix`)

Each machine configuration MUST follow the composition structure:

1. Define `networking.hostName = "<host>"`.
2. Import `inputs.home-manager.nixosModules.home-manager`.
3. Import `./hardware-configuration.nix`.
4. Import `./../../modules/nixos/base.nix`.
5. Import required feature/service modules from `./../../modules/nixos/`.
6. Configure `home-manager.users.${vars.userName}` importing `./../../modules/home-manager/base.nix` and required user tool modules.
