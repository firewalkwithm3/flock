{
  # Add user to docker group.
  users.users.fern = {
    extraGroups = ["docker"];
  };

  # Enable docker.
  virtualisation.docker.enable = true;
}
