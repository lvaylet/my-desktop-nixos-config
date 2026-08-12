# Tasks: Portable Multi-Environment Development, Testing, and Deployment

**Input**: Design documents from [`specs/002-portable-dev-deploy/`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/specs/002-portable-dev-deploy/)
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/cli-contract.md](contracts/cli-contract.md), [contracts/devbox-contract.md](contracts/devbox-contract.md), [quickstart.md](quickstart.md)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure for multi-environment tooling

- [X] T001 Initialize Devbox configuration for cross-platform onboarding in [`devbox.json`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/devbox.json) per [`devbox-contract.md`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/specs/002-portable-dev-deploy/contracts/devbox-contract.md)
- [X] T002 Expand multi-system architecture support in [`flake.nix`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/flake.nix) to include `aarch64-linux`, `x86_64-darwin`, and `aarch64-darwin` for `checks`, `formatter`, and `devShells`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core toolchain and recipe helpers required before user story operations

**⚠️ CRITICAL**: Must complete before user story implementation begins

- [X] T003 Update `devShells.default` in [`flake.nix`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/flake.nix) to ensure all core developer tools (`just`, `nh`, linters) and git pre-commit hooks are exposed on shell entry
- [X] T004 Implement environment detection helper logic (detecting `/etc/NIXOS` and command availability) for operational recipes in [`justfile`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile)

**Checkpoint**: Foundation ready — devShell and recipe helpers established.

---

## Phase 3: User Story 1 - Developer Environment Portability & Onboarding Across Any OS (Priority: P1) 🎯 MVP

**Goal**: Enable contributors on any OS (NixOS, non-NixOS Linux, macOS, Windows WSL) to enter a reproducible dev environment via Devbox or `nix develop` with full toolchain parity.

**Independent Test**: Enter `devbox shell` or `nix develop` on a clean environment, execute `just fmt` and `just lint`, and confirm all linters and git hooks run cleanly.

### Implementation for User Story 1

- [X] T005 [US1] Configure Devbox shell scripts and initialization hooks in [`devbox.json`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/devbox.json)
- [X] T006 [P] [US1] Format and validate all Nix expressions with Alejandra across the flake in [`flake.nix`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/flake.nix)
- [X] T007 [US1] Test multi-platform flake check evaluation via `nix flake check` in [`flake.nix`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/flake.nix)

**Checkpoint**: User Story 1 complete — cross-platform development environment functional via both Devbox and Nix Flakes.

---

## Phase 4: User Story 2 - Remote Target Deployment from Any Linux Host (Priority: P2)

**Goal**: Enable operators on any Linux host (local or remote, NixOS or non-NixOS) to safely deploy system configurations (`switch`, `test`, `boot`) to remote NixOS targets over SSH using `nixos-rebuild`.

**Independent Test**: Execute `just switch configuration="homelab" target="homelab"` and verify `nixos-rebuild switch --flake .#homelab --target-host homelab --use-remote-sudo` is dispatched, while local switch without target enforces `/etc/NIXOS` check.

### Implementation for User Story 2

- [X] T008 [US2] Implement parameterized `switch` recipe with `target` parameter and `/etc/NIXOS` safety guard in [`justfile`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile)
- [X] T009 [US2] Implement parameterized `test` recipe with `target` parameter and remote non-switching activation in [`justfile`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile)
- [X] T010 [US2] Implement parameterized `boot` recipe with `target` parameter and remote bootloader entry creation in [`justfile`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile)

**Checkpoint**: User Story 2 complete — remote deployments operational over SSH with local non-NixOS safety guards.

---

## Phase 5: User Story 3 - Remote and Local Testing & Verification Without Host OS Coupling (Priority: P3)

**Goal**: Enable building and dry-run verification of system closures on non-NixOS Linux workstations without requiring root or modifying host state.

**Independent Test**: Execute `just build configuration="homelab"` on a non-NixOS host and verify `nix build .#nixosConfigurations.homelab.config.system.build.toplevel` runs cleanly to produce `./result`.

### Implementation for User Story 3

- [X] T011 [US3] Update `build` recipe in [`justfile`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile) to support unprivileged `system.build.toplevel` on non-NixOS hosts and remote builds when `target` is provided
- [X] T012 [P] [US3] Verify unprivileged derivation build for all machine configurations (`desktop-pc`, `homelab`, `iso`) via [`justfile`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile)

**Checkpoint**: User Story 3 complete — unprivileged local builds and remote builds verified across all target configurations.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation updates and end-to-end verification

- [X] T013 [P] Update repository documentation with Devbox setup instructions, remote deployment examples, and platform support matrix in [`README.md`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/README.md)
- [X] T014 Run full quickstart validation scenarios per [`quickstart.md`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/specs/002-portable-dev-deploy/quickstart.md) via [`justfile`](file:///home/lvaylet/workspace/github.com/lvaylet/my-nixos-configurations/justfile)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion (MVP)
- **User Story 2 (Phase 4)**: Depends on Foundational phase completion
- **User Story 3 (Phase 5)**: Depends on Foundational phase completion
- **Polish (Phase 6)**: Depends on completion of all user stories

### Parallel Opportunities

- `T001` and `T002` can be drafted in parallel
- `T006` and `T007` can execute in parallel
- `T012` and `T013` can run in parallel during polish/verification

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (`T001`, `T002`)
2. Complete Phase 2: Foundational (`T003`, `T004`)
3. Complete Phase 3: User Story 1 (`T005`, `T006`, `T007`)
4. **VALIDATE MVP**: Verify Devbox shell and `nix develop` environments initialize cleanly with all linters and formatters available.

### Incremental Delivery

1. Deliver MVP (US1: Cross-platform dev environments)
2. Add US2 (Remote deployments via `just switch/test/boot <config> <target>`)
3. Add US3 (Unprivileged local builds on non-NixOS Linux)
4. Finalize Polish (Docs & full quickstart walkthrough)
