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
  in
    {
      nixosConfigurations.${hostname} = nixosSystem {
        system = platform;
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "dotnet-sdk-6.0.428"
              "dotnet-runtime-6.0.36"
            ];
          };
          overlays = [(import ./overlay.nix inputs)];
        };

        specialArgs = {
          inherit
            nixpkgs
            hostname
            platform
            suite
            user
            ; # Inherit variables.
          secrets = builtins.toString inputs.secrets;
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
    // optionalAttrs (suite != "desktop") {
      deploy.nodes.${hostname} = {
        hostname = "${hostname}.local";
        profiles.system = {
          user = "root";
          sshUser = user;
          path = pkgs.deploy-rs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${hostname};
        };
      };
    };
}
