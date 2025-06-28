{
  description = "NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Stable nixpkgs.
    lanzaboote.url = "github:nix-community/lanzaboote"; # Secure boot.
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # Hardware specific config.
    home-manager.url = "github:nix-community/home-manager/release-25.05"; # Manage user home directories.
    
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
      home-manager,
      fluffychat2,
      feishin0_16_0,
      ...
    }:
    {
      nixosConfigurations.muskduck = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        modules = [
          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.lenovo-thinkpad-t480
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.fern = ./home.nix;

            home-manager.extraSpecialArgs = {
              fluffychat2 = import fluffychat2 { inherit system; };
              feishin0_16_0 = import feishin0_16_0 { inherit system; };
            };
          }

          ./configuration.nix
          ./hardware-configuration/muskduck.nix # Include the results of the hardware scan.
        ];
      };
    };
}
