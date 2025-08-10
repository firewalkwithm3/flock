{pkgs, ...}: {
  imports = [../home.nix];

  # Ghostty settings.
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "IosevkaCustom";
      theme = "Kanagawa Dragon";
    };
  };

  # Firefox settings
  programs.firefox = {
    enable = true;
    profiles.default = {};
    profiles.default.settings."identity.sync.tokenserver.uri" = "https://fxsync.fern.garden/1.0/sync/1.5";
  };
}
