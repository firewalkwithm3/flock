{
  config,
  pkgs,
  ...
}: {
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

  # Swap partition.
  swapDevices = [{device = "/dev/disk/by-label/SWAP";}];

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

  # 3D Printing.
  users.users."3dprinting" = {
    isSystemUser = true;
    group = "3dprinting";
  };

  users.groups."3dprinting" = {};

  services.mainsail.enable = true;

  services.moonraker = {
    enable = true;
    address = "0.0.0.0";
    user = "3dprinting";
    group = "3dprinting";
    settings.authorization = {
      cors_domains = [
        "http://weebill.local"
      ];
      trusted_clients = [
        "127.0.0.0/8"
        "10.0.1.0/24"
      ];
    };
  };

  services.klipper = rec {
    enable = true;

    user = "3dprinting";
    group = "3dprinting";

    firmwares.mcu = {
      enable = true;
      configFile = ./ender3v2.cfg;
      serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
    };

    mutableConfig = true;
    configDir = "${config.services.moonraker.stateDir}/config";
    configFile = "${configDir}/printer.cfg";
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
    allowedTCPPorts = [8080 548 80 7125]; # WebOne, Netatalk, nginx, moonraker.
  };
}
