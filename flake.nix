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
    nh.url = "github:nix-community/nh"; # Yet another Nix CLI helper.

    # Home manager.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    # Import helpers & make functions available.
    helpers = import ./helpers.nix inputs;
    inherit (helpers) mergeHosts mkHost;
  in
    mergeHosts [
      # ThinkPad T480.
      (mkHost "muskduck" {
        suite = "desktop";
        hostModules = [
          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.lenovo-thinkpad-t480
        ];
      })

      # ThinkPad X220.
      (mkHost "pardalote" {
        suite = "desktop";
        hostModules = [
          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.lenovo-thinkpad-x220
        ];
      })

      # Raspberry Pi 4B.
      (mkHost "weebill" {
        suite = "server";
        platform = "aarch64-linux";
        hostModules = [
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      })

      # VM running docker containers.
      (mkHost "docker" {
        suite = "server/vm";
        docker = true;
      })

      # VM running a Minecraft server.
      (mkHost "minecraft" {
        suite = "server/vm";
        docker = true;
      })

      # VM running a Musicbrainz mirror + lidarr metadata server.
      (mkHost "musicbrainz" {
        suite = "server/vm";
        docker = true;
      })

      # Container running Technitium DNS Server.
      (mkHost "technitium" {
        suite = "server/lxc";
      })

      # Container running Mozilla's syncstorage-rs
      (mkHost "firefox-syncserver" {
        suite = "server/lxc";
        hostModules = [
          sops-nix.nixosModules.sops
        ];
      })
    ];
}
