# Phase 1: Data Model & Domain Entities

**Feature**: Portable Multi-Environment Development, Testing, and Deployment (`002-portable-dev-deploy`)
**Date**: 2026-08-12
**Status**: Completed

## 1. Domain Entities & Schemas

### 1.1 Development Environment Profile

Represents the developer workspace configuration across different host platforms and onboarding mechanisms.

```mermaid
classDiagram
    class DevEnvironmentProfile {
        +String environmentType // "nix-devshell" | "devbox"
        +List~String~ supportedSystems // "x86_64-linux", "aarch64-linux", "x86_64-darwin", "aarch64-darwin"
        +List~String~ packages // "just", "alejandra", "statix", "deadnix", "ripsecrets", "trufflehog", "nh"
        +Map~String,String~ shellHooks // pre-commit installation, welcome message
        +validate() Boolean
    }

    class MachineTarget {
        +String name // "desktop-pc" | "homelab" | "iso"
        +String architecture // "x86_64-linux"
        +String configPath // "./machines/<name>/configuration.nix"
        +String defaultSshHost // "homelab" | "desktop-pc"
        +buildToplevel() Derivation
    }

    class DeploymentExecution {
        +MachineTarget target
        +String action // "build" | "test" | "switch" | "boot"
        +String targetHost // "" (local) or SSH string (e.g. "homelab", "user@ip")
        +String buildHost // "" (local) or SSH string
        +Boolean useRemoteSudo // true for remote switch/boot/test
        +execute() Result
    }

    DevEnvironmentProfile --> DeploymentExecution : executes via CLI
    DeploymentExecution --> MachineTarget : applies configuration to
```

### Attributes & Types

| Entity | Attribute | Type | Description |
| :--- | :--- | :--- | :--- |
| **DevEnvironmentProfile** | `environmentType` | Enum (`nix-devshell`, `devbox`) | Method of environment initialization |
| | `supportedSystems` | List[String] | Architectures enabled in `flake.nix` and `devbox.json` |
| | `packages` | List[String] | Linters, formatters, and task runners bundled in the environment |
| | `shellHooks` | List[String] | Automated activation scripts (e.g., git hooks installation) |
| **MachineTarget** | `name` | String | Identifier matching a `nixosConfigurations.<name>` attribute |
| | `architecture` | String | System architecture of the target machine (e.g., `x86_64-linux`) |
| | `configPath` | String | Filesystem path to the host configuration entrypoint |
| **DeploymentExecution** | `action` | Enum (`build`, `test`, `switch`, `boot`) | Target lifecycle operation |
| | `targetHost` | Optional[String] | Remote SSH connection target; empty indicates local execution |
| | `buildHost` | Optional[String] | Remote host to perform derivation building (optional) |
| | `useRemoteSudo` | Boolean | Whether remote activation requires `sudo` privileges over SSH |

---

## 2. Lifecycle State Transitions

### 2.1 Deployment Execution State Machine

```mermaid
stateDiagram-v2
    [*] --> Initialized: Operator runs just command (switch/test/boot/build)

    Initialized --> LocalEvaluation: target == "" (local execution)
    Initialized --> RemoteEvaluation: target != "" (remote execution)

    LocalEvaluation --> CheckLocalNixOS: Verify /etc/NIXOS presence
    CheckLocalNixOS --> LocalExecution: Host is NixOS
    CheckLocalNixOS --> LocalAbort: Host is non-NixOS & action is switch/test/boot
    CheckLocalNixOS --> LocalBuildOnly: Host is non-NixOS & action is build

    LocalExecution --> LocalSuccess: nh os switch/test/boot succeeds
    LocalBuildOnly --> LocalSuccess: nix build toplevel succeeds
    LocalAbort --> ErrorState: Display informative error message

    RemoteEvaluation --> ValidateSSHConnection: Test SSH accessibility to targetHost
    ValidateSSHConnection --> BuildPhase: Target reachable & authorized
    ValidateSSHConnection --> NetworkError: Host unreachable or auth rejected

    BuildPhase --> TransferPhase: Derivation built (locally or on buildHost)
    TransferPhase --> ActivationPhase: Copy closure to target /nix/store
    ActivationPhase --> RemoteSuccess: nixos-rebuild activates generation
    ActivationPhase --> RollbackSafeState: Activation failure (previous generation remains active)

    LocalSuccess --> [*]
    RemoteSuccess --> [*]
    NetworkError --> ErrorState: Abort with connection diagnostics
    RollbackSafeState --> ErrorState: Abort without changing active bootloader
    ErrorState --> [*]
```

---

## 3. Validation & Invariant Rules

1. **Host Safety Invariant**: Repository scripts MUST NEVER invoke `nh os switch`, `nh os test`, or `nh os boot` on a non-NixOS operating system.
2. **Hermetic Environment Invariant**: Entering the environment via either `devbox shell` or `nix develop` MUST supply identical versions of `alejandra`, `statix`, `deadnix`, and `just`.
3. **Atomic Failure Invariant**: If a remote deployment fails at any phase (evaluation, build, transfer, or activation), the target machine MUST retain its active system generation without downtime or bootloader corruption.
4. **Zero-Secret Invariant**: Connection strings for remote hosts MUST NOT contain embedded passwords; SSH authentication MUST use public keys or active SSH agents.
