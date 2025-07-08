{
  description = "NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Stable nixpkgs.
    lanzaboote.url = "github:nix-community/lanzaboote"; # Secure boot.
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # Hardware specific config.
    sops-nix.url = "github:Mic92/sops-nix"; # Secrets management.
    secrets = {
      url = "git+ssh://git@docker.local:222/fern/secrets?ref=main";
      flake = false;
    }; # Secrets repo.

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
    {
      # ThinkPad T480
      nixosConfigurations.muskduck = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
          fluffychat2 = import fluffychat2 { inherit system; };
          feishin0_17 = import feishin0_17 { inherit system; };
        };

        modules = [
          { networking.hostName = "muskduck"; }

          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.lenovo-thinkpad-t480

          ./configuration/common.nix
          ./configuration/desktop.nix
          
          ./hosts/muskduck.nix # Include the results of the hardware scan.
        ];
      };

      ### Proxmox Guests ###

      nixosConfigurations.vm-minecraft = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          { networking.hostName = "minecraft"; }

          ./configuration/common.nix
          
          ./configuration/server/common.nix
          ./configuration/server/vm.nix
          ./configuration/server/docker.nix
          
          ./hosts/vm-minecraft.nix # Include the results of the hardware scan.
        ];
      };

      nixosConfigurations.vm-docker = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          { networking.hostName = "docker"; }

          ./configuration/common.nix
          
          ./configuration/server/common.nix
          ./configuration/server/vm.nix
          ./configuration/server/docker.nix

          ./hosts/vm-docker.nix # Include the results of the hardware scan.
        ];
      };

      nixosConfigurations.lxc-technitium = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          { networking.hostName = "technitium"; }
          
          ./configuration/common.nix

          ./configuration/server/common.nix
          ./configuration/server/containers/common.nix

          ./configuration/server/containers/technitium.nix
        ];
      };

      nixosConfigurations.lxc-firefox-syncserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        specialArgs = {
          secrets = builtins.toString inputs.secrets;
        };

        modules = [
          sops-nix.nixosModules.sops
          
          { networking.hostName = "firefox-syncserver"; }
          
          ./configuration/common.nix

          ./configuration/server/common.nix
          ./configuration/server/containers/common.nix

          ./configuration/server/containers/firefox-syncserver.nix
        ];
      };
    };
}
