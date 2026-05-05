_: {
  home-manager.users.laurent = {
    programs.zsh = {
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

    home.file.".config/starship.toml".source = ../../dotfiles/starship.toml;

    programs.starship = {
      # The minimal, blazing-fast, and infinitely customizable prompt for any shell! - https://starship.rs/guide/
      enable = true;
      enableZshIntegration = true;
    };
  };
}
