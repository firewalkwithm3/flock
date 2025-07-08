{ user, lib, ... }:
with lib;
{
  # Passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  # Enable all terminfo (for ghostty)
  environment.enableAllTerminfo = true;

  # Enable SSH server
  services.openssh.enable = true;

  users.users.${user}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETPyuxUVEmYyEW6PVC6BXqkhULHd/RvMm8fMbYhjTMV fern@muskduck"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzW4epTmK01kGVXcuAXUNJQPltnogf4uab9FA5m8S3n fern@pardalote"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEJYq1fMxVOzCMfE/td6DtWS8nUk76U9seYD3Z9RYAz u0_a399@fairywren"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMoJvPcUJDVVzO4dHROCFNlgJdDZSP5xyPx2s40zcx5QAAAABHNzaDo= YubiKey5NFC"
  ];

  # Enable docker.
  virtualisation.docker.enable = mkIf (user == "docker") true;
  users.users.${user}.extraGroups = mkIf (user == "docker") [ "docker" ];
}