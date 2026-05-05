{pkgs, ...}: {
  home-manager.users.laurent.programs = {
    bat.enable = true; # A cat(1) clone with wings - https://github.com/sharkdp/bat
    direnv = {
      # A shell extension that can load and unload environment variables depending on the current directory - https://direnv.net/
      enable = true;
      enableZshIntegration = true;
    };
    eza = {
      # A modern alternative to ls - https://github.com/eza-community/eza
      enable = true;
      enableZshIntegration = true;
    };
    fd.enable = true; # A simple, fast and user-friendly alternative to 'find' - https://github.com/sharkdp/fd
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    gemini-cli.enable = true;
    jq.enable = true; # A lightweight and flexible command-line JSON processor - https://jqlang.github.io/jq/
    lazygit.enable = true; # A simple terminal UI for git commands - https://github.com/jesseduffield/lazygit
    nnn.enable = true; # n³ The unorthodox terminal file manager - https://github.com/jarun/nnn
    pyenv = {
      # Simple Python version management - https://github.com/pyenv/pyenv
      enable = true;
      enableZshIntegration = true;
    };
    ripgrep.enable = true; # Recursively search directories for a regex pattern while respecting your gitignore - https://github.com/BurntSushi/ripgrep
    ssh = {
      enable = true;
      # Check options here: https://home-manager-options.extranix.com/?query=programs.ssh
      enableDefaultConfig = false;
      matchBlocks = {
        "rpi3" = {
          hostname = "192.168.1.68";
          user = "pi";
          identityFile = "~/.ssh/id_ed25519";
          checkHostIP = false; # = StrictHostKeyChecking No
        };
        "homelab-vm" = {
          hostname = "192.168.1.194";
          user = "core";
          identityFile = "~/.ssh/id_ed25519";
          checkHostIP = false; # = StrictHostKeyChecking No
        };
      };
    };
    yazi = {
      # 💥 Blazing fast terminal file manager written in Rust, based on async I/O - https://github.com/sxyazi/yazi
      enable = true;
      enableZshIntegration = true;
      package = pkgs.yazi;
      shellWrapperName = "y";
    };
  };
}
