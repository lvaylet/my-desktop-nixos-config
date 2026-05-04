default: format lint build

# Rebuild
build:
  nh os build .

# Rebuild and switch
switch:
  nh os switch .

# Rebuild and switch after boot
boot:
  nh os boot .

# Rebuild and activate but not switch
test:
  nh os test .

format:
  alejandra .

lint:
  deadnix
  statix check

collect-garbage:
  nix-collect-garbage

delete-old-generations:
  nix-collect-garbage --delete-old

clean keep="1":
  nh clean user --keep {{keep}}

clean-all keep="1":
  nh clean all --keep {{keep}}
