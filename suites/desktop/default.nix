{
  pkgs,
  lib,
  ...
}:
with lib; {
  imports = [../.]; # Common config.

  # Configure the bootloader.
  boot = {
    # Enable systemd-boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

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

  # Enable zram swap.
  zramSwap.enable = true;

  # Enable smart card support (for YubiKey).
  services.pcscd.enable = true;

  # Encrypt user's home with fscrypt
  security.pam.enableFscrypt = true;

  # Enable the GNOME Desktop Environment.
  services.xserver = {
    enable = true;

    excludePackages = [
      pkgs.xterm # Don't install xterm.
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
    platformTheme = "gnome";
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
    caligula
    celluloid
    discord
    feishin
    fluffychat
    ghostty
    gimp3
    glabels-qt
    gnome-tweaks
    gnomeExtensions.auto-move-windows
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.smile-complementary-extension
    jellyfin-media-player
    libreoffice
    obsidian
    prismlauncher
    protonmail-desktop
    signal-desktop
    smile
    yubioath-flutter
  ];

  fonts.packages = with pkgs; [
    merriweather
    iosevka
  ];

  # Allow opening terminal applications from gnome app launcher.
  xdg.terminal-exec = {
    enable = true;
    settings.default = ["ghostty.desktop"];
  };

  # Enable gamemode service.
  programs.gamemode.enable = true;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [pkgs.brlaser pkgs.cups-dymo];
  };

  # https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111
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

  # Home manager settings.
  home-manager.users.fern = {
    # Ghostty settings.
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "IosevkaCustom";
        theme = "GruvboxDarkHard";
      };
    };

    # Gnome settings.
    dconf.settings = let
      wallpaper = pkgs.fetchurl {
        url = "https://git.fern.garden/fern/flock/raw/branch/main/suites/desktop/wallpaper.jpg";
        hash = "sha256-NOEJy8Tlag7pySdQnwxARJHFTzLpfwrwfksnH0/y8Mc=";
      };
    in {
      "org/gnome/desktop/interface".accent-color = "green"; # Main colour used throughout interface.
      "org/gnome/desktop/interface".clock-show-seconds = true; # Show seconds on menubar clock.
      "org/gnome/desktop/interface".clock-show-weekday = true; # Show weekday on menubar clock.
      "org/gnome/desktop/interface".color-scheme = "prefer-dark"; # Dark mode.
      "org/gnome/desktop/interface".enable-hot-corners = false; # Disable hot corner activation.
      "org/gnome/desktop/interface".show-battery-percentage = true; # Display battery percentage in menubar.
      "org/gnome/desktop/peripherals/touchpad".natural-scroll = false; # Disable natural scrolling on trackpad.
      "org/gnome/desktop/session".idle-delay = 300; # Switch off display after 5 minutes of activity.
      "org/gnome/desktop/wm/preferences".num-workspaces = 5; # Make 5 workspaces available.
      "org/gnome/mutter".dynamic-workspaces = false; # Specify number of workspaces (see previous).
      "org/gnome/settings-daemon/plugins/color".night-light-enabled = true; # Enable night light.
      "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing"; # Don't automatically suspend when charging.
      "org/gnome/settings-daemon/plugins/power".sleep-inactive-battery-timeout = 1800; # Automatically suspend after 30 minutes on battery.

      # Keybinds
      "org/gnome/desktop/wm/keybindings".move-to-workspace-1 = ["<Shift><Super>1"]; # Move window to workspace 1.
      "org/gnome/desktop/wm/keybindings".move-to-workspace-2 = ["<Shift><Super>2"]; # Move window to workspace 2.
      "org/gnome/desktop/wm/keybindings".move-to-workspace-3 = ["<Shift><Super>3"]; # Move window to workspace 3.
      "org/gnome/desktop/wm/keybindings".move-to-workspace-4 = ["<Shift><Super>4"]; # Move window to workspace 4.
      "org/gnome/desktop/wm/keybindings".switch-to-workspace-1 = ["<Super>1"]; # Switch to workspace 1.
      "org/gnome/desktop/wm/keybindings".switch-to-workspace-2 = ["<Super>2"]; # Switch to workspace 2.
      "org/gnome/desktop/wm/keybindings".switch-to-workspace-3 = ["<Super>3"]; # Switch to workspace 3.
      "org/gnome/desktop/wm/keybindings".switch-to-workspace-4 = ["<Super>4"]; # Switch to workspace 4.

      "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>period";
        command = "smile";
        name = "Open Emoji Picker";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Super>Return";
        command = "ghostty";
        name = "Open Terminal";
      };

      "org/gnome/desktop/background".picture-uri = "file://${wallpaper}";
      "org/gnome/desktop/background".picture-uri-dark = "file://${wallpaper}";
    };
  };
}
