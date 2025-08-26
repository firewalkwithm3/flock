{
  nixpkgs-unstable,
  nixpkgs-pr-feishin,
  ...
}: final: prev: let
  pkgs-unstable = import nixpkgs-unstable {inherit (prev) config system;};
  pkgs-pr-feishin = import nixpkgs-pr-feishin {inherit (prev) config system;};
in {
  ## My packages ##

  webone = prev.pkgs.callPackage ./packages/webone {}; # WebOne HTTP proxy.
  yazi-flavour-kanagawa-dragon = prev.pkgs.callPackage ./packages/yazi-flavour-kanagawa-dragon {}; # Kanagawa theme for yazi.
  cups-dymo = prev.pkgs.callPackage ./packages/cups-dymo {}; # Dymo label printer drivers.

  # Kanagawa Dragon theme for tmux.
  tmuxPlugins =
    prev.tmuxPlugins
    // {
      kanagawa = prev.tmuxPlugins.mkTmuxPlugin {
        pluginName = "kanagawa";
        rtpFilePath = "kanagawa.tmux";
        version = "2025-06-01";
        src = prev.fetchFromGitHub {
          owner = "Nybkox";
          repo = "tmux-kanagawa";
          rev = "9124a8887587f784aaec94b97631255a4e70b8a0";
          hash = "sha256-ZueH5KjPD0SaReuWJOq1FGpjEFXg216BzeXL64o74MU=";
        };
      };
    };

  ## Unstable channel. ##

  protonmail-desktop = pkgs-unstable.protonmail-desktop;
  rockbox-utility = pkgs-unstable.rockbox-utility;

  fluffychat = pkgs-unstable.fluffychat.overrideAttrs (prevAttrs: {
    desktopItems = [
      ((builtins.elemAt prevAttrs.desktopItems 0).override {startupWMClass = "fluffychat";})
    ];
  });

  ## Pull requests. ##

  feishin = pkgs-pr-feishin.feishin.overrideAttrs (prevAttrs: rec {
    pname = "feishin";
    version = "0.18.0";

    src = prev.fetchFromGitHub {
      owner = "jeffvli";
      repo = "feishin";
      rev = "v${version}";
      hash = "sha256-4gcS7Vd7LSpEByO2Hlk6nb8V2adBPh5XwWGCu2lwOA4=";
    };

    pnpmDeps = prev.pnpm_10.fetchDeps {
      inherit pname version src;
      hash = "sha256-1MGxrUcfvazxAubaYAsQuulUKm05opWOIC7oaLzjr7o=";
    };
  });

  ## Modifications ##

  # PrismLauncher with Temurin JRE;
  prismlauncher = prev.prismlauncher.override {
    jdks = [
      prev.pkgs.temurin-jre-bin
    ];
  };

  # Custom iosevka build.
  iosevka = prev.iosevka.override {
    set = "Custom";

    privateBuildPlan = {
      family = "IosevkaCustom";
      spacing = "term";
      serifs = "sans";
      noCvSs = false;
      exportGlyphNames = true;
      variants.inherits = "ss05";

      weights = {
        Regular = {
          shape = 400;
          menu = 400;
          css = 400;
        };
        Bold = {
          shape = 700;
          menu = 700;
          css = 700;
        };
      };
    };
  };
}
