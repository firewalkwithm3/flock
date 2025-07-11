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

  # Enable docker.
  virtualisation.docker.enable = mkIf (user == "docker") true;
  users.users.${user}.extraGroups = mkIf (user == "docker") ["docker"];
}
