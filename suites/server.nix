{
  user,
  lib,
  ...
}:
with lib; {
  # Passwordless sudo.
  security.sudo.wheelNeedsPassword = false;

  # Enable all terminfo (for ghostty).
  environment.enableAllTerminfo = true;

  # Enable sshd.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.${user} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETPyuxUVEmYyEW6PVC6BXqkhULHd/RvMm8fMbYhjTMV fern@muskduck"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMoJvPcUJDVVzO4dHROCFNlgJdDZSP5xyPx2s40zcx5QAAAABHNzaDo= YubiKey5NFC"
    ];
    extraGroups = mkIf (user == "docker") ["docker"]; # if docker is enabled.
  };

  # Enable docker.
  virtualisation.docker.enable = mkIf (user == "docker") true;
}
