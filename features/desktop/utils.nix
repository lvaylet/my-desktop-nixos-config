_: {
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  virtualisation = {
    vmware.host.enable = true; # VMware Workstation
    podman.enable = true; # A daemonless container engine for developing, managing, and running OCI Containers on your Linux System.
  };

  # Enable OpenGL.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
