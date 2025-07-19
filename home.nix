{
  config,
  pkgs,
  ...
}: {
  # Me!
  home.username = "fern";
  home.homeDirectory = "/home/fern";

  # Home manager version.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
