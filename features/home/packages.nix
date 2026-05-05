_: {
  home-manager.users.laurent.home.packages = with pkgs; [
    # Fonts
    # ---
    # Nerd Fonts - https://www.nerdfonts.com/
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg

    # Internet
    # ---
    google-chrome # Freeware web browser developed by Google - https://www.google.com/chrome/

    # Productivity
    # ---
    obsidian # Powerful knowledge base that works on top of a local folder of plain text Markdown files - https://obsidian.md/

    # Virtualization
    # ---
    vmware-workstation # Industry standard desktop hypervisor for x86-64 architecture - https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion

    # Nix
    # ---
    alejandra # An uncompromising Nix Code Formatter - https://github.com/kamadorueda/alejandra
    deadnix # Scan .nix files for dead code (unused variable bindings) - https://github.com/astro/deadnix
    nixd # A Nix Language Server, based on Nix libraries - https://github.com/nix-community/nixd
    nil # A Nix Language Server, an incremental analysis assistant for writing in Nix - https://github.com/oxalica/nil
    statix # Lints and suggestions for the Nix programming language - https://github.com/oppiliappan/statix
    nh # Yet another Nix CLI helper - https://github.com/nix-community/nh
    cachix # A service for Nix binary cache hosting - https://github.com/cachix/cachix
  ];
}
