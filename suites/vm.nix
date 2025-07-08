{
  modulesPath,
  lib,
  ...
}:
with lib;
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./server.nix
  ];

  # Load kernel modules.
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
  ];

  boot.kernelModules = [ "kvm-intel" ];

  # Enable DHCP.
  networking.useDHCP = mkDefault true;

  # Configure the bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  # Enable QEMU guest agent
  services.qemuGuest.enable = true;
}
