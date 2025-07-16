{
  imports = [../.]; # Common config.

  # Passwordless sudo.
  security.sudo.wheelNeedsPassword = false;

  # Enable sshd.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Add authorized ssh pubkeys.
  users.users.fern = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETPyuxUVEmYyEW6PVC6BXqkhULHd/RvMm8fMbYhjTMV fern@muskduck"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMoJvPcUJDVVzO4dHROCFNlgJdDZSP5xyPx2s40zcx5QAAAABHNzaDo= YubiKey5NFC"
    ];
  };
}
