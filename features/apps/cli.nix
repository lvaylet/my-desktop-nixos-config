{pkgs, ...}: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

    wget
    curl

    just # A command runner similar to Makefile, but simpler - https://github.com/casey/just

    git
    pre-commit # A framework for managing and maintaining multi-language pre-commit hooks - https://pre-commit.com/

    nvtopPackages.nvidia
  ];
}
