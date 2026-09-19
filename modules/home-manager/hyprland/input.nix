{
  config,
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    # Environment variables
    # https://wiki.hyprland.org/Configuring/Variables/#input
    input = lib.mkDefault {
      kb_layout = "us";
      # kb_variant =
      # kb_model =
      kb_options = "caps:escape";
      # kb_rules =

      follow_mouse = 1;

      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

      touchpad = {
        natural_scroll = false;
        clickfinger_behavior = true;
        drag_3fg = 1;
      };
    };

    # https://wiki.hyprland.org/Configuring/Variables/#gestures
    gestures = lib.mkDefault {
      gesture = "3, horizontal, workspace";
      workspace_swipe_invert = false;
      workspace_swipe_distance = 400;
    };
  };
}
