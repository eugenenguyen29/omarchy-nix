{ pkgs }:
let
  inherit (pkgs) qt6;

  # QML modules that should be visible to the qml runtime, qmlls and qmllint.
  qmlModules = [
    qt6.qtdeclarative
    qt6.qt5compat
    qt6.qtmultimedia
    qt6.qtquick3d
    qt6.qtsvg
    pkgs.quickshell
    pkgs.kdePackages.qqc2-desktop-style
  ];

  qmlImportPath = pkgs.lib.concatMapStringsSep ":" (p: "${p}/lib/qt-6/qml") qmlModules;
in
pkgs.mkShell {
  name = "qt-qml";

  # wrapQtAppsHook is here for its environment hooks, not for wrapping:
  # the shellHook below replays them so Qt tools find their plugins.
  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    pkgs.makeWrapper

    # Build system / toolchain
    pkgs.cmake
    pkgs.ninja
    pkgs.pkg-config
    pkgs.gcc
    pkgs.gdb

    # qmake, for projects that predate CMake
    qt6.qmake
  ];

  buildInputs = qmlModules ++ [
    qt6.qtbase
    qt6.qtwayland
    qt6.qtimageformats
    qt6.qtshadertools # shader compilation for Qt Quick effects
    qt6.qtlanguageserver # qmlls backend
    qt6.qttools # linguist, designer, qdbus, qtpaths
  ];

  packages = [
    pkgs.quickshell # `quickshell -p .` to run the shell in config/quickshell
  ];

  shellHook = ''
    # Replay wrapQtAppsHook's wrapper args into this shell, so QT_PLUGIN_PATH
    # and friends are set the same way a wrapped Qt app would see them.
    setQtEnvironment=$(mktemp)
    random=$(head -c 10 /dev/urandom | base64)
    makeShellWrapper "$(type -p sh)" "$setQtEnvironment" "''${qtWrapperArgs[@]}" --argv0 "$random"
    sed "/$random/d" -i "$setQtEnvironment"
    source "$setQtEnvironment"
    rm -f "$setQtEnvironment"

    # qmlls/qmllint read QML_IMPORT_PATH; the qml runtime reads QML2_IMPORT_PATH.
    export QML_IMPORT_PATH="${qmlImportPath}''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
    export QML2_IMPORT_PATH="$QML_IMPORT_PATH"

    # Qt Creator and editors pick the language server up from here.
    export QMLLS="${qt6.qtdeclarative}/bin/qmlls"

    # Wayland-native by default; unset if you need to debug under XWayland.
    export QT_QPA_PLATFORM=wayland

    # Banner only for an interactive shell, so `nix develop --command` stays pipeable.
    if [[ $- == *i* ]]; then
      echo "qt-qml: $(qmlls --version) · $(quickshell --version | head -1)"
      echo "  qmlls · qmlformat · qml · quickshell -p config/quickshell"
      echo "  Qt Creator is not in this shell: nix shell nixpkgs#qtcreator"
    fi
  '';
}
