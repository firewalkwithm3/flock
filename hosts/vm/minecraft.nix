{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cbd70e61-fcdc-4b1f-af03-d3da8a2866ea";
    fsType = "ext4";
  };

  fileSystems."/home/docker/volumes" = {
    device = "/dev/disk/by-uuid/3730e48a-8784-4c49-8692-473c9b4bc8c3";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/3123f58e-63a9-44fa-ac29-3e79dc520b8f"; }
  ];
}
