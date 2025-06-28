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
          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.lenovo-thinkpad-t480
          ./configuration.nix
        ];
      };
    };
}
