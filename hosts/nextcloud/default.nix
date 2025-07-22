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
  # services.nextcloud = {
  #   enable = true;
  #   package = pkgs.nextcloud31;
  #   hostName = "localhost";
  #   config.adminpassFile = config.sops.secrets."nextcloud/admin_pass".path;
  #   config.dbtype = "sqlite";
  # };
}
