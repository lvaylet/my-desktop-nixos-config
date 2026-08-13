{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      opencode
    ];

    file.".config/opencode/config.json".text = ''
      {
        "$schema": "https://opencode.ai/config.json",
        "model": "ollama/gemma4:12b",
        "provider": {
          "ollama": {
            "npm": "@ai-sdk/openai",
            "options": {
              "baseURL": "http://127.0.0.1:11434/v1"
            },
            "models": {
              "gemma4:12b": {
                "name": "gemma4:12b",
                "limit": {
                  "context": 8192,
                  "output": 8192
                }
              }
            }
          }
        }
      }
    '';
  };
}
