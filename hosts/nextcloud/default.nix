{
  config,
  pkgs,
  secrets,
  ...
}: {
  # Import secrets.
  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    defaultSopsFile = "${secrets}/sops.yaml";
    secrets."nextcloud/admin_pass" = {};
  };

  # Enable Nextcloud.
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = "cloud.ferngarden.net";
    settings = {
      trusted_proxies = ["10.0.1.102"];
      overwriteprotocol = "https";
    };
    config = {
      adminpassFile = config.sops.secrets."nextcloud/admin_pass".path;
      dbtype = "pgsql";
    };
    database.createLocally = true;
    extraApps = {
      inherit
        (config.services.nextcloud.package.packages.apps)
        contacts
        calendar
        dav_push
        end_to_end_encryption
        gpoddersync
        user_oidc
        ;
    };
    extraAppsEnable = true;
  };

  # Open port for Nextcloud
  networking.firewall.allowedTCPPorts = [80];
}
