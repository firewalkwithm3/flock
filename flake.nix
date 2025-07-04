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

      nixosConfigurations.vm-docker = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          { networking.hostName = "docker"; }

          ./configuration/common.nix
          ./configuration/vm.nix
          ./hardware-configuration/vm-docker.nix # Include the results of the hardware scan.
        ];
      };

      nixosConfigurations.lxc-technitium = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          (nixpkgs + "/nixos/modules/virtualisation/proxmox-lxc.nix")
          { networking.hostName = "technitium"; }
          ./configuration/containers/technitium.nix
        ];
      };

      nixosConfigurations.lxc-firefox-syncserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          (nixpkgs + "/nixos/modules/virtualisation/proxmox-lxc.nix")
          { networking.hostName = "firefox-syncserver"; }
          ./configuration/containers/firefox-syncserver.nix
        ];
      };
    };
}
