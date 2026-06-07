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

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        wallpaper.wallpaper_path
      ];
      wallpaper = [
        ",${wallpaper.wallpaper_path}"
      ];
    };
  };
}
