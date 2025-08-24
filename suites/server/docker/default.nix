{
  # Add user to docker group.
  users.users.fern = {
    extraGroups = ["docker"];
  };

  # Enable docker.
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    liveRestore = true;
    daemon.settings = {
      data-root = "/home/fern/docker/daemon";
      default-address-pools = [
        {
          base = "172.20.0.0/12";
          size = 24;
        }
      ];
    };
  };
}
