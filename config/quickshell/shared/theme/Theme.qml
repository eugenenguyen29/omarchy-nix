pragma Singleton

import QtQuick
import QtQuick.Controls.Material as M
import Quickshell
import qs.shared.config

// Material choices, not colours: Surface applies them, everything else reads
// the Material attached colours. Plumbing the Nix palette back in only touches
// this file.
Singleton {
    readonly property int theme: ShellConfig.theme.dark ? M.Material.Dark : M.Material.Light

    // A name of a Material predefined colour, looked up as an enum. Never hand
    // the JSON string to Material.accent: it parses as a CSS colour, and "Teal"
    // is #008080, not Material Teal.
    readonly property int accent: M.Material[ShellConfig.theme.accent] ?? M.Material.Pink

    // Status colours at the shade Material uses for the active theme.
    readonly property int shade: ShellConfig.theme.dark ? M.Material.Shade200 : M.Material.Shade500
    readonly property color success: M.Material.color(M.Material.Green, shade)
    readonly property color warn: M.Material.color(M.Material.Amber, shade)
    readonly property color error: M.Material.color(M.Material.Red, shade)
}
