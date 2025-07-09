{
  pkgs,
  lib,
  hostname,
  user,
  ...
}:
with lib;
{
  # NixOS version.
  system.stateVersion = "25.05";

  # Enable flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable redistributable firmware.
  hardware.enableRedistributableFirmware = true;

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

  # Enable networking.
  networking.networkmanager.enable = true;

  # Set hostname
  networking.hostName = hostname;

  # Define a user account.
  users.users.${user} = {
    isNormalUser = true;
    description = mkIf (user == "fern") "Fern Garden";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  # Use fish shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function n --wraps nnn --description 'support nnn quit and change directory'
          if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
              echo "nnn is already running"
              return
          end

          if test -n "$XDG_CONFIG_HOME"
              set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
          else
              set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
          end

          command ${pkgs.nnn}/bin/nnn $argv

          if test -e $NNN_TMPFILE
              source $NNN_TMPFILE
              rm -- $NNN_TMPFILE
          end
      end
    '';
  };

  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  }; # https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell

  # Install some packages.
  programs.git.enable = true;

  programs.nvf = {
    enable = true;
    defaultEditor = true;

    settings.vim = {
      autocomplete.blink-cmp.enable = true;
      undoFile.enable = true;
      lineNumberMode = "number";

      options = rec {
        shiftwidth = 2;
        tabstop = shiftwidth;
        softtabstop = shiftwidth;
        expandtab = true;
      };

      languages.nix = {
        enable = true;
        treesitter.enable = true;
        lsp = {
          enable = true;
          server = "nixd";
        };
        format = {
          enable = true;
          type = "alejandra";
        };
      };
      
      extraPlugins = {
        kanagawa-nvim = {
          package = pkgs.vimPlugins.kanagawa-nvim;
          setup = ''
            require("kanagawa").load("dragon")
          '';
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    aria2
    btop
    lynx
    ncdu
    nnn
    rsync
    tmux
    trash-cli
  ];

  # Enable avahi hostname resolution.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
}
