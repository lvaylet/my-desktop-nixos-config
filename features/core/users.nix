{pkgs, ...}: {
  # When adding a new shell, always enable the shell system-wide, even if it's already enabled in your Home Manager configuration, otherwise it won't source the necessary files.
  # Reference: https://wiki.nixos.org/wiki/Command_Shell
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.laurent = {
    isNormalUser = true;
    description = "Laurent VAYLET";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
}
