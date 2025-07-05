{
  pkgs,
  lib,
  feishin0_17,
  fluffychat2,
  ...
}:

{
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
      settings.timeout = 0;
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

  # Enable zRAM swap
  zramSwap.enable = true;

  # Enable smart card support (for YubiKey).
  services.pcscd.enable = true;

  # Enable networking.
  networking.networkmanager.enable = true;

  # Define a user account.
  users.users.fern = {
    isNormalUser = true;
    description = "Fern Garden";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Encrypt user's home with fscrypt
  security.pam.enableFscrypt = true;

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

  # Theme QT applications
  qt = {
    enable = true;
    style = "adwaita-dark";
  };

  # Exclude some default gnome applications.
  environment.gnome.excludePackages = (
    with pkgs;
    [
      epiphany
      gnome-connections
      gnome-console
      gnome-maps
      gnome-music
      gnome-tour
      totem
      yelp
    ]
  );

  # Remove NixOS HTML manual
  documentation.doc.enable = false;

  # Use ghostty for the "open in terminal" option in file manager.
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty";
  };

  # Run electron apps under wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Install some packages.
  programs.steam.enable = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    adwsteamgtk
    ansible
    celluloid
    discord
    feishin0_17.feishin
    ghostty
    gimp3
    glabels-qt
    gnome-tweaks
    gnomeExtensions.auto-move-windows
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.smile-complementary-extension
    jellyfin-media-player
    libreoffice
    nixd # nix language server
    nixfmt-rfc-style # nix language formatter
    obsidian
    protonmail-desktop
    signal-desktop
    smile
    vscodium
    yubioath-flutter

    # PrismLauncher with temurin jre.
    (prismlauncher.override {
      jdks = [
        temurin-jre-bin
      ];
    })

    # FluffyChat 2.0.0 with fixed desktop item.
    (fluffychat2.fluffychat.overrideAttrs (
      finalAttrs: previousAttrs: {
        desktopItems = [
          ((builtins.elemAt previousAttrs.desktopItems 0).override { startupWMClass = "fluffychat"; })
        ];
      }
    ))
  ];

  # Enable gamemode service
  programs.gamemode.enable = true;

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
