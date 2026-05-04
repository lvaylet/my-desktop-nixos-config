build:
  nixos-rebuild build --flake .#nixos-desktop

switch:
  sudo nixos-rebuild switch --flake .#nixos-desktop

format:
  alejandra .

collect-garbage:
  nix-collect-garbage

delete-old-generations:
  nix-collect-garbage --delete-old
