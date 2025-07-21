{
  inputs,
  system,
  ...
}:
with inputs;
  final: prev: {
    # WebOne HTTP proxy.
    webone = prev.pkgs.callPackage ./packages/webone {};

    # Yazi Gruvbox theme.
    yazi-flavour-gruvbox-dark = prev.pkgs.callPackage ./packages/yazi-flavour-gruvbox {};

    # Dymo label printer drivers.
    cups-dymo = prev.pkgs.callPackage ./packages/cups-dymo {};

    # Latest FluffyChat.
    fluffychat =
      (import nixpkgs-pr-fluffychat
        {
          inherit system;
          overlays = [
            (final: prev: {
              fluffychat = prev.fluffychat.overrideAttrs (prevAttrs: {
                desktopItems = [
                  ((builtins.elemAt prevAttrs.desktopItems 0).override {startupWMClass = "fluffychat";})
                ];
              });
            })
          ];
        }).fluffychat;

    # Latest Feishin.
    feishin =
      (import nixpkgs-pr-feishin {
        inherit system;
        overlays = [
          (final: prev: {
            feishin = prev.feishin.overrideAttrs (prevAttrs: rec {
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
          })
        ];
      }).feishin;

    # PrismLauncher with Temurin JRE;
    prismlauncher = prev.prismlauncher.override {
      jdks = [
        prev.pkgs.temurin-jre-bin
      ];
    };

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
