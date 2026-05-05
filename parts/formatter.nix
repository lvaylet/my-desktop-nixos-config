{self, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # Run the hooks with `nix fmt`.
    formatter = let
      inherit (self.checks.${system}.pre-commit-check) config;
      inherit (config) package configFile;
      script = ''
        ${pkgs.lib.getExe package} run --all-files --config ${configFile}
      '';
    in
      pkgs.writeShellScriptBin "pre-commit-run" script;
  };
}
