inputs:
with inputs;
with inputs.nixpkgs.lib; {
  mergeHosts = lists.foldl' (
    a: b: attrsets.recursiveUpdate a b
  ) {};

  mkHost = hostname: {
    platform ? "x86_64-linux",
    suite,
    user ? "fern",
    extraModules ? [],
  }: let
    system = platform;
    secrets = builtins.toString inputs.secrets;

    pull-requests = {
      fluffychat = import nixpkgs-pr-fluffychat {
        inherit system;
        overlays = [
          (final: prev: {
            fluffychat = prev.fluffychat.overrideAttrs (prevAttrs: rec {
              desktopItems = [
                ((builtins.elemAt prevAttrs.desktopItems 0).override {startupWMClass = "fluffychat";})
              ];
            });
          })
        ];
      };

      feishin = import nixpkgs-pr-feishin {
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
      };
    };

    userPackages = final: prev: {
      # WebOne HTTP proxy.
      webone = prev.pkgs.callPackage ./packages/webone {};
      # Yazi Gruvbox theme.
      yazi-flavour-gruvbox-dark = prev.pkgs.callPackage ./packages/yazi-flavour-gruvbox {};
      # Latest FluffyChat.
      fluffychat = pull-requests.fluffychat.fluffychat;
      # Latest Feishin.
      feishin = pull-requests.feishin.feishin;
      # PrismLauncher with Temurin JRE.
      prismlauncher = prev.prismlauncher.override {
        jdks = [
          prev.pkgs.temurin-jre-bin
        ];
      };
    };

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "dotnet-sdk-6.0.428"
          "dotnet-runtime-6.0.36"
        ];
      };
      overlays = [
        userPackages
      ];
    };

    deployPkgs = import nixpkgs {
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
  in
    {
      nixosConfigurations.${hostname} = nixosSystem {
        inherit system pkgs;

        specialArgs = {
          inherit
            hostname
            platform
            suite
            user
            secrets
            ; # Inherit variables.
        };

        modules =
          [
            nixvim.nixosModules.nixvim
            ./suites/common.nix
            ./suites/${suite}.nix
            ./hosts/${hostname}.nix
          ]
          ++ (filesystem.listFilesRecursive ./modules)
          ++ extraModules;
      };
    }
    // optionalAttrs ((suite == "server")
      || (suite == "vm")
      || (suite == "lxc")) {
      deploy.nodes.${hostname} = {
        hostname = "${hostname}.local";
        profiles.system = {
          user = "root";
          sshUser = user;
          path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${hostname};
        };
      };
    };
}
