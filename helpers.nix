inputs:
with inputs;
with inputs.nixpkgs.lib; let
in {
  mergeHosts = lists.foldl' (
    a: b: attrsets.recursiveUpdate a b
  ) {};

  mkHost = hostname: {
    platform ? "x86_64-linux",
    suite,
    user ? "fern",
    extraModules ? [],
  }: {
    nixosConfigurations.${hostname} = nixosSystem rec {
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
      };

      specialArgs = {
        inherit
          hostname
          nixpkgs
          suite
          platform
          user
          ; # Inherit variables.

        userPackages = {
          fluffychat = fluffychat-2_0_0.legacyPackages.${system}.fluffychat;
          feishin = feishin-0_17_0.legacyPackages.${system}.feishin;
          webone = pkgs.callPackage ./packages/webone {};
        };

        secrets = builtins.toString inputs.secrets; # Secrets directory.
      };

      modules =
        [
          nixvim.nixosModules.nixvim
          ./suites/common.nix
          ./suites/${suite}.nix
          ./hosts/${suite}/${hostname}.nix
        ]
        ++ (filesystem.listFilesRecursive ./modules)
        ++ extraModules;
    };

    deploy.nodes.${hostname} = {
      hostname = "${hostname}.local";
      profiles.system = {
        user = "root";
        sshUser = user;
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${hostname};
      };
    };
  };
}
