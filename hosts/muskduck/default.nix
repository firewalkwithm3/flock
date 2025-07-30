{lib, ...}:
with lib; {
  # Kernel modules.
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  boot.kernelModules = ["kvm-intel"];

  # Enable lanzaboote & secure boot.
  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = mkForce false;
  boot.bootspec.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    settings.timeout = 0;
  };

  # Root filesystem.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/63d79656-aa5b-466a-b369-be5eac3f51ab";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-93fa00bc-777f-4359-bad5-880c29faca0d".device = "/dev/disk/by-uuid/93fa00bc-777f-4359-bad5-880c29faca0d";

  # EFI/boot partition.
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EBD7-3E1C";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Share Music dir.
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "FLOCK";
        "server string" = "muskduck";
        "netbios name" = "muskduck";
        "security" = "user";
      };
      "Music" = {
        "path" = "/home/fern/Music";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "no";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
