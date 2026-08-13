# Data Model: Local Gemma 4 Model Acceleration & Aider CLI Integration

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Updated**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Entity Relationship Overview

```mermaid
erDiagram
    NIXOS_HOST ||--|| HARDWARE_RESOURCE_BUDGET : possesses
    NIXOS_HOST ||--|| OLLAMA_SERVICE : manages_daemon
    OLLAMA_SERVICE ||--|{ GEMMA_MODEL_ASSET : serves_on_demand
    OLLAMA_SERVICE ||--|| GPU_ACCELERATION_CONTEXT : utilizes
    USER_ENVIRONMENT ||--|| AIDER_CONFIG : declares
    AIDER_CONFIG ||--|| AIDER_CLI : provisions
    AIDER_CLI }|--|| OLLAMA_SERVICE : sends_requests_to

    HARDWARE_RESOURCE_BUDGET {
        int system_ram_gb "32"
        int gpu_vram_gb "16"
        string gpu_model "NVIDIA GeForce RTX 5070 Ti"
        int model_weights_vram_gb "13"
        int kv_cache_8k_vram_gb "1.5"
        int reserved_gui_vram_gb "1.5"
    }

    OLLAMA_SERVICE {
        string service_name "ollama"
        boolean enabled "true"
        string package "pkgs.ollama-cuda"
        string listen_address "127.0.0.1:11434"
        string state_directory "/var/lib/ollama"
    }

    GEMMA_MODEL_ASSET {
        string model_tag "gemma4:12b"
        string architecture "gemma"
        string parameter_size "12B"
        string quantization "q8_0"
        int context_window_tokens "8192"
        int memory_footprint_gb "13"
        string storage_path "/var/lib/ollama/models"
        string download_method "just download-model"
    }

    GPU_ACCELERATION_CONTEXT {
        string driver_type "nvidia-open"
        string compute_runtime "CUDA"
        int offloaded_layers_pct "100"
        boolean memory_fallback_enabled "true"
    }

    USER_ENVIRONMENT {
        string user_name "vars.userName"
        string shell "zsh / bash"
        string home_manager_module "aider.nix"
    }

    AIDER_CONFIG {
        string package_name "pkgs.aider-chat"
        string config_file "~/.aider.conf.yml"
        string model "ollama/gemma4:12b"
        string api_base "http://127.0.0.1:11434"
        int context_window_tokens "8192"
        boolean auto_commits "true"
        boolean dark_mode "true"
    }

    AIDER_CLI {
        string binary_path "$HOME/.nix-profile/bin/aider"
        string execution_mode "offline / local"
        string protocol "Ollama REST API / OpenAI-Compatible API"
    }
```

---

## Entities & Attributes

### 1. `HARDWARE_RESOURCE_BUDGET`
Defines the physical compute, memory, and acceleration boundaries on the `desktop-pc` workstation.
- **`system_ram_gb`** (integer): 32 GB total physical host RAM.
- **`gpu_vram_gb`** (integer): 16 GB dedicated GDDR7 VRAM on the NVIDIA GeForce RTX 5070 Ti.
- **`model_weights_vram_gb`** (integer): ~12.5–13.0 GB VRAM for 8-bit quantized 12B model weights.
- **`kv_cache_8k_vram_gb`** (float): ~1.2–1.5 GB VRAM for 8,192 token attention/KV cache.
- **`reserved_gui_vram_gb`** (float): ~1.5–2.0 GB unallocated VRAM guaranteed for Wayland/X11 desktop compositing.

### 2. `OLLAMA_SERVICE`
Represents the system-level NixOS background daemon (`modules/nixos/ollama.nix`).
- **`enable`** (boolean): Activates the systemd `ollama.service` unit (`true`).
- **`package`** (package): `pkgs.ollama-cuda` (CUDA-accelerated binary).
- **`host`** (string): Bind address (`"127.0.0.1"`).
- **`port`** (integer): TCP port (`11434`).
- **`home`** (path): Persistent state directory (`/var/lib/ollama`).

### 3. `GEMMA_MODEL_ASSET`
Represents the local large language model weights and configuration.
- **`model_tag`** (string): Canonical model identifier (`gemma4:12b`).
- **`quantization`** (string): 8-bit precision profile (`q8_0`).
- **`context_window_tokens`** (integer): `8192` (8k).
- **`parameter_count`** (string): `12B` parameters.
- **`storage_location`** (path): `/var/lib/ollama/models/blobs/`.
- **`lifecycle`**: Downloaded on demand via `just download-model model="gemma4:12b"`.

### 4. `AIDER_CONFIG`
Represents the user-level Home Manager module configuration (`modules/home-manager/aider.nix`).
- **`package`**: `pkgs.aider-chat` installed in user environment.
- **`config_file`**: `~/.aider.conf.yml` specifying default model (`ollama/gemma4:12b`), dark mode, and git auto-commits.
- **`environment`**: `OLLAMA_API_BASE=http://127.0.0.1:11434`.

---

## State Transition & Execution Flow

```mermaid
stateDiagram-v2
    [*] --> SystemBoot: Machine Boot / Activation (desktop-pc)

    state SystemBoot {
        [*] --> InitNvidia: Load NVIDIA Driver & CUDA Runtime
        InitNvidia --> StartOllama: systemctl start ollama.service
        StartOllama --> ServiceListening: Listening on 127.0.0.1:11434 (Starts Instantly)
    }

    ServiceListening --> ModelAcquisition: On Demand 'just download-model'
    ModelAcquisition --> ServiceListening: Model Stored in /var/lib/ollama/models

    state ServiceListening {
        [*] --> IdleState: Idle (0% Compute, ~200MB Baseline VRAM)
    }

    ServiceListening --> InferenceActive: Developer runs 'aider' or 'just aider'

    state InferenceActive {
        [*] --> LoadWeightsVRAM: Offload 100% Layers to 16GB VRAM (~13GB)
        LoadWeightsVRAM --> AllocKVCache: Allocate 8k KV Cache (~1.5GB in VRAM)
        AllocKVCache --> ProcessContext: Ingest Repo Map, File Context & Prompts
        ProcessContext --> GenerateTokens: CUDA Stream Generation (~40+ tok/s)
        GenerateTokens --> ApplyEdits: Interactive Diffs & Git Commits in TUI
    }

    InferenceActive --> IdleState: Session Ended / Ollama Timeout
    IdleState --> [*]: System Shutdown
```
