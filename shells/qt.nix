{ pkgs }:
let
  inherit (pkgs) qt6;
in
pkgs.mkShell {
  name = "qt-qml";

  packages = [
    pkgs.quickshell # `qs -p config/quickshell`; the binary is wrapped with its own Qt env
    qt6.qtdeclarative # qmlformat, qmlls
    pkgs.slurp # pick a region of the running shell to capture
    pkgs.wf-recorder
  ];

  # Lets qmlls resolve QtQuick and Quickshell types (qs.* imports stay unresolved, see docs).
  QML_IMPORT_PATH = "${qt6.qtdeclarative}/lib/qt-6/qml:${pkgs.quickshell}/lib/qt-6/qml";
}
