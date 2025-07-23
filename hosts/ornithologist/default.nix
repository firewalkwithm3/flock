{pkgs, ...}: {
  # Root filesystem.
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/11bdddf2-82b9-473d-b2ac-3b58f9f93ee7";
      fsType = "ext4";
    };

  # Swap.
  swapDevices =
    [ { device = "/dev/disk/by-uuid/2fd2d201-14a2-45f8-abef-a1e57a509fe4"; }
    ];

  # Install some packages.
  environment.systemPackages = with pkgs; [
    deploy-rs
  ];

  # Allows remote deployment on ARM systems (ie. Raspberry Pi).
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
}
