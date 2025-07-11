{
  config,
  pkgs,
  secrets,
  ...
}: {
  # Secrets.
  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    defaultSopsFile = "${secrets}/sops.yaml";
    secrets."firefox_syncserver/sync_master_secret" = {};
  };

  # Enable Firefox sync service.
  services.mysql.package = pkgs.mariadb;

  services.firefox-syncserver = {
    enable = true;
    secrets = config.sops.secrets."firefox_syncserver/sync_master_secret".path;
    settings.host = "0.0.0.0";
    singleNode = {
      enable = true;
      hostname = "0.0.0.0";
      url = "https://fxsync.fern.garden";
      capacity = 1;
    };
  };

  # Open Firefox sync service port.
  networking.firewall.allowedTCPPorts = [5000];
}
