{
  # Root filesystem.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cbd70e61-fcdc-4b1f-af03-d3da8a2866ea";
    fsType = "ext4";
  };

  # Docker data directory.
  fileSystems."/home/fern/docker/data" = {
    device = "/dev/disk/by-uuid/3730e48a-8784-4c49-8692-473c9b4bc8c3";
    fsType = "ext4";
  };

  # Swap.
  swapDevices = [
    {device = "/dev/disk/by-uuid/45cafadd-90f2-4b65-82fc-60d59eb75786";}
  ];
}
