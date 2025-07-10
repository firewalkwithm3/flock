{
  pkgs,
  userPackages,
  lib,
  ...
}:
with lib; {
  # Configure the bootloader.
  boot = {
    # Enable secure boot.
    bootspec.enable = true;
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = mkForce false;
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
      extraGSettingsOverridePackages = [pkgs.mutter];
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
    with pkgs; [
      epiphany # Browser (replaced by Firefox).
      gnome-connections # Remote desktop viewer.
      gnome-console # Terminal (replaced by ghostTTY).
      gnome-maps # Maps viewer.
      gnome-music # Music player.
      gnome-tour # First-boot tour.
      totem # Movie player (replaced by Celluloid).
      yelp # Help viewer.
    ]
  );

  # Remove NixOS HTML manual
  documentation.doc.enable = false;

  # Run electron apps under wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Install some packages.
  programs = {
    steam.enable = true;
    firefox.enable = true;
  };

  environment.systemPackages = with pkgs; [
    adwsteamgtk
    ansible
    caligula
    celluloid
    discord
    ghostty
    gimp3
    glabels-qt
    gnome-tweaks
    gnomeExtensions.auto-move-windows
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.smile-complementary-extension
    jellyfin-media-player
    libreoffice
    merriweather
    merriweather-sans
    nerd-fonts.fira-code
    obsidian
    protonmail-desktop
    signal-desktop
    smile
    userPackages.feishin
    yubioath-flutter

    # PrismLauncher with temurin jre.
    (prismlauncher.override {
      jdks = [
        temurin-jre-bin
      ];
    })

    # FluffyChat 2.0.0 with fixed desktop item.
    (userPackages.fluffychat.overrideAttrs (
      finalAttrs: previousAttrs: {
        desktopItems = [
          ((builtins.elemAt previousAttrs.desktopItems 0).override {startupWMClass = "fluffychat";})
        ];
      }
    ))
  ];

  # Enable gamemode service.
  programs.gamemode.enable = true;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [pkgs.brlaser];
  };

  # If you don't set this Wireguard won't work.
  networking.firewall.checkReversePath = false;

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
  services.power-profiles-daemon.enable = mkForce false; # enabled by gnome
  services.tlp.enable = mkForce false; # enabled by nixos-hardware
  services.auto-cpufreq.enable = true;
}
