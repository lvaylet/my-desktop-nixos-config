{pkgs, ...}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "laurent";
  home.homeDirectory = "/home/laurent";

  home.packages = with pkgs; [
    # Internet
    # ---
    google-chrome

    # Productivity
    # ---
    obsidian

    # Nix
    # ---
    nixd # Nix Language Server, based on Nix libraries - https://github.com/nix-community/nixd
    nil # Nix Language Server, an incremental analysis assistant for writing in Nix. - https://github.com/oxalica/nil
  ];

  programs = {
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
    git = {
      enable = true;
      settings = {
        user = {
          name = "Laurent VAYLET";
          email = "laurent.vaylet@gmail.com";
        };
        init.defaultBranch = "main";

        # Popular Git Config Options - https://jvns.ca/blog/2024/02/16/popular-git-config-options/
        color.ui = "auto";
        commit.verbose = true;
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          mnemonicPrefix = true;
          renames = true;
        };
        fetch.prune = true;
        help.autocorrect = 10;
        merge = {
          conflictstyle = "zdiff3";
          tool = "meld";
        };
        pull = {
          ff = "only";
          rebase = true;
        };
        push.autoSetupRemote = true;
        rebase = {
          autosquash = true;
          autostash = true;
        };
        rerere.enable = true;
        # url."git@github.com:".insteadOf = "https://github.com/"; # Be careful with this. Some repositories do not support cloning over SSH, for example https://github.com/oxalica/nil.
      };
    };
    jq.enable = true; # A lightweight and flexible command-line JSON processor - https://jqlang.github.io/jq/
    lazygit.enable = true; # A simple terminal UI for git commands - https://github.com/jesseduffield/lazygit
    neovim = {
      # An hyperextensible Vim-based text editor - https://neovim.io/
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    nnn.enable = true; # n³ The unorthodox terminal file manager - https://github.com/jarun/nnn
    pyenv = {
      # Simple Python version management - https://github.com/pyenv/pyenv
      enable = true;
      enableZshIntegration = true;
    };
    ripgrep.enable = true; # Recursively search directories for a regex pattern while respecting your gitignore - https://github.com/BurntSushi/ripgrep
    vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide # Nix IDE
          bbenoist.nix # Nix Language Support for Visual Studio Code
          kamadorueda.alejandra # The Uncompromising Nix Code Formatter
        ];
        userSettings = {
          # This property will be used to generate `settings.json`:
          # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
          "editor.fontSize" = 14;
          "editor.formatOnSave" = true;
          "files.autoSave" = "afterDelay";
          "diffEditor.hideUnchangedRegions.enabled" = true;

          # Nix
          "[nix]" = {
            "editor.tabSize" = 2;
            "editor.defaultFormatter" = "kamadorueda.alejandra";
            "editor.formatOnPaste" = true;
            "editor.formatOnSave" = true;
            "editor.formatOnType" = false;
          };
          "alejandra.program" = "alejandra";
          "nix.enableLanguageServer" = true; # Enable LSP.
          # "nix.formatterPath" = "alejandra"; # "nixfmt", "alejandra"
          "nix.serverPath" = "nil"; # The path to the LSP server executable: "nil", "nixd", or ["executable", "argument1", ...]
          # "nix.serverSettings.nil.formatting.command" = [ "nixfmt" ];
        };
      };
    };
    yazi = {
      # 💥 Blazing fast terminal file manager written in Rust, based on async I/O - https://github.com/sxyazi/yazi
      enable = true;
      enableZshIntegration = true;
      package = pkgs.yazi;
    };
    # zellij = { # A terminal workspace with batteries included - https://github.com/zellij-org/zellij
    #   enable = true;
    #   enableZshIntegration = true;
    # };
    zsh = {
      # An interactive login shell and a command interpreter for shell scripting - https://www.zsh.org/
      enable = true;
      autocd = true; # Automatically enter into a directory if typed directly into shell.
      defaultKeymap = "viins"; # The default base keymap to use. One of `emacs` (= `-e`), `vicmd` (= `-a`) or `viins` (= `-v`).
      zplug = {
        # 🌺 A next-generation plugin manager for zsh - https://github.com/zplug/zplug
        enable = true;
        plugins = [
          {name = "zsh-users/zsh-autosuggestions";}
          {name = "zsh-users/zsh-completions";}
          {name = "zsh-users/zsh-syntax-highlighting";}
          {
            name = "plugins/git";
            tags = ["from:oh-my-zsh"];
          }
          {name = "MichaelAquilina/zsh-you-should-use";}
          {
            name = "hlissner/zsh-autopair";
            tags = ["defer:2"];
          }
        ];
      };
      shellAliases = {
        c = "clear";
        x = "exit";
        r = "source ~/.zshrc";

        # `ls` / `eza`
        # See: https://www.avonture.be/blog/linux-eza/
        ls = "eza --group --group-directories-first --icons --header --time-style long-iso";
        ll = "eza --group --group-directories-first --icons --header --time-style long-iso --long";
        llt = "eza --group --group-directories-first --icons --header --time-style long-iso --long --tree";
        la = "eza --group --group-directories-first --icons --header --time-style long-iso --long --all";
        lat = "eza --group --group-directories-first --icons --header --time-style long-iso --long --all --tree";

        cat = "bat"; # A cat(1) clone with wings
        y = "yazi"; # 💥 Blazing fast terminal file manager written in Rust, based on async I/O

        take = "() { mkdir -p \"$1\"; cd \"$1\"; }"; # Create a directory tree and `cd` into it.

        # History
        h = "history -10"; # last 10 history commands
        hc = "history -c"; # clear history
        hh = "history | cut -c 8-";
        hg = "history | grep "; # + command to search for

        # Aliases
        ag = "alias | grep "; # + alias to search for

        # Utils
        b = "btop";
        d = "ncdu --exclude /mnt --color dark "; # + path

        # Home Manager
        # hms = "cd ~/.config/home-manager; git pull; home-manager switch; cd -";
      };
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # ".config/starship.toml".source = dotfiles/starship.toml;

    # The configuration files below are not compatible with Yazi 0.3.3 (Nixpkgs 2024-09-04) installed by Home Manager. Use flakes instead to access the latest, bleeding edge version?
    # ".config/yazi/yazi.toml".source = dotfiles/yazi/yazi.toml;
    # ".config/yazi/keymap.toml".source = dotfiles/yazi/keymap.toml;
    # ".config/yazi/theme.toml".source = dotfiles/yazi/theme.toml;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05";
}
