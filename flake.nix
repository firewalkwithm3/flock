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
    
    # Updated packages.
    fluffychat2.url = "github:NixOS/nixpkgs?ref=pull/419632/head"; # FluffyChat 2.0.0
    feishin0_17.url = "github:NixOS/nixpkgs?ref=pull/414929/head"; # Feishin 0.17.0
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
          platform,
          user ? "fern",
          extraModules ? [ ],
        }:
        nixosSystem rec {
          system = platform;

          specialArgs = {
            inherit user;
            secrets = builtins.toString inputs.secrets;
            fluffychat2 = import fluffychat2 { inherit system; };
            feishin0_17 = import feishin0_17 { inherit system; };
          };

          modules = [
            ./suites/common.nix
            ./suites/${suite}.nix
            ./hosts/${suite}/${hostname}.nix
            { networking.hostName = hostname; }
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        # Laptops.
        muskduck = mkHost {
          hostname = "muskduck";
          suite = "laptop";
          platform = "x86_64-linux";
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
          platform = "x86_64-linux";
        };

        vm-minecraft = mkHost {
          hostname = "minecraft";
          suite = "vm";
          user = "docker";
          platform = "x86_64-linux";
        };

        # LXC containers.
        lxc-technitium = mkHost {
          hostname = "technitium";
          suite = "lxc";
          platform = "x86_64-linux";
        };

        lxc-firefox-syncserver = mkHost {
          hostname = "firefox-syncserver";
          suite = "lxc";
          platform = "x86_64-linux";
          extraModules = [
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
