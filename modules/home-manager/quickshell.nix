{
  config,
  pkgs,
  ...
}:
let
  palette = config.colorScheme.palette;
in
{
  home.file = {
    ".config/quickshell/" = {
      source = ../../config/quickshell;
      recursive = true;
    };

    # Deliberately OUTSIDE the tree above: a second home.file entry writing into
    # a recursively-managed directory fights it, and a .qml that only exists
    # after activation cannot be run from the working tree with `qs -p`.
    ".config/omarchy/palette.json".text = builtins.toJSON {
      inherit (palette)
        base00
        base01
        base02
        base03
        base04
        base05
        base06
        base07
        base08
        base09
        base0A
        base0B
        base0C
        base0D
        base0E
        base0F
        ;
    };
  };

  home.packages = [ pkgs.quickshell ];
}
