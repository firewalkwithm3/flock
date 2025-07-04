{
  # Configure the bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
  
  # Enable QEMU guest agent
  services.qemuGuest.enable = true;

  # Define a user account.
  users.users.docker = {
    isNormalUser = true;
    linger = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETPyuxUVEmYyEW6PVC6BXqkhULHd/RvMm8fMbYhjTMV fern@muskduck"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzW4epTmK01kGVXcuAXUNJQPltnogf4uab9FA5m8S3n fern@pardalote"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEJYq1fMxVOzCMfE/td6DtWS8nUk76U9seYD3Z9RYAz u0_a399@fairywren"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMoJvPcUJDVVzO4dHROCFNlgJdDZSP5xyPx2s40zcx5QAAAABHNzaDo= YubiKey5NFC"
    ];
  };

  # Auto login
  services.getty.autologinUser = "docker";

  # Passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  # Enable all terminfo (for ghostty)
  environment.enableAllTerminfo = true;

  # Enable SSH server
  services.openssh.enable = true;

  # Enable docker
  virtualisation.docker = {
    enable = true;
  };
}
