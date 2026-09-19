lib: {
  omarchyOptions = {
    full_name = lib.mkOption {
      type = lib.types.str;
      description = "Main user's full name";
    };
    email_address = lib.mkOption {
      type = lib.types.str;
      description = "Main user's email address";
    };
    theme = lib.mkOption {
      type = lib.types.either (lib.types.enum [
        "tokyo-night"
        "kanagawa"
        "everforest"
        "catppuccin"
        "nord"
        "gruvbox"
        "gruvbox-light"
        "generated_light"
        "generated_dark"
      ]) lib.types.str;
      default = "tokyo-night";
      description = "Theme to use for Omarchy configuration";
    };
    theme_overrides = lib.mkOption {
      type = lib.types.submodule {
        options = {
          wallpaper_path = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to the wallpaper image to extract colors from";
          };
        };
      };
      default = { };
      description = "Theme overrides including wallpaper path for generated themes";
    };
    desktop_wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to the desktop (hyprpaper) wallpaper. Takes precedence over
        theme_overrides.wallpaper_path; falls back to the theme wallpaper when
        neither is set.
      '';
    };
    hyprlock_wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the hyprlock wallpaper => fallback to the desktop wallpaper if not specified";
    };
    primary_font = lib.mkOption {
      type = lib.types.str;
      default = "Liberation Sans 11";
    };
    vscode_settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    scale = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Display scale factor (1 for 1x displays, 2 for 2x displays)";
    };
    quick_app_bindings = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "A list of single keystroke key bindings to launch common apps.";
      default = [
        "SUPER, return, exec, $terminal"
        "SUPER, F, exec, $fileManager"
        "SUPER, B, exec, $browser"
        "SUPER, M, exec, $music"
        "SUPER, N, exec, $terminal -e nvim"
        "SUPER, T, exec, $terminal -e btop"
        "SUPER, D, exec, $terminal -e lazydocker"
        "SUPER, G, exec, $messenger"
        "SUPER, slash, exec, $passwordManager"
      ];
    };
    kill_app_binding = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "SUPER, W, killactive,"
        "SUPER, Backspace, killactive,"
      ];
      description = "Packages to exclude from the default system packages";
    };
    exclude_packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Packages to exclude from the default system packages";
    };
  };
}
