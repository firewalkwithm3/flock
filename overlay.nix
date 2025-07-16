inputs:
with inputs; (super: self: {
  webone = super.pkgs.callPackage ./packages/webone {};
  yazi-flavour-gruvbox-dark = super.pkgs.callPackage ./packages/yazi-flavour-gruvbox {};
  pr.fluffychat = import nixpikgs-pr-fluffychat {inherit system;};

  pr.feishin = import nixpkgs-pr-feishin {
    inherit system;
    overlays = [
      (self: super: {
        feishin = super.feishin.overrideAttrs (old: rec {
          pname = "feishin";
          version = "0.18.0";

          src = super.fetchFromGitHub {
            owner = "jeffvli";
            repo = "feishin";
            rev = "v${version}";
            hash = "sha256-4gcS7Vd7LSpEByO2Hlk6nb8V2adBPh5XwWGCu2lwOA4=";
          };

          pnpmDeps = super.pnpm_10.fetchDeps {
            inherit pname version src;
            hash = "sha256-1MGxrUcfvazxAubaYAsQuulUKm05opWOIC7oaLzjr7o=";
          };
        });
      })
    ];
  };

  deploy-rs = import nixpkgs {
    inherit system;
    overlays = [
      deploy-rs.overlays.default
      (self: super: {
        deploy-rs = {
          inherit (pkgs) deploy-rs;
          lib = super.deploy-rs.lib;
        };
      })
    ];
  };
})
