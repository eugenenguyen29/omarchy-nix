pragma Singleton

import QtQuick
import Quickshell

// Semantic tokens. Slices import this and never Base16 — a theme change is then
// an edit to this one file.
Singleton {
    readonly property color surface: Base16.base00
    // base01 is not reliably lighter than base00 — in tokyonight it is darker —
    // so anything that must sit *above* the surface tints the surface itself.
    readonly property color surfaceRaised: Qt.tint(surface, Qt.rgba(1, 1, 1, 0.08))
    readonly property color overlay: Base16.base02

    readonly property color text: Base16.base05
    readonly property color textMuted: Base16.base04

    readonly property color accent: Base16.base0D
    readonly property color warn: Base16.base0A
    readonly property color error: Base16.base08
}
