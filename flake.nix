{
  description = "My NixOS Desktop Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:mightyiam/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage Neovim with nvf.
    # References:
    # - https://www.youtube.com/watch?v=uP9jDrRvAwM
    # - https://nvf.notashelf.dev/#sec-nixos-flakes-usage
    # - https://www.youtube.com/watch?v=VTIGSxpzlIM
    nvf = {
      url = "github:NotAShelf/nvf";
      # You can override the input nixpkgs to follow your system's
      # instance of nixpkgs. This is safe to do as nvf does not depend
      # on a binary cache.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Seamless integration of Git hooks with Nix.
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = inputs @ {
    flake-parts,
    import-tree,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      imports = [
        (import-tree ./parts)
      ];
    };
}
