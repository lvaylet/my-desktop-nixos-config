build:
  nixos-rebuild build --flake .#nixos-desktop

build-nh:
  nh os build .

switch:
  sudo nixos-rebuild switch --flake .#nixos-desktop

switch-nh:
  nh os switch .

format:
  alejandra .

collect-garbage:
  nix-collect-garbage

delete-old-generations:
  nix-collect-garbage --delete-old

clean:
  nh clean user

clean-all:
  nh clean all
