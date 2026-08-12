# Technical Research & Architecture Decisions: Common Multi-Language VS Code Extensions

**Feature**: `002-vscode-common-extensions` | **Date**: 2026-08-12

This document records the architectural decisions, package resolution strategies, and trade-offs for adding common multi-language development extensions and supporting CLI tools.

---

## 1. VS Code Extension Selection & Nixpkgs Resolution

- **Context**: The feature requires adding five common multi-language extensions to the declarative VS Code profile:
  - Code Runner by Jun Han
  - CodeLLDB by Vadim Chugunov
  - Dependin by Fill Labs
  - markdownlint by David Anson
  - ShellCheck by Timon Wong
- **Decision**: Declare extensions using first-party `pkgs.vscode-extensions` package attributes in `modules/home-manager/vscode.nix`:
  - `pkgs.vscode-extensions.formulahendry.code-runner`
  - `pkgs.vscode-extensions.vadimcn.vscode-lldb`
  - `pkgs.vscode-extensions.fill-labs.dependi`
  - `pkgs.vscode-extensions.davidanson.vscode-markdownlint`
  - `pkgs.vscode-extensions.timonwong.shellcheck`
- **Rationale**:
  - First-party nixpkgs derivations are hermetic, version-pinned via `flake.lock`, and cached on binary caches.
  - Native extensions (like `vscode-lldb`) are automatically patched with NixOS ELF dynamic linkers and library RPATHs by nixpkgs.
- **Alternatives Considered**:
  - *Imperative VS Code Marketplace downloads*: Rejected because mutable downloads violate repository Constitution Principle I (Declarative & Hermetic Configuration).
  - *Custom `buildVscodeMarketplaceExtension` expressions*: Rejected because all five extensions are packaged and maintained in nixpkgs.

---

## 2. CLI Tooling Placement & Scope (`shellcheck`)

- **Context**: The ShellCheck VS Code extension requires the `shellcheck` binary to perform static analysis. Developers also require `shellcheck` in terminal workflows and pre-commit checks.
- **Decision**: Install `pkgs.shellcheck` in `modules/home-manager/_packages.nix` under general development packages.
- **Rationale**:
  - Aligns with the clarified requirement (Session 2026-08-12, Question 1).
  - Guarantees dual availability: the VS Code extension automatically discovers `shellcheck` in the user's `PATH`, while the user can also run `shellcheck` in CLI scripts, CI, and pre-commit hooks.
  - Adheres to repository Constitution Principle II (Modular Separation of Concerns) by placing user CLI tools in user Home Manager packages.
- **Alternatives Considered**:
  - *Scoping `shellcheck` strictly within VS Code*: Rejected because it prevents CLI/terminal parity and duplicates tool installations.
  - *System-wide installation in `modules/nixos/_packages.nix`*: Rejected because developer linters are user-specific tools and belong in Home Manager.

---

## 3. Code Runner Execution Runtime & Terminal Integration

- **Context**: Code Runner can execute code snippets in either the read-only Output channel or an interactive integrated terminal.
- **Decision**: Configure `"code-runner.runInTerminal" = true;` in `programs.vscode.profiles.default.userSettings` within `modules/home-manager/vscode.nix`.
- **Rationale**:
  - Aligns with the clarified requirement (Session 2026-08-12, Question 2).
  - Integrated terminal execution supports interactive standard input (`stdin`), ANSI color codes, and inherits the active shell environment and `direnv` environment variables.
- **Alternatives Considered**:
  - *Output tab execution (`runInTerminal: false`)*: Rejected because interactive input prompts (`read`, `input()`, `scanf`) hang or fail in the non-interactive output panel.

---

## 4. CodeLLDB Native Debug Adapter on NixOS

- **Context**: CodeLLDB includes compiled backend components (`codelldb` binary and shared libraries) that require dynamic linker patching on NixOS.
- **Decision**: Use the pre-packaged `pkgs.vscode-extensions.vadimcn.vscode-lldb` derivation.
- **Rationale**:
  - Nixpkgs maintains comprehensive `autoPatchelfHook` scripts for `vscode-lldb`, ensuring that LLDB backend binaries reference Nix store glibc and dynamic linker paths without runtime crashes.
- **Alternatives Considered**:
  - *Manual LLDB path configuration to system LLDB*: Rejected because the packaged extension is self-contained and pre-configured.

---

## 5. Dependin Manifest Analysis & Performance

- **Context**: Dependin analyzes dependencies declared in files such as `Cargo.toml` and `package.json` and queries registries for updates.
- **Decision**: Include `pkgs.vscode-extensions.fill-labs.dependi` in `modules/home-manager/vscode.nix`.
- **Rationale**:
  - Provides lightweight inline lenses for package versions without interfering with underlying language servers (`nixd`, `rust-analyzer`).
- **Alternatives Considered**:
  - *Language-specific individual dependency extensions*: Rejected in favor of a single unified multi-language dependency manager.
