# Interface Contract: Ollama API Integration for OpenCoder

**Feature Branch**: `005-add-opencoder` | **Date**: 2026-08-13 | **Spec**: [spec.md](../spec.md)

## 1. Network & Protocol Specification

- **Protocol**: HTTP/1.1 REST + Server-Sent Events (SSE) streaming
- **Host / Binding**: `127.0.0.1` (loopback only)
- **Port**: `11434`
- **Base URL**: `http://127.0.0.1:11434/v1`

## 2. Consumed Endpoints

| HTTP Method | Path | Purpose |
| :--- | :--- | :--- |
| `GET` | `/v1/models` | List available models in Ollama |
| `POST` | `/v1/chat/completions` | Stream OpenAI-compatible chat completions with local Gemma 4 model |

## 3. Payload Parameters

- `model`: `"gemma4:12b"`
- `stream`: `true`
- `temperature`: float (optional)
- `max_tokens`: integer `<= 8192`
