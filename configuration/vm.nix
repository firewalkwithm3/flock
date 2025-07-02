{
  pkgs,
  ...
}:

{
  # NixOS version.
  system.stateVersion = "25.05";

  # Enable flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Configure the bootloader.
  boot.loader.grub = { 
    enable = true;
    device = "/dev/sda";
  };

  # Set time zone.
  time.timeZone = "Australia/Perth";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Configure keymap in X11.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account.
  users.users.docker = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  # Install some packages.
  programs.git.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true; # Use neovim as default terminal editor.
    configure = {
      customRC = ''
        set expandtab
        set shiftwidth=2
        set tabstop=8
        set softtabstop=2
        set number
        colorscheme kanagawa-dragon
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ kanagawa-nvim ];
      };
    };
  };

  # Enable SSH server
  services.openssh.enable = true;
  
  # Enable avahi hostname resolution.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
}
