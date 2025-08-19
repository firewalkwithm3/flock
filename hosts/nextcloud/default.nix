{
  config,
  pkgs,
  secrets,
  ...
}: {
  # # Import secrets.
  # sops = {
  #   age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  #   defaultSopsFile = "${secrets}/sops.yaml";
  #   secrets."nextcloud/admin_pass" = {};
  # };
  #
  # # Enable Nextcloud.
  # services.nextcloud = {
  #   enable = true;
  #   package = pkgs.nextcloud31;
  #   hostName = "localhost";
  #   database.createLocally = true;
  #   appstoreEnable = false;
  #   autoUpdateApps.enable = true;
  #
  #   extraApps = with config.services.nextcloud.package.packages.apps; {
  #     inherit bookmarks calendar contacts dav_push gpoddersync user_oidc;
  #   };
  #
  #   settings = {
  #     trusted_domains = ["cloud.ferngarden.net"];
  #     trusted_proxies = ["10.0.1.102"];
  #     log_type = "file";
  #     default_phone_region = "AU";
  #   };
  #
  #   config = {
  #     dbtype = "pgsql";
  #     adminuser = "fern";
  #     adminpassFile = config.sops.secrets."nextcloud/admin_pass".path;
  #   };
  #
  #   notify_push = {
  #     enable = true;
  #   };
  # };
  #
  # # Open required ports for Nextcloud.
  # networking.firewall.allowedTCPPorts = [
  #   80
  #   443
  # ];
}
