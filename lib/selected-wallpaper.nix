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

  usesGeneratedTheme = cfg.theme == "generated_light" || cfg.theme == "generated_dark";

  # The desktop wallpaper is, in order of precedence:
  #   1. omarchy.desktop_wallpaper           -- explicit user choice
  #   2. omarchy.theme_overrides.wallpaper_path -- the image a generated theme
  #      derives its colours from, which doubles as the wallpaper
  #   3. the wallpaper shipped with the selected theme
  # The first two are arbitrary out-of-tree paths and must be copied in.
  customDesktopSource =
    if cfg.desktop_wallpaper != null then
      cfg.desktop_wallpaper
    else if usesGeneratedTheme || cfg.theme_overrides.wallpaper_path != null then
      cfg.theme_overrides.wallpaper_path
    else
      null;

  # Custom wallpapers are copied in under a side-specific prefix so that a
  # desktop and a lock image sharing a basename cannot clobber one another.
  desktopWallpaperName =
    if customDesktopSource != null then
      "desktop-${builtins.baseNameOf customDesktopSource}"
    else
      builtins.elemAt (wallpapers.${cfg.theme}) 0;

  # Absolute path to the desktop wallpaper inside ~/Pictures/Wallpapers.
  wallpaper_path = "${wallpaperDir}/${desktopWallpaperName}";

  # Lock screen wallpaper: user-configured override or fall back to the desktop one.
  customLockSource = cfg.hyprlock_wallpaper;

  lockWallpaperName =
    if customLockSource != null then
      "lock-${builtins.baseNameOf customLockSource}"
    else
      desktopWallpaperName;

  hyprlock_wallpaper_path = "${wallpaperDir}/${lockWallpaperName}";

  # Extra home.file entries that copy custom wallpapers (from arbitrary
  # configured paths) into ~/Pictures/Wallpapers so hyprpaper/hyprlock can
  # always reference them from a single, stable, absolute location.
  customDesktopFile =
    if customDesktopSource != null then
      {
        "Pictures/Wallpapers/${desktopWallpaperName}".source = customDesktopSource;
      }
    else
      { };

  customLockFile =
    if customLockSource != null then
      {
        "Pictures/Wallpapers/${lockWallpaperName}".source = customLockSource;
      }
    else
      { };

  wallpaperFiles = customDesktopFile // customLockFile;
in
{
  inherit wallpaper_path hyprlock_wallpaper_path wallpaperFiles;
}
