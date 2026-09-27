{
  config,
  pkgs,
  ...
}:
{
  home.file = {
    # Icon colors for omarchy-power-menu, sourced by the script at runtime.
    ".config/wofi/power-colors.sh" = {
      text = ''
        lock_fg="#${config.colorScheme.palette.base0D}"
        logout_fg="#${config.colorScheme.palette.base0E}"
        suspend_fg="#${config.colorScheme.palette.base0C}"
        reboot_fg="#${config.colorScheme.palette.base0A}"
        shutdown_fg="#${config.colorScheme.palette.base08}"
      '';
    };

    # Standalone theme for the power menu: compact, centered, icon-first.
    ".config/wofi/power.css" = {
      text = ''
        * {
          font-family: 'CaskaydiaMono Nerd Font', monospace;
          font-size: 18px;
        }

        window {
          margin: 0;
          padding: 0;
          border: 2px solid #${config.colorScheme.palette.base0D};
          border-radius: 14px;
          background-color: #${config.colorScheme.palette.base00};
        }

        #outer-box {
          margin: 0;
          padding: 12px;
          border: none;
          background-color: transparent;
        }

        #input {
          margin: 0 0 10px 0;
          padding: 10px 14px;
          border: none;
          border-radius: 10px;
          background-color: #${config.colorScheme.palette.base01};
          color: #${config.colorScheme.palette.base05};
        }

        #input:focus {
          outline: none;
          box-shadow: none;
          border: none;
        }

        #inner-box,
        #scroll {
          margin: 0;
          padding: 0;
          border: none;
          background-color: transparent;
        }

        #entry {
          margin: 2px 0;
          padding: 10px 14px;
          border-radius: 10px;
          background-color: transparent;
        }

        #entry:selected {
          outline: none;
          border: none;
          background-color: #${config.colorScheme.palette.base02};
        }

        #text {
          margin: 0;
          border: none;
          color: #${config.colorScheme.palette.base05};
        }

        #entry:selected #text {
          color: #${config.colorScheme.palette.base07};
        }
      '';
    };

    ".config/wofi/style.css" = {
      text = ''
        * {
          font-family: 'CaskaydiaMono Nerd Font', monospace;
          font-size: 18px;
        }

        window {
          margin: 0px;
          padding: 20px;
          background-color: #${config.colorScheme.palette.base00};
          opacity: 0.95;
        }

        #inner-box {
          margin: 0;
          padding: 0;
          border: none;
          background-color: #${config.colorScheme.palette.base00};
        }

        #outer-box {
          margin: 0;
          padding: 20px;
          border: none;
          background-color: #${config.colorScheme.palette.base00};
        }

        #scroll {
          margin: 0;
          padding: 0;
          border: none;
          background-color: #${config.colorScheme.palette.base00};
        }

        #input {
          margin: 0;
          padding: 10px;
          border: none;
          background-color: #${config.colorScheme.palette.base00};
          color: @text;
        }

        #input:focus {
          outline: none;
          box-shadow: none;
          border: none;
        }

        #text {
          margin: 5px;
          border: none;
          color: #${config.colorScheme.palette.base06};
        }

        #entry {
          background-color: #${config.colorScheme.palette.base00};
        }

        #entry:selected {
          outline: none;
          border: none;
        }

        #entry:selected #text {
          color: #${config.colorScheme.palette.base02};
        }

        #entry image {
          -gtk-icon-transform: scale(0.7);
        }
      '';
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 350;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
    };
  };
}
