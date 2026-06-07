config:
let
  cfg = config.omarchy;

  # hyprpaper / hyprlock do NOT expand "~", they require an absolute path.
  homeDir = config.home.homeDirectory;
  wallpaperDir = "${homeDir}/Pictures/Wallpapers";

  wallpapers = {
    "tokyo-night" = [
      "1-Pawel-Czerwinski-Abstract-Purple-Blue.jpg"
    ];
    "kanagawa" = [
      "kanagawa-1.png"
    ];
    "everforest" = [
      "1-everforest.jpg"
    ];
    "nord" = [
      "nord-1.png"
    ];
    "gruvbox" = [
      "gruvbox-1.jpg"
    ];
    "gruvbox-light" = [
      "gruvbox-1.jpg"
    ];
  };

  # A custom desktop wallpaper is used for generated themes and for any theme
  # that overrides the wallpaper via theme_overrides.wallpaper_path.
  usesCustomDesktopWallpaper =
    (cfg.theme == "generated_light" || cfg.theme == "generated_dark")
    || (cfg.theme_overrides.wallpaper_path != null);

  desktopWallpaperName =
    if usesCustomDesktopWallpaper then
      builtins.baseNameOf cfg.theme_overrides.wallpaper_path
    else
      builtins.elemAt (wallpapers.${cfg.theme}) 0;

  # Absolute path to the desktop wallpaper inside ~/Pictures/Wallpapers.
  wallpaper_path = "${wallpaperDir}/${desktopWallpaperName}";

  # Lock screen wallpaper: user-configured override or fall back to the desktop one.
  usesCustomLockWallpaper = cfg.hyprlock_wallpaper != null;

  lockWallpaperName =
    if usesCustomLockWallpaper then
      builtins.baseNameOf cfg.hyprlock_wallpaper
    else
      desktopWallpaperName;

  hyprlock_wallpaper_path = "${wallpaperDir}/${lockWallpaperName}";

  # Extra home.file entries that copy custom wallpapers (from arbitrary
  # configured paths) into ~/Pictures/Wallpapers so hyprpaper/hyprlock can
  # always reference them from a single, stable, absolute location.
  customDesktopFile =
    if usesCustomDesktopWallpaper then
      {
        "Pictures/Wallpapers/${desktopWallpaperName}".source = cfg.theme_overrides.wallpaper_path;
      }
    else
      { };

  customLockFile =
    if usesCustomLockWallpaper then
      {
        "Pictures/Wallpapers/${lockWallpaperName}".source = cfg.hyprlock_wallpaper;
      }
    else
      { };

  wallpaperFiles = customDesktopFile // customLockFile;
in
{
  inherit wallpaper_path hyprlock_wallpaper_path wallpaperFiles;
}
