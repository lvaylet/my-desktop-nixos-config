{lib, ...}: {
  imports = lib.filter (
    path: let
      baseName = builtins.baseNameOf path;
    in
      lib.hasSuffix ".nix" baseName
      && (baseName != "default.nix")
      && !(lib.hasPrefix "_" baseName)
  ) (lib.filesystem.listFilesRecursive ./.);
}
