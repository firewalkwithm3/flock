{
  pkgs,
  lib,
  ...
}:
with lib; {
  imports = [../.]; # Common config.

  # Configure the bootloader.
  boot = {
    # Use linux-zen kernel.
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;

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

    # Allow emulating aarch64 to build for Raspberry Pi.
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  # Enable zram swap.
  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };

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
    desktopManager.gnome.enable = true;
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
      evince # Document viewer (replaced by papers, which will become default on Gnome 49).
      gnome-connections # Remote desktop viewer.
      gnome-console # Terminal (replaced by ghostTTY).
      gnome-maps # Maps viewer.
      gnome-music # Music player.
      gnome-tour # First-boot tour.
      simple-scan # Scanning app (replaced by naps2).
      totem # Movie player (replaced by Celluloid).
      yelp # Help viewer.
    ]
  );

  # Run electron apps under wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # dconf settings.
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        # virt-manager autoconnect.
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };

        # Gnome settings.
        "org/gnome/desktop/interface" = {
          accent-color = "green";
          clock-show-seconds = true;
          clock-show-weekday = true;
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
          show-battery-percentage = true;
        };

        "org/gnome/desktop/background" = let
          wallpaper = pkgs.copyPathToStore ./wallpaper.jpg;
        in {
          picture-uri = wallpaper;
          picture-uri-dark = wallpaper;
        };

        "org/gnome/shell" = {
          favorite-apps = gvariant.mkEmptyArray (gvariant.type.string);
          enabled-extensions = with pkgs; [
            gnomeExtensions.adw-gtk3-colorizer.extensionUuid
            gnomeExtensions.alphabetical-app-grid.extensionUuid
            gnomeExtensions.auto-move-windows.extensionUuid
            gnomeExtensions.caffeine.extensionUuid
            gnomeExtensions.color-picker.extensionUuid
            gnomeExtensions.rounded-window-corners-reborn.extensionUuid
            gnomeExtensions.smile-complementary-extension.extensionUuid
          ];
        };

        "org/gnome/desktop/preferences" = {
          num-workspaces = gvariant.mkInt32 4;
        };

        "org/gnome/mutter" = {
          dynamic-workspaces = false;
          experimental-features = [
            "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
            "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
          ];
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-automatic = false;
        };

        "org/gnome/desktop/peripherals/touchpad" = {
          natural-scroll = false;
          two-finger-scrolling-enabled = true;
        };

        "org/gnome/desktop/wm/keybindings" = {
          close = ["<Super>q"];
          move-to-workspace-1 = ["<Shift><Super>1"];
          move-to-workspace-2 = ["<Shift><Super>2"];
          move-to-workspace-3 = ["<Shift><Super>3"];
          move-to-workspace-4 = ["<Shift><Super>4"];
          switch-to-workspace-1 = ["<Super>1"];
          switch-to-workspace-2 = ["<Super>2"];
          switch-to-workspace-3 = ["<Super>3"];
          switch-to-workspace-4 = ["<Super>4"];
          toggle-maximized = ["<Super>m"];
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          ];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Open Emoji Picker";
          command = "smile";
          binding = "<Super>period";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          name = "Open Terminal";
          command = "ghostty";
          binding = "<Super>Return";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          name = "Open Files";
          command = "nautilus";
          binding = "<Super>e";
        };

        # Applications.
        "io/github/Foldex/AdwSteamGtk" = {
          color-theme-options = "Adwaita";
          hide-whats-new-switch = false;
          library-sidebar-options = "Show";
          login-qr-options = "Show";
          no-rounded-corners-switch = false;
          prefs-beta-support = false;
          window-controls-layout-options = "Auto";
          window-controls-options = "Adwaita";
        };

        # Extensions.
        "org/gnome/shell/extensions/auto-move-windows" = {
          application-list = ["Fluffychat.desktop:2" "signal.desktop:2" "proton-mail.desktop:2" "feishin.desktop:3" "org.prismlauncher.PrismLauncher.desktop:4" "steam.desktop:4" "discord.desktop:2"];
        };

        "org/gnome/shell/extensions/alphabetical-app-grid" = {
          folder-order-position = "start";
        };

        "org/gnome/shell/extensions/caffeine" = {
          enable-fullscreen = false;
          enable-mpris = false;
          indicator-position = gvariant.mkInt32 0;
          indicator-position-index = gvariant.mkInt32 0;
          indicator-position-max = gvariant.mkInt32 4;
          restore-state = false;
          show-indicator = "only-active";
        };

        "org/gnome/shell/extensions/color-picker" = {
          enable-notify = false;
          enable-preview = true;
          enable-shortcut = true;
          enable-sound = false;
          enable-systray = false;
          persistent-mode = false;
        };
      };
    }
  ];

  # Virtualisation.
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["fern"];
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
      };
    };
  };

  # Install some packages.
  programs = {
    steam.enable = true;
    firefox.enable = true;
  };

  environment.systemPackages = with pkgs; [
    adw-gtk3
    adwsteamgtk
    caligula
    celluloid
    cura-appimage
    deploy-rs
    feishin
    fluffychat
    fusee-nano
    ghostty
    gimp3
    glabels-qt
    gnome-tweaks
    gnomeExtensions.adw-gtk3-colorizer
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.auto-move-windows
    gnomeExtensions.caffeine
    gnomeExtensions.color-picker
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.smile-complementary-extension
    hunspell
    hunspellDicts.en_AU
    inkscape
    jellyfin-media-player
    libreoffice
    minipro
    naps2
    nextcloud-client
    ns-usbloader
    obsidian
    papers
    prismlauncher
    protonmail-desktop
    rockbox-utility
    rpi-imager
    signal-desktop
    smile
    via
    webcord
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

  # Enable configuration of keyboard.
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [pkgs.via];

  # Nintendo Switch udev rules.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7321", MODE="0666"
  '';

  # Enable gamemode service.
  programs.gamemode.enable = true;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [pkgs.brlaser pkgs.cups-dymo]; # Brother laser printer & Dymo label printer.
  };

  # Scanner drivers.
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.cnijfilter2];
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
}
