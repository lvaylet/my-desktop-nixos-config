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
