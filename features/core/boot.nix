{pkgs, ...}: {
  # Bootloader and kernel.
  boot = {
    loader = {
      limine = {
        # A modern, advanced, portable, multi-protocol bootloader and boot manager.
        # For additional Limine module configuration options, refer to https://search.nixos.org/options?channel=unstable&show=boot.loader.limine.
        enable = true;
        maxGenerations = 5; # Maximum number of latest generations in the boot menu.
        # Prepend extra settings to `limine.conf`.
        # The config format can be found here: https://github.com/limine-bootloader/limine/blob/trunk/CONFIG.md
        extraConfig = ''
          remember_last_entry: yes
        '';
        # Append extra entries to the end of `limine.conf`.
        #
        # For Windows 11, follow these instructions to copy the Windows bootloader to Limine's ESP
        # and avoid using uuid(): https://github.com/basecamp/omarchy/discussions/1604
        #
        # Reference: https://wiki.archlinux.org/title/Limine#Windows_entry_(UEFI)
        extraEntries = ''
          /Windows 11
            protocol: efi
            path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
        '';
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest; # Recent kernel for recent GPU.
  };
}
