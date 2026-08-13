# run `just --list`
default:
  just --list

###################################
# (Re)build
###################################

# rebuild
[group('(re)build')]
build configuration="desktop-pc" target="":
  #!/usr/bin/env bash
  set -euo pipefail
  if [ -z "{{target}}" ]; then
    if command -v nh >/dev/null 2>&1 && [ -e /etc/NIXOS ]; then
      nh os build .#{{configuration}}
    else
      nix build .#nixosConfigurations.{{configuration}}.config.system.build.toplevel
    fi
  else
    nixos-rebuild build --flake .#{{configuration}} --target-host {{target}}
  fi

# rebuild and switch
[group('(re)build')]
switch configuration="desktop-pc" target="":
  #!/usr/bin/env bash
  set -euo pipefail
  if [ -z "{{target}}" ]; then
    if [ ! -e /etc/NIXOS ]; then
      echo "Error: Local system is not NixOS. To deploy to a remote NixOS host, specify the target parameter, e.g.: just switch {{configuration}} <target-host>" >&2
      exit 1
    fi
    nh os switch .#{{configuration}}
  else
    nixos-rebuild switch --flake .#{{configuration}} --target-host {{target}} --use-remote-sudo
  fi

# rebuild and switch after boot
[group('(re)build')]
boot configuration="desktop-pc" target="":
  #!/usr/bin/env bash
  set -euo pipefail
  if [ -z "{{target}}" ]; then
    if [ ! -e /etc/NIXOS ]; then
      echo "Error: Local system is not NixOS. To set boot entry on a remote NixOS host, specify the target parameter, e.g.: just boot {{configuration}} <target-host>" >&2
      exit 1
    fi
    nh os boot .#{{configuration}}
  else
    nixos-rebuild boot --flake .#{{configuration}} --target-host {{target}} --use-remote-sudo
  fi

# rebuild and activate but not switch
[group('(re)build')]
test configuration="desktop-pc" target="":
  #!/usr/bin/env bash
  set -euo pipefail
  if [ -z "{{target}}" ]; then
    if [ ! -e /etc/NIXOS ]; then
      echo "Error: Local system is not NixOS. To test on a remote NixOS host, specify the target parameter, e.g.: just test {{configuration}} <target-host>" >&2
      exit 1
    fi
    nh os test .#{{configuration}}
  else
    nixos-rebuild test --flake .#{{configuration}} --target-host {{target}} --use-remote-sudo
  fi

# build custom ISO image with SSH access for remote installations
[group('(re)build')]
build-iso:
  nix build .#nixosConfigurations.iso.config.system.build.isoImage

###################################
# Dev Utils
###################################

# format code recursively
[group('dev-utils')]
fmt:
  nix fmt .

# run linters
[group('dev-utils')]
lint:
  deadnix
  statix check

# fix warnings reported by linters
[group('dev-utils')]
fix:
  deadnix --edit
  statix fix

###################################
# Flake Management
###################################

# update all inputs and `flake.lock` file
[group('flake-management')]
up:
  nix flake update

# show the flake outputs
[group('flake-management')]
show:
  nix flake show

# check whether the flake evaluates and run its tests
[group('flake-management')]
check:
  nix flake check

###################################
# Garbage Collection
###################################

# delete all unreachable store objects
[group('garbage-collection')]
collect-garbage:
  nix-collect-garbage

# delete all unreachable store objects and old generations of profiles
[group('garbage-collection')]
delete-old-generations:
  nix-collect-garbage --delete-old

# clean the current user's profiles
[group('garbage-collection')]
clean keep="1":
  #!/usr/bin/env bash
  set -euo pipefail
  if command -v nh >/dev/null 2>&1 && [ -e /etc/NIXOS ]; then
    nh clean user --keep {{keep}} # keep at least this number of generations
  else
    nix-collect-garbage --delete-older-than {{keep}}d 2>/dev/null || nix-collect-garbage
  fi

# clean all profiles
[group('garbage-collection')]
clean-all keep="1":
  #!/usr/bin/env bash
  set -euo pipefail
  if command -v nh >/dev/null 2>&1 && [ -e /etc/NIXOS ]; then
    nh clean all --keep {{keep}} # keep at least this number of generations
  else
    nix-collect-garbage --delete-old
  fi

###################################
# Local AI & Model Tooling
###################################

# show Ollama systemd service status
[group('local-ai')]
ollama-status:
  systemctl status ollama.service

# follow Ollama service logs
[group('local-ai')]
ollama-logs:
  journalctl -u ollama.service -f

# list installed local models
[group('local-ai')]
ollama-models:
  curl -s http://127.0.0.1:11434/api/tags | jq .

# download model weights on demand
[group('local-ai')]
download-model model="gemma4:12b":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Downloading model '{{model}}' via Ollama..."
  if command -v ollama >/dev/null 2>&1; then
    ollama pull {{model}}
  else
    curl -X POST http://127.0.0.1:11434/api/pull -d '{"name": "{{model}}"}'
  fi

# check NVIDIA GPU and VRAM utilization
[group('local-ai')]
gpu-status:
  nvidia-smi

# test local Gemma 4 12B model inference
[group('local-ai')]
test-inference prompt="Write a short Nix expression.":
  curl -s http://127.0.0.1:11434/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{"model": "gemma4:12b", "messages": [{"role": "user", "content": "{{prompt}}"}], "stream": false}' | jq .

# launch interactive Aider AI pair-programming session with local Gemma 4 model
[group('local-ai')]
aider *args="":
  aider {{args}}

# launch Aider in architect mode with local Gemma 4 model
[group('local-ai')]
aider-architect *args="":
  aider --architect {{args}}
