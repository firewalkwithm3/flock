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

    # Allow emulating aarch64 to build for Raspberry Pi.
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

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

  # Run electron apps under wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
    deploy-rs
    discord
    feishin
    fluffychat
    fusee-nano
    ghostty
    gimp3
    glabels-qt
    gnome-tweaks
    gnomeExtensions.adw-gtk3-colorizer
    gnomeExtensions.auto-move-windows
    gnomeExtensions.color-picker
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.smile-complementary-extension
    jellyfin-media-player
    libreoffice
    nextcloud-client
    ns-usbloader
    obsidian
    prismlauncher
    protonmail-desktop
    rockbox-utility
    signal-desktop
    smile
    via
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

    # virt-manager - autoconnect to qemu.
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
