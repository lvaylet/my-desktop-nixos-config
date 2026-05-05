_: {
  home-manager.users.laurent.programs.git = {
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
}
