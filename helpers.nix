inputs:
with inputs;
with inputs.nixpkgs.lib; {
  # Merge NixOS hosts.
  mergeHosts = lists.foldl' (
    a: b: attrsets.recursiveUpdate a b
  ) {};

  # Create a NixOS host.
  mkHost = hostname: {
    platform ? "x86_64-linux",
    suite ? "",
    docker ? false,
    hostModules ? [],
  }:
    {
      nixosConfigurations.${hostname} = nixosSystem rec {
        # Architecture.
        system = platform;

        # nixpkgs config.
        pkgs = import nixpkgs {
          inherit system;

          config = {
            # Allow installation of proprietary software.
            allowUnfree = true;
            # Allow the installation of packages marked as insecure in nixpkgs.
            permittedInsecurePackages = [
              "dotnet-sdk-6.0.428" # For WebOne.
              "dotnet-runtime-6.0.36" # For WebOne.
            ];
          };

          # Import my overlays.
          overlays = [
            (import ./overlay.nix {inherit nixpkgs-unstable nixpkgs-pr-feishin;})
          ];
        };

        specialArgs = {
          # Pass hostname & inputs to config.
          inherit inputs hostname;

          # Secrets directory.
          secrets = builtins.toString inputs.secrets;
        };

        modules =
          [
            nixvim.nixosModules.nixvim # Neovim.
            lanzaboote.nixosModules.lanzaboote # Secure boot.
            sops-nix.nixosModules.sops # Secrets management.

            ./suites/${suite} # Collection of configuration options for different types of systems.
            ./hosts/${hostname} # Host-specific config.

            # Home manager.
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.fern = {
                  # Me!
                  home.username = "fern";
                  home.homeDirectory = "/home/fern";

                  # Home manager version.
                  home.stateVersion = "25.05";

                  # Let Home Manager install and manage itself.
                  programs.home-manager.enable = true;

                  # Import config.
                  imports = [./suites/${suite}/home.nix];
                };
              };
            }
          ]
          ++ hostModules # Host-specific modules.
          ++ optionals (docker == true) [./suites/server/docker] # Enable docker if required.
          ++ (filesystem.listFilesRecursive ./modules); # Custom modules.
      };
    }
    // optionalAttrs (strings.hasPrefix "server" suite) {
      deploy.nodes.${hostname} = let
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
      in {
        hostname = "${hostname}.local";
        profiles.system = {
          user = "root";
          sshuser = "fern";
          path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${hostname};
        };
      };
    };
}
