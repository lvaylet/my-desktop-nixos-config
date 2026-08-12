# Data Model: Local Gemma 4 Model Acceleration & Antigravity CLI Integration

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Spec**: [spec.md](spec.md)

## Entity Relationship Overview

```mermaid
erDiagram
    NIXOS_HOST ||--|| HARDWARE_RESOURCE_BUDGET : possesses
    NIXOS_HOST ||--|| OLLAMA_SERVICE : manages_daemon
    OLLAMA_SERVICE ||--|{ GEMMA_MODEL_ASSET : serves_on_demand
    OLLAMA_SERVICE ||--|| GPU_ACCELERATION_CONTEXT : utilizes
    USER_ENVIRONMENT ||--|| ANTIGRAVITY_CONFIG : declares
    ANTIGRAVITY_CONFIG ||--|| ANTIGRAVITY_CLI : provisions
    ANTIGRAVITY_CLI }|--|| OLLAMA_SERVICE : sends_requests_to

    HARDWARE_RESOURCE_BUDGET {
        int system_ram_gb "32"
        int gpu_vram_gb "16"
        string gpu_model "NVIDIA GeForce RTX 5070 Ti"
        int max_model_vram_gb "14"
        int reserved_gui_vram_gb "2"
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
        string home_manager_module "antigravity.nix"
    }

    ANTIGRAVITY_CONFIG {
        string package_name "antigravity-cli"
        string api_base "http://127.0.0.1:11434/v1"
        string default_model "gemma4:12b"
        boolean telemetry_disabled "true"
    }

    ANTIGRAVITY_CLI {
        string binary_path "$HOME/.nix-profile/bin/antigravity"
        string execution_mode "offline / local"
        string protocol "OpenAI-Compatible Chat Completions REST API"
    }
```

---

## Entities & Attributes

### 1. `HARDWARE_RESOURCE_BUDGET`
Defines the physical compute, memory, and acceleration boundaries on the `desktop-pc` workstation.
- **`system_ram_gb`** (integer): 32 GB total physical host RAM.
- **`gpu_vram_gb`** (integer): 16 GB dedicated GDDR7 VRAM on the NVIDIA GeForce RTX 5070 Ti.
- **`max_model_vram_gb`** (integer): Maximum target allocation for model weights (~13–14 GB).
- **`reserved_gui_vram_gb`** (integer): Minimum guaranteed unallocated VRAM (~2–3 GB) reserved for desktop display rendering and compositor operations.

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
- **`parameter_count`** (string): `12B` parameters.
- **`storage_location`** (path): `/var/lib/ollama/models/blobs/`.
- **`lifecycle`**: Downloaded on demand via `just download-model model="gemma4:12b"`.

### 4. `ANTIGRAVITY_CONFIG`
Represents the user-level Home Manager module configuration (`modules/home-manager/antigravity.nix`).
- **`enable`** (boolean): Activates Antigravity CLI in user profile (`true`).
- **`api_base`** (string): Base URL for model completions (`http://127.0.0.1:11434/v1`).
- **`model`** (string): Default model identifier (`gemma4:12b`).
- **`offline_mode`** (boolean): Enforces local loopback routing without cloud fallback (`true`).

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

    ServiceListening --> InferenceActive: Developer runs 'antigravity <prompt>'

    state InferenceActive {
        [*] --> LoadWeightsVRAM: Offload 100% Layers to 16GB VRAM (~13GB)
        LoadWeightsVRAM --> ProcessContext: Ingest Prompt & Code Context
        ProcessContext --> GenerateTokens: CUDA Stream Generation (~40+ tok/s)
        GenerateTokens --> StreamResponse: HTTP Stream to Antigravity CLI
    }

    InferenceActive --> IdleState: Completion Finished / Timeout
    IdleState --> [*]: System Shutdown
```
