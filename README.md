# my-nixos-configurations

Declarative NixOS multi-host configurations, Home Manager user environments, and portable cross-platform development toolchains.

## Quickstart & Environment Setup

This repository supports development, testing, and deployment from **any Linux machine** (NixOS or non-NixOS) as well as **macOS and Windows (WSL2)** via Devbox.

### Option 1: Cross-Platform via Devbox (Recommended for non-NixOS / macOS / WSL)

If you have [Devbox](https://www.jetify.com/devbox) installed:

```sh
# Start the development shell with all linters, formatters, and task runners:
devbox shell

# Or run tasks directly:
devbox run check
devbox run lint
devbox run fmt
```

### Option 2: Native Nix Flakes (`nix develop`)

On any system with the Nix package manager and Flakes enabled:

```sh
# Enter the nix development shell (automatically sets up pre-commit hooks):
nix develop

# Format and lint:
just fmt
just lint
just check
```

---

## Operational Recipes (`justfile`)

All common workflows are defined in the [`justfile`](justfile):

```sh
$ just
Available recipes:
    default                                     # run `just --list`

    [(re)build]
    boot configuration="desktop-pc" target=""   # rebuild and set boot entry (local or remote over SSH)
    build configuration="desktop-pc" target=""  # rebuild system closure (local or remote over SSH)
    build-iso                                   # build custom ISO image with SSH access for remote installations
    switch configuration="desktop-pc" target="" # rebuild and switch (local or remote over SSH)
    test configuration="desktop-pc" target=""   # rebuild and activate temporarily (local or remote over SSH)

    [dev-utils]
    fix                                         # fix warnings reported by linters
    fmt                                         # format code recursively
    lint                                        # run linters

    [flake-management]
    check                                       # check whether the flake evaluates and run its tests
    show                                        # show the flake outputs
    up                                          # update all inputs and `flake.lock` file

    [garbage-collection]
    clean keep="1"                              # clean the current user's profiles
    clean-all keep="1"                          # clean all profiles
    collect-garbage                             # delete all unreachable store objects
    delete-old-generations                      # delete all unreachable store objects and old generations of profiles
```

### Remote Deployments over SSH

To deploy to a remote NixOS host from any Linux machine:

```sh
# Temporarily test a configuration on a remote target:
just test configuration="homelab" target="homelab"

# Permanently deploy and switch a remote target:
just switch configuration="homelab" target="homelab"

# Set next boot profile on a remote target:
just boot configuration="homelab" target="homelab"
```

### Local / Non-NixOS Building

On a non-NixOS Linux workstation, build a target system closure without requiring root privileges:

```sh
just build configuration="homelab"
```

---

## Flake Outputs

```sh
$ just show
git+file:///home/laurent/workspace/github.com/lvaylet/my-nixos-configurations
├───checks
│   ├───aarch64-darwin
│   ├───aarch64-linux
│   ├───x86_64-darwin
│   └───x86_64-linux
│       └───pre-commit-check: derivation 'pre-commit-run'
├───devShells
│   ├───aarch64-darwin
│   ├───aarch64-linux
│   ├───x86_64-darwin
│   └───x86_64-linux
│       └───default: development environment 'nix-shell'
├───formatter
│   ├───aarch64-darwin
│   ├───aarch64-linux
│   ├───x86_64-darwin
│   └───x86_64-linux: package 'pre-commit-run'
└───nixosConfigurations
    ├───desktop-pc: NixOS configuration
    ├───homelab: NixOS configuration
    └───iso: NixOS configuration
```

## Useful Nix Commands

| Command | Purpose |
| --- | --- |
| `nix fmt .` | format all Nix code with Alejandra |
| `nix develop` | activate developer shell with pre-commit hooks and linters |
| `nix flake check` | check whether flake evaluates and all checks pass |
| `nix flake show` | show outputs provided by the flake |
| `nix flake update` | update all pinned inputs in `flake.lock` |
| `nixos-rebuild switch --flake .#<host> --target-host <host> --use-remote-sudo` | manual remote switch command |
