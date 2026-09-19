{
  config,
  pkgs,
  ...
}:
let
  wallpaper = import ../../lib/selected-wallpaper.nix config;
in
{
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../config/themes/wallpapers;
      recursive = true;
    };
  }
  # Copy any custom desktop/lock wallpapers into ~/Pictures/Wallpapers too.
  // wallpaper.wallpaperFiles;

  home.packages = [ pkgs.hyprpaper ];

  services.hyprpaper = {
    enable = true;
    # Config file only; hyprpaper itself is launched via exec-once in
    # autostart.nix, per the hyprpaper wiki. The home-manager systemd
    # unit races Hyprland's startup (see autostart.nix for details).
    package = null;
    # hyprpaper 0.8 replaced the old `preload=` / `wallpaper=<mon>,<path>`
    # keywords with a `wallpaper { ... }` section; the old syntax parses
    # without error but leaves every monitor without a target (black desktop).
    settings = {
      wallpaper = {
        monitor = ""; # empty = all monitors
        path = wallpaper.wallpaper_path;
        fit_mode = "cover";
      };
    };
  };
}
