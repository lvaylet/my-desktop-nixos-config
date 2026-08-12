# Contract: Ollama Inference Service & API Interface

**Feature Branch**: `004-local-gemma-antigravity` | **Date**: 2026-08-12 | **Spec**: [spec.md](../spec.md)

## 1. NixOS Service Configuration Contract

The system service must be declared in `modules/nixos/ollama.nix` conforming to standard NixOS options:

```nix
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "127.0.0.1";
    port = 11434;
    loadModels = [
      "gemma4:12b"
    ];
  };
}
```

| Option | Value | Purpose |
|---|---|---|
| `services.ollama.enable` | `true` | Enables systemd `ollama.service` daemon |
| `services.ollama.acceleration` | `"cuda"` | Enforces NVIDIA CUDA compilation and runtime GPU offload |
| `services.ollama.host` | `"127.0.0.1"` | Restricts network binding strictly to local loopback |
| `services.ollama.port` | `11434` | Default communication port |
| `services.ollama.loadModels` | `[ "gemma4:12b" ]` | Declaratively ensures `gemma4:12b` is downloaded and primed on service startup |

---

## 2. OpenAI-Compatible API Endpoint Contract

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

#### Streamed Response Chunk (`text/event-stream`)
```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion.chunk",
  "created": 1723498800,
  "model": "gemma4:12b",
  "choices": [
    {
      "index": 0,
      "delta": {
        "content": "def"
      },
      "finish_reason": null
    }
  ]
}
```

---

## 3. Health & Readiness Endpoints Contract

| Endpoint | Method | Expected Status | Response Summary |
|---|---|---|---|
| `http://127.0.0.1:11434/` | `GET` | `200 OK` | Text: `"Ollama is running"` |
| `http://127.0.0.1:11434/api/tags` | `GET` | `200 OK` | JSON listing installed models including `gemma4:12b` |
| `http://127.0.0.1:11434/api/show` | `POST` | `200 OK` | JSON metadata detailing model architecture, parameters, and quantization (`q8_0`) |
