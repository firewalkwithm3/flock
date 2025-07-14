{
  description = "NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Stable nixpkgs.
    nixpkgs-pr-fluffychat.url = "github:NixOS/nixpkgs?ref=pull/419632/head"; # FluffyChat 2.0.0
    nixpkgs-pr-feishin.url = "github:NixOS/nixpkgs?ref=pull/414929/head"; # Feishin 0.17.0

    deploy-rs.url = "github:serokell/deploy-rs"; # Remote deployment
    lanzaboote.url = "github:nix-community/lanzaboote"; # Secure boot.
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # Hardware specific config.
    sops-nix.url = "github:Mic92/sops-nix"; # Secrets management.
    nixvim.url = "github:nix-community/nixvim"; # Neovim.

    # Secrets repo.
    secrets = {
      url = "git+ssh://git@docker.local:222/fern/secrets?ref=main";
      flake = false;
    };
  };

  outputs = {
    lanzaboote,
    nixos-hardware,
    sops-nix,
    ...
  } @ inputs: let
    helpers = import ./helpers.nix inputs;
    inherit (helpers) mergeHosts mkHost;
  in
    mergeHosts [
      (mkHost "muskduck" {
        suite = "desktop";
        extraModules = [
          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.lenovo-thinkpad-t480
        ];
      })

      (mkHost "weebill" {
        suite = "server";
        platform = "aarch64-linux";
        extraModules = [
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      })

      # (mkHost "docker" {
      #   suite = "vm";
      #   user = "docker";
      # })

      (mkHost "minecraft" {
        suite = "vm";
        user = "docker";
      })

      (mkHost "technitium" {
        suite = "lxc";
      })

      (mkHost "firefox-syncserver" {
        suite = "lxc";
        extraModules = [
          sops-nix.nixosModules.sops
        ];
      })
    ];
}
