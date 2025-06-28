{ config, pkgs, fluffychat2, feishin0_16_0, ... }:

{
  # Home manager options.
  home.username = "fern";
  home.homeDirectory = "/home/fern";
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Gnome extensions.
  programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [
    { package = rounded-window-corners-reborn; }
    { package = smile-complementary-extension; }
  ];

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
    bitwarden-desktop
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
    protonmail-desktop
    signal-desktop
    smile
    yubioath-flutter
  ];
}