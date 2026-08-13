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
    '';

    sessionVariables = {
      OLLAMA_API_BASE = "http://127.0.0.1:11434";
    };
  };
}
