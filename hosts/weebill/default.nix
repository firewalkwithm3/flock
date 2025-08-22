{pkgs, ...}: {
  # Boot loader.
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

  # Root filesystem.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  # Printer Sharing.
  services.printing = {
    enable = true;
    drivers = [pkgs.cups-dymo]; # Dymo label printer.
    listenAddresses = ["*:631"];
    allowFrom = ["all"];
    browsing = true;
    defaultShared = true;
    openFirewall = true;
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

  systemd.tmpfiles.settings = {
    "10-netatalk" = {
      "/srv/netatalk" = {
        d = {
          group = "users";
          mode = "0755";
          user = "fern";
        };
      };
    };
  };

  # Open ports for services.
  networking.firewall = {
    allowedUDPPorts = [53 67]; # DHCP server.
    allowedTCPPorts = [8080 548]; # WebOne & Netatalk.
  };
}
