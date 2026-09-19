inputs:
{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./hyprland/configuration.nix ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # home-manager >= 26.05 defaults configType to "lua" (writes hyprland.lua).
    # The lua backend renders every setting as `hl.<name>(<value>)`, which does
    # not understand the hyprlang string form used throughout ./hyprland/*.nix
    # (e.g. `bind = [ "SUPER, space, exec, walker" ]` becomes a single-argument
    # hl.bind call). Hyprland 0.56 still reads hyprland.conf, so pin hyprlang
    # explicitly until these modules are ported to the lua API.
    configType = "hyprlang";
  };
  services.hyprpolkitagent.enable = true;
}
