_: {
  nix = {
    settings = {
      # Enable Flakes and modern Nix.
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # For sudoless `cachix`.
      trusted-users = ["root" "laurent"];
    };

    # Garbage collection and store optimization.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings.auto-optimise-store = true;
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;
}
