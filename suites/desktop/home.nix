{pkgs, ...}: {
  imports = [../home.nix];

  # Autostart.
  xdg.autostart = {
    enable = true;
    readOnly = true;
    entries = let
      smile = pkgs.writeText "smile.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=it.mijorus.smile
        X-XDP-Autostart=it.mijorus.smile
        Exec=smile --start-hidden
      '';
    in [
      smile
      "${pkgs.fluffychat}/share/applications/Fluffychat.desktop"
      "${pkgs.feishin}/share/applications/feishin.desktop"
      "${pkgs.protonmail-desktop}/share/applications/proton-mail.desktop"
      "${pkgs.signal-desktop}/share/applications/signal.desktop"
    ];
  };

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
