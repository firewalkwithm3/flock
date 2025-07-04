{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/63d79656-aa5b-466a-b369-be5eac3f51ab";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-93fa00bc-777f-4359-bad5-880c29faca0d".device =
    "/dev/disk/by-uuid/93fa00bc-777f-4359-bad5-880c29faca0d";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EBD7-3E1C";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
