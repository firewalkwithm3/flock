{
  config,
  lib,
  userPackages,
  ...
}:
with lib;
let
  cfg = config.services.webone;
in
{
  options.services.webone.enable = mkEnableOption "Enable WebOne HTTP proxy.";

  config = mkIf cfg.enable {
    users.groups.webone = { };

    users.users.webone = {
      createHome = true;
      isSystemUser = true;
      home = "/var/lib/webone";
      group = "webone";
    };

    systemd.tmpfiles.settings = {
      "10-webone" = {
        "/var/log/webone.log" = {
          f = {
            group = "webone";
            mode = "0664";
            user = "webone";
          };
        };
        "/etc/webone.conf.d" = {
          d = {
            group = "webone";
            mode = "0755";
            user = "webone";
          };
        };
      };
    };

    systemd.services.webone = {
      description = "WebOne HTTP Proxy Server";
      documentation = [ "https://github.com/atauenis/webone/wiki/" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "default.target" ];
      startLimitIntervalSec = 5;
      startLimitBurst = 3;
      environment = {
        OPENSSL_CONF = "${userPackages.webone}/lib/webone/openssl_webone.cnf";
      };
      serviceConfig = {
        Type = "simple";
        User = "webone";
        Group = "webone";
        ExecStart = "${userPackages.webone}/bin/webone";
        TimeoutStopSec = "10";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };
  };
}
