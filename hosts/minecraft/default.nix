let
  rootDisk = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
  rootPart = "/dev/disk/by-uuid/f59330d9-0315-43c0-90a1-d9b13c6298f9";
  dockerPart = "/dev/disk/by-uuid/3730e48a-8784-4c49-8692-473c9b4bc8c3";
in {
  # Bootloader.
  boot.loader.grub.device = rootDisk;

  # Root filesystem.
  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };

  # Docker data directory.
  fileSystems."/home/fern/docker" = {
    device = "/dev/disk/by-label/docker";
    fsType = "ext4";
  };

  # Swap partition.
  swapDevices = [{device = "/dev/disk/by-label/swap";}];
}
