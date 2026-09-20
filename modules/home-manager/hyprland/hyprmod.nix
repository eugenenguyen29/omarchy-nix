inputs:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # hyprmod hardcodes this path (hyprmod/core/config.py: _DEFAULT_MANAGED_BASE)
  # and only offers an in-app override, so mirror it here rather than expose an
  # option that would have to be kept in sync on both sides.
  guiConf = "${config.home.homeDirectory}/.config/hypr/hyprland-gui.conf";
in
{
  home.packages = [ inputs.hyprmod.packages.${pkgs.stdenv.hostPlatform.system}.hyprmod ];

  # On first launch hyprmod appends this exact source line to hyprland.conf --
  # which it cannot do here, since home-manager renders that file as a read-only
  # /nix/store symlink. Writing the line ourselves makes its needs_setup() check
  # (hyprmod/core/setup.py) find the file already in the source chain, so it
  # skips setup and only ever writes hyprland-gui.conf.
  #
  # This has to go in extraConfig, not settings.source: home-manager's
  # sourceFirst defaults to true and hoists source entries to the top of the
  # file, where they would be overridden by everything below. extraConfig is
  # concatenated last, which is what gives hyprmod's edits precedence.
  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''

    # HyprMod managed settings
    source = ${guiConf}
  '';

  # hyprmod owns this file, so it must be a real writable file rather than a
  # store symlink -- home.file/xdg.configFile would defeat the whole point.
  # Hyprland logs a config error for a missing source target, hence creating it
  # empty up front.
  home.activation.hyprmodManagedConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e ${lib.escapeShellArg guiConf} ]; then
      run touch ${lib.escapeShellArg guiConf}
    fi
  '';
}
