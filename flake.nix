{
  description = "NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Stable nixpkgs.
    lanzaboote.url = "github:nix-community/lanzaboote"; # Secure boot.
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # Hardware specific config.
    
    # Updated packages.
    fluffychat2.url = "github:NixOS/nixpkgs?ref=pull/419632/head"; # FluffyChat 2.0.0
    feishin0_16_0.url = "github:NixOS/nixpkgs?ref=pull/414929/head"; # Feishin 0.16.0
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      lanzaboote,
      nixos-hardware,
      fluffychat2,
      feishin0_16_0,
      ...
    }:
    {
      nixosConfigurations.muskduck = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
          fluffychat2 = import fluffychat2 { inherit system; };
          feishin0_16_0 = import feishin0_16_0 { inherit system; };
        };

        modules = [
          { networking.hostName = "muskduck"; }

          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.lenovo-thinkpad-t480

          ./configuration/common.nix
          ./configuration/desktop.nix
          ./hardware-configuration/muskduck.nix # Include the results of the hardware scan.
        ];
      };

      nixosConfigurations.vm-minecraft = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          { networking.hostName = "minecraft"; }
          
          ./configuration/common.nix
          ./configuration/vm.nix
          ./hardware-configuration/vm-minecraft.nix # Include the results of the hardware scan.
        ];
      };
      
      nixosConfigurations.lxc-technitium = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          (nixpkgs + "/nixos/modules/virtualisation/proxmox-lxc.nix")

          { 
            networking.hostName = "technitium";

            services.technitium-dns-server = {
              enable = true;
              openFirewall = true;
            };

            system.stateVersion = "25.05";
          }
        ];
      };

      nixosConfigurations.lxc-firefox-syncserver = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        modules = [
          (nixpkgs + "/nixos/modules/virtualisation/proxmox-lxc.nix")

          { 
            networking.hostName = "firefox-syncserver";

            services.mysql.package = nixpkgs.legacyPackages.${system}.mariadb;

            services.firefox-syncserver = {
              enable = true;
              secrets = ./firefox-syncserver.env;
              settings.host = "0.0.0.0";
              singleNode = {
                enable = true;
                hostname = "0.0.0.0";
                url = "https://fxsync.fern.garden";
                capacity = 1;
              };
            };

            networking.firewall.allowedTCPPorts = [ 5000 ];

            system.stateVersion = "25.05";
          }
        ];
      };
    };
}
