# Every omarchy.lid backend is imported; each one gates itself on
# `omarchy.lid.backend`, so only the selected one contributes config.
{
  imports = [ ./hyprland.nix ];
}
