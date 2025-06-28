{
  pkgs,
  lib,
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
  boot = {
    # Enable secure boot.
    bootspec.enable = true;
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;
    loader.efi.canTouchEfiVariables = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # Enable quiet boot with splash
    plymouth.enable = true;
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };

  # Enable firmware updates.
  services.fwupd.enable = true;

  # Enable smart card support (for YubiKey).
  services.pcscd.enable = true;

  # Define hostname.
  networking.hostName = "muskduck";

  # Enable networking.
  networking.networkmanager.enable = true;

  # Set your time zone.
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
  users.users.fern = {
    isNormalUser = true;
    description = "Fern Garden";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Use fish shell.
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # Enable the GNOME Desktop Environment.
  services.xserver = {
    enable = true;

    excludePackages = with pkgs; [
      xterm # Don't install xterm.
    ];

    displayManager.gdm.enable = true;

    desktopManager.gnome = {
      enable = true;
      # Enable fractional scaling.
      extraGSettingsOverridePackages = [ pkgs.mutter ];
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']
      '';
    };
  };

  # Exclude some default gnome applications.
  environment.gnome.excludePackages = (with pkgs; [
    epiphany
    gnome-connections
    gnome-console
    gnome-maps
    gnome-music
    gnome-tour
    totem
    yelp
  ]);

  # Remove NixOS HTML manual
  documentation.doc.enable = false;

  # Use ghostty for the "open in terminal" option in file manager.
  programs.nautilus-open-any-terminal = { 
    enable = true; 
    terminal = "ghostty";
  };

  # Run electron apps under wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Gaming packages.
  programs.gamemode.enable = true;
  programs.steam.enable = true;

  # Allow avahi hostname resolution.
  services.avahi.nssmdns4 = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable CPU frequency scaling management.
  services.power-profiles-daemon.enable = lib.mkForce false; # enabled by gnome
  services.tlp.enable = lib.mkForce false; # enabled by nixos-hardware
  services.auto-cpufreq.enable = true;
}