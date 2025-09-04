{pkgs, ...}: let
  rootDisk = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
  rootPart = "/dev/disk/by-uuid/5dc8ca3b-177a-458e-b8a8-89309168d0fc";
  dockerPart = "/dev/disk/by-uuid/95461a94-ad91-43b9-b502-2b5d4496b84e";
in {
  # Boot loader.
  boot.loader.grub.device = rootDisk;

  # Root filesystem.
  fileSystems."/" = {
    device = rootPart;
    fsType = "ext4";
  };

  # Docker data directory
  fileSystems."/home/fern/docker" = {
    device = dockerPart;
    fsType = "ext4";
  };

  # Media HDDs.
  fileSystems."/mnt/hdd0" = {
    device = "/dev/disk/by-uuid/fcee0188-8ca1-4fda-81b7-f5920c79ab48";
    fsType = "ext4";
  };

  fileSystems."/mnt/hdd1" = {
    device = "/dev/disk/by-uuid/5d9dd538-79e4-4168-be91-e0b040155cb3";
    fsType = "ext4";
  };

  fileSystems."/mnt/hdd2" = {
    device = "/dev/disk/by-uuid/5a43b7dc-3e28-459e-824a-ad45b5475361";
    fsType = "ext4";
  };

  # Install some packages.
  environment.systemPackages = with pkgs; [
    mergerfs
  ];

  # MergerFS.
  fileSystems."/media" = {
    fsType = "fuse.mergerfs";
    depends = ["/mnt/hdd0" "/mnt/hdd1" "/mnt/hdd2"];
    device = "/mnt/hdd0:/mnt/hdd1:/mnt/hdd2";
    options = ["cache.files=partial" "dropcacheonclose=true" "category.create=mfs" "func.getattr=newest"];
  };

  # Media group.
  users.groups.media = {
    gid = 1800;
  };

  users.users.fern.extraGroups = ["media"];
}
