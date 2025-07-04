{ pkgs, ... }:
{
  services.mysql.package = pkgs.mariadb;

  services.firefox-syncserver = {
    enable = true;
    secrets = ./firefox-syncserver.env;
    settings.host = "0.0.0.0";
    singleNode = {
      enable = true;
      hostname = "0.0.0.0";
      url = "https://fxsync.fern.garden";
      capacity = 1;
    };
  };

  networking.firewall.allowedTCPPorts = [ 5000 ];

  system.stateVersion = "25.05";
}
