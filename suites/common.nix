{
  nixpkgs,
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETPyuxUVEmYyEW6PVC6BXqkhULHd/RvMm8fMbYhjTMV fern@muskduck"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzW4epTmK01kGVXcuAXUNJQPltnogf4uab9FA5m8S3n fern@pardalote"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEJYq1fMxVOzCMfE/td6DtWS8nUk76U9seYD3Z9RYAz u0_a399@fairywren"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMoJvPcUJDVVzO4dHROCFNlgJdDZSP5xyPx2s40zcx5QAAAABHNzaDo= YubiKey5NFC"
    ];
  };

  # Use fish shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # yazi cd on quit.
      function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        ${pkgs.yazi}/bin/yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      end

      # kanagawa theme.
      set -l foreground DCD7BA normal
      set -l selection 2D4F67 brcyan
      set -l comment 727169 brblack
      set -l red C34043 red
      set -l orange FF9E64 brred
      set -l yellow C0A36E yellow
      set -l green 76946A green
      set -l purple 957FB8 magenta
      set -l cyan 7AA89F cyan
      set -l pink D27E99 brmagenta

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
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

      globals.mapleader = " ";

      keymaps = [
        {
          key = "<Leader>t";
          action = "<cmd> ToggleTerm direction=float <CR>";
          mode = "n";
          options = {
            silent = true;
            desc = "Open floating terminal.";
          };
        }

        {
          key = "<Leader>g";
          action = "<cmd> LazyGit <CR>";
          mode = "n";
          options.desc = "Open LazyGit.";
        }

        {
          key = "<Leader>y";
          action = "<cmd> Yazi toggle <CR>";
          mode = "n";
          options.desc = "Show/hide file browser.";
        }

        {
          key = "<Leader>ff";
          action = "<cmd> Telescope fd <CR>";
          mode = "n";
          options.desc = "Find files.";
        }

        {
          key = "<Leader>fb";
          action = "<cmd> Telescope buffers <CR>";
          mode = "n";
          options.desc = "Switch between buffers with telescope.";
        }

        {
          key = "<Leader>fg";
          action = "<cmd> Telescope live_grep <CR>";
          mode = "n";
          options.desc = "Grep files.";
        }
      ];

      colorschemes.kanagawa = {
        enable = true;
        settings = {
          background.dark = "dragon";
          colors.theme.all.ui.bg_gutter = "none";
          overrides = ''
            function(colors)
              local theme = colors.theme
              return {
                NormalFloat = { bg = "none" },
                FloatBorder = { bg = "none" },
                FloatTitle = { bg = "none" },

                TelescopeTitle = { fg = theme.ui.special, bold = true },
                TelescopePromptNormal = { bg = theme.ui.bg_p1 },
                TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
                TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
                TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
                TelescopePreviewNormal = { bg = theme.ui.bg_dim },
                TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },

                Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },  -- add `blend = vim.o.pumblend` to enable transparency
                PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                PmenuSbar = { bg = theme.ui.bg_m1 },
                PmenuThumb = { bg = theme.ui.bg_p2 },
              }
            end,
          '';
        };
      };

      opts = rec {
        shiftwidth = 2;
        tabstop = shiftwidth;
        softtabstop = shiftwidth;
        expandtab = true;
        number = true;
        cursorline = true;
        undofile = true;
        clipboard = "unnamedplus";
      };

      clipboard.providers.wl-copy.enable = true;

      plugins = {
        colorizer.enable = true;
        comment.enable = true;
        gitsigns.enable = true;
        lazygit.enable = true;
        lsp-format.enable = true;
        mini-statusline.enable = true;
        mini-tabline.enable = true;
        notify.enable = true;
        nvim-autopairs.enable = true;
        telescope.enable = true;
        toggleterm.enable = true;
        trouble.enable = true;
        web-devicons.enable = true;
        which-key.enable = true;
        yazi.enable = true;

        blink-cmp = {
          enable = true;
          settings = {
            keymap.preset = "enter";
            menu.auto_show = true;
            completion.documentation.auto_show = true;
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

  environment.systemPackages = with pkgs; [
    aria2
    btop
    lynx
    ncdu
    rsync
    tmux
    trash-cli
    yazi
  ];

  # Enable SSH server.
  services.openssh.enable = true;

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
