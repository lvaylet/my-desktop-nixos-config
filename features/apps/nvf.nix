_: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        viAlias = false;
        vimAlias = true;

        theme = {
          enable = true;
          name = "nord";
          style = "dark";
          transparent = true;
        };

        statusline.lualine.enable = true; # Status line
        telescope.enable = true; # Fuzzy finder
        autocomplete.nvim-cmp.enable = true; # Fancy completion menu

        lsp = {
          enable = true;
          formatOnSave = true;
        };
        languages = {
          enableTreesitter = true;

          nix = {
            enable = true;
            lsp = {
              enable = true;
              servers = ["nixd"];
            };
            format = {
              enable = true;
              type = ["alejandra"];
            };
            extraDiagnostics = {
              enable = true;
              types = ["statix" "deadnix"];
            };
          };
          typescript.enable = true;
          rust.enable = true;
        };
      };
    };
  };
}
