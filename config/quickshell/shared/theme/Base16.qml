pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Raw base16 palette, read from the JSON Nix writes (modules/home-manager/
// quickshell.nix). Nobody edits the values here; the fallbacks exist only so the
// tree runs bare, before `home-manager switch` has ever written the file.
Singleton {
    // Guarded: before the first `home-manager switch` the file does not exist
    // and text() returns "", which JSON.parse throws on — leaving `data`
    // undefined and the ?? fallbacks below unreachable.
    readonly property var data: {
        const raw = paletteFile.text();
        if (!raw)
            return {};
        try {
            return JSON.parse(raw);
        } catch (error) {
            return {};
        }
    }

    readonly property color base00: data.base00 ?? "#1a1b26"
    readonly property color base01: data.base01 ?? "#16161e"
    readonly property color base02: data.base02 ?? "#2f3549"
    readonly property color base03: data.base03 ?? "#444b6a"
    readonly property color base04: data.base04 ?? "#787c99"
    readonly property color base05: data.base05 ?? "#a9b1d6"
    readonly property color base06: data.base06 ?? "#cbccd1"
    readonly property color base07: data.base07 ?? "#d5d6db"
    readonly property color base08: data.base08 ?? "#c0caf5"
    readonly property color base09: data.base09 ?? "#a9b1d6"
    readonly property color base0A: data.base0A ?? "#0db9d7"
    readonly property color base0B: data.base0B ?? "#9ece6a"
    readonly property color base0C: data.base0C ?? "#b4f9f8"
    readonly property color base0D: data.base0D ?? "#2ac3de"
    readonly property color base0E: data.base0E ?? "#bb9af7"
    readonly property color base0F: data.base0F ?? "#f7768e"

    FileView {
        id: paletteFile

        path: `${Quickshell.env("HOME")}/.config/omarchy/palette.json`
        // text() is synchronous under blockLoading, so the first frame already
        // has the real colours — no flash of the fallbacks above.
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }
}
