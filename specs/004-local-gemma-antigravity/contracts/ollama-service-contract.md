# Contract: Ollama Inference Service & API Interface

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Spec**: [spec.md](../spec.md)

## 1. NixOS Service Configuration Contract

The system service must be declared in `modules/nixos/ollama.nix` conforming to standard NixOS options:

```nix
{pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "127.0.0.1";
    port = 11434;
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_KEEP_ALIVE = "5m";
    };
  };
}
```

| Option | Value | Purpose |
|---|---|---|
| `services.ollama.enable` | `true` | Enables systemd `ollama.service` daemon |
| `services.ollama.package` | `pkgs.ollama-cuda` | Uses the CUDA-compiled Ollama binary for NVIDIA hardware offloading |
| `services.ollama.host` | `"127.0.0.1"` | Restricts network binding strictly to local loopback |
| `services.ollama.port` | `11434` | Default communication port |

---

## 2. On-Demand Model Download Contract

Model acquisition is triggered on demand via `just download-model model="gemma4:12b"`:

### Endpoint: `POST /api/pull`

#### Request Payload
```json
{
  "name": "gemma4:12b"
}
```

---

## 3. OpenAI-Compatible API Endpoint Contract

Ollama exposes an OpenAI-compatible REST API interface over `http://127.0.0.1:11434/v1`:

### Endpoint: `POST /v1/chat/completions`

#### Request Payload
```json
{
  "model": "gemma4:12b",
  "messages": [
    {
      "role": "system",
      "content": "You are an expert pair programmer assisting with code refactoring."
    },
    {
      "role": "user",
      "content": "Refactor this function to be pure and immutable."
    }
  ],
  "stream": true,
  "temperature": 0.2
}
```

---

## 4. Health & Readiness Endpoints Contract

| Endpoint | Method | Expected Status | Response Summary |
|---|---|---|---|
| `http://127.0.0.1:11434/` | `GET` | `200 OK` | Text: `"Ollama is running"` |
| `http://127.0.0.1:11434/api/tags` | `GET` | `200 OK` | JSON listing installed models including `gemma4:12b` |
| `http://127.0.0.1:11434/api/show` | `POST` | `200 OK` | JSON metadata detailing model architecture, parameters, and quantization (`q8_0`) |
