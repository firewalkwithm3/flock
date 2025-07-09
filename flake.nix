{
  description = "NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Stable nixpkgs.
    lanzaboote.url = "github:nix-community/lanzaboote"; # Secure boot.
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # Hardware specific config.
    sops-nix.url = "github:Mic92/sops-nix"; # Secrets management.
    # Secrets repo.
    secrets = {
      url = "git+ssh://git@docker.local:222/fern/secrets?ref=main";
      flake = false;
    };
    nvf.url = "github:notashelf/nvf"; # Neovim.

    # Packages.
    fluffychat-2_0_0.url = "github:NixOS/nixpkgs?ref=pull/419632/head"; # FluffyChat 2.0.0
    feishin-0_17_0.url = "github:NixOS/nixpkgs?ref=pull/414929/head"; # Feishin 0.17.0
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      lanzaboote,
      nixos-hardware,
      sops-nix,
      nvf,
      fluffychat-2_0_0,
      feishin-0_17_0,
      ...
    }:
    with nixpkgs.lib;
    let
      mkHost =
        {
          hostname,
          suite,
          platform ? "x86_64-linux",
          user ? "fern",
          extraModules ? [ ],
        }:
        nixosSystem rec {
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
              suite
              platform
              user
              ; # Inherit variables.

            userPackages = {
              fluffychat = fluffychat-2_0_0.legacyPackages.${system}.fluffychat;
              feishin = feishin-0_17_0.legacyPackages.${system}.feishin;
              webone = pkgs.callPackage ./packages/webone { };
            };

            secrets = builtins.toString inputs.secrets; # Secrets directory.
          };

          modules =
            [
              nvf.nixosModules.default
              ./suites/common.nix
              ./suites/${suite}.nix
              ./hosts/${suite}/${hostname}.nix
            ]
            ++ (filesystem.listFilesRecursive ./modules)
            ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        # Laptops.
        muskduck = mkHost {
          hostname = "muskduck";
          suite = "laptop";
          extraModules = [
            lanzaboote.nixosModules.lanzaboote
            nixos-hardware.nixosModules.lenovo-thinkpad-t480
          ];
        };

        # Servers.
        weebill = mkHost {
          hostname = "weebill";
          suite = "server";
          platform = "aarch64-linux";
          user = "docker";
          extraModules = [
            nixos-hardware.nixosModules.raspberry-pi-4
          ];
        };

        # Virtual machines.
        vm-docker = mkHost {
          hostname = "docker";
          suite = "vm";
          user = "docker";
        };

        vm-minecraft = mkHost {
          hostname = "minecraft";
          suite = "vm";
          user = "docker";
        };

        # LXC containers.
        lxc-technitium = mkHost {
          hostname = "technitium";
          suite = "lxc";
        };

        lxc-firefox-syncserver = mkHost {
          hostname = "firefox-syncserver";
          suite = "lxc";
          extraModules = [
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
