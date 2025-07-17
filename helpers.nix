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
  }: let
    # System architecture.
    system = platform;

    # Secrets directory.
    secrets = builtins.toString inputs.secrets;

    # Extra modules to import.
    extraModules =
      hostModules # Host-specific modules.
      ++ optionals (docker == true) [./suites/server/docker] # Enable docker if required.
      ++ (filesystem.listFilesRecursive ./modules); # Custom modules.

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

      # Import my overlay.
      overlays = [
        (import ./overlay.nix {inherit inputs system;})
      ];
    };

    # deploy-rs overlay.
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
          # Make some variables accesible to modules.
          inherit
            hostname
            platform
            suite
            secrets
            ;
        };

        modules =
          [
            nixvim.nixosModules.nixvim # Neovim.
            ./suites/${suite} # Collection of configuration options for different types of systems.
            ./hosts/${hostname} # Host-specific config.
          ]
          ++ extraModules;
      };
    }
    // optionalAttrs (strings.hasPrefix "server" suite) {
      deploy.nodes.${hostname} = {
        hostname = "${hostname}.local";
        profiles.system = {
          user = "root";
          sshuser = "fern";
          path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosconfigurations.${hostname};
        };
      };
    };
}
