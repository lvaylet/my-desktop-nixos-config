_: {
  home-manager.users.laurent = {
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "25.11";

    home = {
      username = "laurent";
      homeDirectory = "/home/laurent";
    };

    # Allow fontconfig to discover fonts and configurations installed through `home.packages` and `nix-env`.
    # Source: https://mynixos.com/home-manager/option/fonts.fontconfig.enable
    fonts.fontconfig.enable = true;
  };
}
