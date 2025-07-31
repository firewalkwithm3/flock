{
  description = "NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Stable nixpkgs.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # Unstable nixpkgs.
    nixpkgs-pr-feishin.url = "github:NixOS/nixpkgs?ref=pull/414929/head"; # Feishin 0.17.0

    deploy-rs.url = "github:serokell/deploy-rs"; # Remote deployment.
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # Hardware specific config.

    # Secure boot.
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets repo.
    secrets = {
      url = "git+ssh://git@docker.local:222/fern/secrets?ref=main";
      flake = false;
    };

    # Home manager.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim.
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixos-hardware, ...} @ inputs: let
    # Import helpers & make functions available.
    helpers = import ./helpers.nix inputs;
    inherit (helpers) mergeHosts mkHost;
  in
    mergeHosts [
      # ThinkPad T480.
      (mkHost "muskduck" {
        suite = "desktop";
        hostModules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-t480
        ];
      })

      # ThinkPad X220.
      (mkHost "pardalote" {
        suite = "desktop";
        hostModules = [
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
      })
    ];
}
