{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      aider-chat
    ];

    file.".aider.conf.yml".text = ''
      model: ollama/gemma4:12b
      dark-mode: true
      auto-commits: true
      show-diffs: true
      set-env:
        - OLLAMA_API_BASE=http://127.0.0.1:11434
    '';

    file.".aider.model.settings.yml".text = ''
      - name: ollama/gemma4:12b
        extra_params:
          num_ctx: 8192
      - name: ollama_chat/gemma4:12b
        extra_params:
          num_ctx: 8192
    '';

    file.".aider.model.metadata.json".text = ''
      {
        "ollama/gemma4:12b": {
          "max_tokens": 8192,
          "max_input_tokens": 8192,
          "max_output_tokens": 8192,
          "input_cost_per_token": 0.0,
          "output_cost_per_token": 0.0,
          "litellm_provider": "ollama",
          "mode": "chat"
        },
        "ollama_chat/gemma4:12b": {
          "max_tokens": 8192,
          "max_input_tokens": 8192,
          "max_output_tokens": 8192,
          "input_cost_per_token": 0.0,
          "output_cost_per_token": 0.0,
          "litellm_provider": "ollama",
          "mode": "chat"
        }
      }
    '';

    sessionVariables = {
      OLLAMA_API_BASE = "http://127.0.0.1:11434";
    };
  };
}
