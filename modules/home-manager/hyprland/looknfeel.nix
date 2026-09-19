{
  config,
  pkgs,
  ...
}:
let
  hexToRgba =
    hex: alpha:
    let
    in
    "rgba(${hex}${alpha})";

  inactiveBorder = hexToRgba config.colorScheme.palette.base09 "aa";
  activeBorder = hexToRgba config.colorScheme.palette.base0D "aa";
in
{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 5;
      gaps_out = 10;

      border_size = 2;

      "col.active_border" = activeBorder;
      "col.inactive_border" = inactiveBorder;

      resize_on_border = false;

      allow_tearing = false;

      layout = "dwindle";
    };

    decoration = {
      rounding = 4;

      shadow = {
        enabled = false;
        range = 30;
        render_power = 3;
        color = "rgba(00000045)";
      };

      blur = {
        enabled = true;
        size = 5;
        passes = 2;

        vibrancy = 0.1696;
      };
    };

    dwindle = {
      preserve_split = true;
      force_split = 2;
    };

    master = {
      new_status = "master";
    };

    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };
  };
}
