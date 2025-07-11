{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cac60222-9b38-4938-8b17-5fddd67e8e26";
    fsType = "ext4";
  };

  fileSystems."/home/docker/volumes" = {
    device = "/dev/disk/by-uuid/95461a94-ad91-43b9-b502-2b5d4496b84e";
    fsType = "ext4";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/025beadb-a89b-4abe-8d0c-b55401316319";}
  ];
}
