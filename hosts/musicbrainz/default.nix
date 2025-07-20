{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5d71cc16-f1ee-4b87-87b2-00fdf98442bd";
    fsType = "ext4";
  };

  fileSystems."/home/fern/docker/data" = {
    device = "/dev/disk/by-uuid/0eb05c79-7765-4b7e-bf22-c3a53f516db5";
    fsType = "ext4";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/1402e27f-861f-4ecd-8b46-a29461ec3eeb";}
  ];
}
