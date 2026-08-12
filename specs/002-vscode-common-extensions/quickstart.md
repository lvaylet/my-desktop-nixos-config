# Quickstart Validation Guide: Common Multi-Language VS Code Extensions

**Feature**: `002-vscode-common-extensions` | **Date**: 2026-08-12

This guide outlines step-by-step verification procedures to validate that all extensions, CLI dependencies, and configuration settings operate correctly.

---

## 1. Prerequisites

- Host environment: NixOS on `desktop-pc`
- Working directory: Repository root (`my-nixos-configurations`)
- Target files modified per [VS Code Contract](contracts/vscode-module-contract.md) and [User Packages Contract](contracts/user-packages-contract.md).

---

## 2. Quality Gates Verification

Execute repository quality checks before system activation:

```bash
# 1. Format Nix files
just fmt

# 2. Run static analysis and dead code detection
just lint

# 3. Hermetically evaluate flake checks
just check
```

**Expected Outcome**: All commands succeed with exit code `0` and zero linter warnings.

---

## 3. Safe Profile Activation Testing

Test the configuration without permanently altering the system bootloader entry:

```bash
just test configuration="desktop-pc"
```

**Expected Outcome**: Home Manager generates and activates the user environment profile without errors.

---

## 4. End-to-End Functional Verification Scenarios

### Scenario A: ShellCheck Integration (IDE & CLI)

1. **CLI Verification**: Run `shellcheck --version` in your terminal.
   - *Expected*: Displays ShellCheck version (e.g. `version: 0.10.x`).
2. **VS Code In-Editor Verification**:
   - Open a shell script file (`test.sh`) containing:

     ```bash
     #!/usr/bin/env bash
     echo $foo
     ```

   - *Expected*: Diagnostic warning `SC2086: Double quote to prevent globbing and word splitting` appears inline and in the Problems panel within 2 seconds.

---

### Scenario B: markdownlint Validation

1. Open any Markdown file (`test.md`) with invalid heading progression:

   ```markdown
   # Heading 1
   ### Heading 3
   ```

2. *Expected*: Markdownlint flags rule `MD001/heading-increment` with yellow squiggly underline.

---

### Scenario C: Code Runner Execution

1. Open a simple script (e.g., Python `print("Hello from Code Runner")` or Bash `echo "Running in terminal"`).
2. Press `Ctrl+Alt+N` or click the "Run Code" button.
3. *Expected*: The code executes directly in the VS Code Integrated Terminal tab and prints output cleanly.

---

### Scenario D: CodeLLDB Debugger Initialization

1. Open the Run & Debug panel (`Ctrl+Shift+D`).
2. Verify "LLDB" appears as a selectable debug environment.
3. *Expected*: CodeLLDB loads without native ELF loader or missing library errors.

---

### Scenario E: Dependin Manifest Lens

1. Open a manifest file with dependencies (e.g., `Cargo.toml` or `package.json`).
2. *Expected*: Inline annotations display package version statuses and update hints.
