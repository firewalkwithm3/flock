{
  nixpkgs,
  userPackages,
  pkgs,
  lib,
  hostname,
  user,
  ...
}:
with lib; {
  # NixOS version.
  system.stateVersion = "25.05";

  # Enable flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Add @wheel to trusted-users for remote deployments.
  nix.settings.trusted-users = ["root" "@wheel"];

  # Set $NIX_PATH to flake input.
  nix.nixPath = ["nixpkgs=${nixpkgs}"];

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
      # set gruvbox theme
      theme_gruvbox dark hard

      # yazi cd on quit.
      function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        ${pkgs.yazi}/bin/yazi $argv --cwd-file="$tmp"
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
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365/2
  documentation.man.generateCaches = false;

  # Install some packages.
  programs = {
    git.enable = true;
    lazygit.enable = true;

    nixvim = {
      enable = true;

      dependencies.ripgrep.enable = true;

      globals.mapleader = " ";

      keymaps = [
        {
          key = "<Leader>tt";
          action = "<cmd> ToggleTerm direction=float <CR>";
        }
        {
          key = "<Leader>xx";
          action = "<cmd> Trouble diagnostics toggle focus=false<CR>";
        }
      ];

      colorschemes.gruvbox = {
        enable = true;
        settings.contrast = "hard";
      };

      opts = rec {
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
              settings.formatting.command = ["${pkgs.alejandra}/bin/alejandra"];
              settings.options.nixos.expr = "(builtins.getFlake (builtins.toString /home/fern/Repositories/flock)).nixosConfigurations.muskduck.options";
            };
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
    flavors."gruvbox-dark.yazi" = userPackages.yazi-flavour-gruvbox-dark;
    settings.theme = {
      flavor.dark = "gruvbox-dark";
    };
  };

  environment.systemPackages = with pkgs; [
    aria2
    btop
    fishPlugins.gruvbox
    lynx
    ncdu
    rsync
    tmux
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
    };
  };
}
