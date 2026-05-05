{self, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # Enter a development shell with `nix develop`.
    # The hooks will be installed automatically.
    # Or run pre-commit manually with `nix develop -c pre-commit run --all-files`
    devShells.default = let
      inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
    in
      pkgs.mkShell {
        inherit shellHook;
        buildInputs = enabledPackages;
      };
  };
}
