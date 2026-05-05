{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations = {
    desktop-pc = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs self;};
      modules = [
        # The shared dendritic base
        ../features

        # Host specific configuration
        ../hosts/desktop-pc

        # Global modules that are always needed
        inputs.home-manager.nixosModules.home-manager
        inputs.nvf.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            # Dendritic pattern: home-manager is also configured in features/
          };
        }
      ];
    };
  };
}
