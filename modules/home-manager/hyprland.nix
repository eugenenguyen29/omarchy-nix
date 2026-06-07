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
    # home-manager >= 26.05 defaults configType to "lua" (writes hyprland.lua),
    # but the pinned Hyprland still loads hyprland.conf. Force hyprlang so the
    # generated config is actually read by this Hyprland version.
    configType = "hyprlang";
  };
  services.hyprpolkitagent.enable = true;
}
