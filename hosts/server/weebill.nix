{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    kernelParams = [
      "snd_bcm2835.enable_hdmi=1"
      "snd_bcm2835.enable_headphones=1"
    ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      raspberryPi.firmwareConfig = ''
        dtparam=audio=on
      '';
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # Config from <https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_4>
  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      fkms-3d.enable = true;
    };

    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  console.enable = false;

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  networking.networkmanager.wifi.powersave = false; # Prevent host becoming unreachable on wifi after some time.

  # Open ports for DHCP server.
  networking.firewall.allowedUDPPorts = [
    53
    67
  ];

  # Enable WebOne HTTP proxy.
  services.webone.enable = true;
}
