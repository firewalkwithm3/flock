{ lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4d1a9488-acf2-456c-a435-cc96ecff8aba";
      fsType = "ext4";
    };

  fileSystems."/home/docker/volumes" =
    { device = "/dev/disk/by-uuid/e520aca6-6cad-483c-b855-f6409a8a6908";
      fsType = "ext2";
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-uuid/fab223a4-78a1-4900-81a6-45d04325fdcf";
      fsType = "ext2";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/73916996-b863-4279-9fe5-ae2b3b773608"; }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}