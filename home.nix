{ config, pkgs, fluffychat2, feishin0_16_0, ... }:

{
  # Home manager options.
  home.username = "fern";
  home.homeDirectory = "/home/fern";
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Install some packages.
  programs.git.enable = true;
  programs.firefox.enable = true;
  
  programs.ghostty = { 
    enable = true; 
    settings.theme = "GruvboxDarkHard";
  };
  
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };

  home.packages = with pkgs; [
    adwsteamgtk
    ansible
    discord
    feishin0_16_0.feishin
    filezilla
    fluffychat2.fluffychat
    gimp3
    glabels-qt
    jellyfin-media-player
    libreoffice
    nixd # nix language server
    nixfmt-rfc-style # nix language formatter
    obsidian
    prismlauncher
    signal-desktop
    smile
    yubioath-flutter
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.smile-complementary-extension
  ];
}