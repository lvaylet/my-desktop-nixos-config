build:
  sudo nixos-rebuild build --flake .#nixos-desktop

switch:
  sudo nixos-rebuild switch --flake .#nixos-desktop

format:
  alejandra .
