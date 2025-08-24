{
  inputs,
  pkgs,
  lib,
  hostname,
  ...
}:
with lib; {
  # NixOS version.
  system.stateVersion = "25.05";

  # nix config.
  nix = {
    # Set $NIX_PATH.
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    settings = {
      # Enable flakes.
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Limit nix build.
      cores = 0;
      max-jobs = 4;
    };
  };

  # Enable redistributable firmware.
  hardware.enableRedistributableFirmware = true;

  # Enable firmware updates.
  services.fwupd.enable = true;

  # Enable zram swap.
  zramSwap = {
    enable = true;
    algorithm = "lz4";
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

  # Enable networking.
  networking.networkmanager.enable = true;
  users.groups.networkmanager.members = ["fern"];

  # Set hostname
  networking.hostName = hostname;

  # Define a user account.
  users.users.fern = {
    isNormalUser = true;
    uid = 1000;
    description = "Fern Garden";
    extraGroups = ["wheel"];
  };

  # Use fish shell
  programs.fish = {
    enable = true;

    shellAbbrs = let
      flake = "/home/fern/Repositories/flock";
    in {
      ns = "nh os switch ${flake}";
      nt = "nh os test ${flake}";
      nb = "nh os boot ${flake}";
    };

    interactiveShellInit = let
      kanagawaTheme = builtins.readFile (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/rebelot/kanagawa.nvim/refs/heads/master/extras/fish/kanagawa.fish";
        hash = "sha256-2sRTcX/ktf4aiALCn4w88PiGF8K3BtUeSSIQOdDxtWo=";
      });
    in ''
      # Kanagawa theme.
      ${kanagawaTheme}

      # Disable greeting
      set fish_greeting

      # Yazi cd on quit.
      function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      end
    '';
  };

  # https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec fish $LOGIN_OPTION
      fi
    '';
  };

  # https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365/2
  documentation.man.generateCaches = false;

  # Enable all terminfo (for ghostty).
  environment.enableAllTerminfo = true;

  # Install some packages.
  programs = {
    git.enable = true;
    lazygit.enable = true;

    nixvim = {
      enable = true;

      # Set $EDITOR
      defaultEditor = true;

      # For telescope grep.
      dependencies.ripgrep.enable = true;

      # Space as leader.
      globals.mapleader = " ";

      keymaps = [
        {
          key = "<Leader>t";
          action = "<cmd> ToggleTerm direction=float <CR>";
        }
        {
          key = "<Leader>x";
          action = "<cmd> Trouble diagnostics toggle focus=false <CR>";
        }
        {
          key = "<Leader>y";
          action = "<cmd> Yazi <CR>";
        }
        {
          key = "<Leader>fs";
          action = "<cmd> SessionSearch <CR>";
        }
      ];

      colorschemes.kanagawa = {
        enable = true;
        settings = {
          background.dark = "dragon";
          colors.theme.all.ui.bg_gutter = "none";
        };
      };

      opts = rec {
        background = "dark";
        shiftwidth = 2;
        tabstop = shiftwidth;
        softtabstop = shiftwidth;
        expandtab = true;
        number = true;
        cursorline = true;
        undofile = true;
      };

      plugins = {
        auto-session.enable = true;
        bufferline.enable = true;
        colorizer.enable = true;
        comment.enable = true;
        gitsigns.enable = true;
        lsp-format.enable = true;
        notify.enable = true;
        nvim-autopairs.enable = true;
        nvim-surround.enable = true;
        toggleterm.enable = true;
        trouble.enable = true;
        web-devicons.enable = true;
        yazi.enable = true;

        lualine = {
          enable = true;
          settings.extensions = ["trouble" "toggleterm"];
        };

        telescope = {
          enable = true;
          keymaps = {
            "<Leader>ff" = "find_files";
            "<Leader>fg" = "live_grep";
            "<Leader>fb" = "buffers";
          };
        };

        blink-cmp = {
          enable = true;
          settings = {
            keymap = {
              preset = "enter";
              "<Tab>" = [
                "select_next"
                "fallback"
              ];
              "<S-Tab>" = [
                "select_prev"
                "fallback"
              ];
            };
            completion = {
              menu.auto_show = true;
              documentation.auto_show = true;
              list.selection.preselect = false;
            };
            cmdline = {
              keymap.preset = "inherit";
              completion = {
                menu.auto_show = true;
                list.selection.preselect = false;
              };
            };
          };
        };

        lsp = {
          enable = true;
          inlayHints = true;
          servers = {
            nixd = {
              enable = true;
              settings = {
                nixpkgs.expr = "import (builtins.getFlake (builtins.toString ${inputs.self})).inputs.nixpkgs { }";
                formatting.command = ["${pkgs.alejandra}/bin/alejandra"];
                options = {
                  nixos.expr = "(builtins.getFlake (builtins.toString ${inputs.self})).nixosConfigurations.${hostname}.options";
                  home-manager.expr = "(builtins.getFlake (builtins.toString ${inputs.self})).nixosConfigurations.${hostname}.options.home-manager.users.type.getSubOptions []";
                };
              };
            };
            docker_compose_language_service.enable = true;
          };
        };

        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            incremental_selection.enable = true;
            indent.enable = true;
          };
        };
      };
    };
  };

  programs.yazi = {
    enable = true;
    flavors."kanagawa-dragon.yazi" = pkgs.yazi-flavour-kanagawa-dragon;
    settings.theme.flavor.dark = "kanagawa-dragon";
  };

  programs.tmux = {
    enable = true;
    plugins = [pkgs.tmuxPlugins.kanagawa];
    extraConfigBeforePlugins = ''
      set -g @kanagawa-plugins " "
      set -g @kanagawa-theme "dragon"
      set -g @kanagawa-ignore-window-colors true
    '';
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep 5";
    };
  };

  environment.systemPackages = with pkgs; [
    aria2
    btop
    lynx
    ncdu
    rsync
    trash-cli
  ];

  # Enable avahi hostname resolution.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      userServices = true;
    };
  };
}
