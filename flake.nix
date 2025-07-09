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
    
    # Packages.
    fluffychat2.url = "github:NixOS/nixpkgs?ref=pull/419632/head"; # FluffyChat 2.0.0
    feishin0_17.url = "github:NixOS/nixpkgs?ref=pull/414929/head"; # Feishin 0.17.0
    webone.url = "github:firewalkwithm3/webone?rev=256f5e115ceffb71fd2d61e0c7cb9b6b55c7571a"; # WebOne HTTP proxy.
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      lanzaboote,
      nixos-hardware,
      sops-nix,
      fluffychat2,
      feishin0_17,
      ...
    }:
    let
      mkHost =
        with nixpkgs.lib;
        {
          hostname,
          suite,
          platform ? "x86_64-linux",
          user ? "fern",
          extraModules ? [ ],
        }:
        nixosSystem rec {
          system = platform;

          specialArgs = {
            inherit hostname suite platform user; # Inherit variables.
            secrets = builtins.toString inputs.secrets; # Secrets directory.
            # Packages
            userPkgs = {
              fluffychat = fluffychat2.legacyPackages.${system}.fluffychat;
              feishin = feishin0_17.legacyPackages.${system}.feishin;
              webone = webone.packages.${system}.default;
            };
          };

          modules = [
            ./suites/common.nix
            ./suites/${suite}.nix
            ./hosts/${suite}/${hostname}.nix
          ] ++ extraModules;
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
