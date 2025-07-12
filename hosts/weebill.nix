{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  # Enable WebOne HTTP proxy.
  services.webone.enable = true;

  # Enable Netatalk AFP fileserver.
  services.netatalk = {
    enable = true;
    settings = {
      Global = {
        "uam list" = "uams_guest.so";
      };
      iMac = {
        path = "/srv/iMac";
        browsable = "yes";
        "read-only" = "yes";
      };
    };
  };
  # Open ports for services.
  networking.firewall = {
    allowedUDPPorts = [
      53 # DHCP server.
      67 # DHCP server.
    ];
    allowedTCPPorts = [8080 548]; # WebOne & Netatalk.
  };
}
