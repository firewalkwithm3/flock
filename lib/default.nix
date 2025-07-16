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
        (import ../overlays {inherit inputs system;})
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
            ../suites/common.nix
            ../suites/${suite}.nix
            ../hosts/${hostname}.nix
          ]
          ++ (filesystem.listFilesRecursive ../modules)
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
