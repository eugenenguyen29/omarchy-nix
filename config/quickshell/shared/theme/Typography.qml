pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string family: "CaskaydiaMono Nerd Font"

    // Icons are Material Symbols, the set Android draws its quick settings in.
    // The text is the icon's name; the font's ligatures turn it into the glyph.
    readonly property string icons: "Material Symbols Rounded"

    // Type scale. Only the sizes the shell actually uses exist.
    readonly property int caption: 11
    readonly property int body: 13
    readonly property int title: 16
    readonly property int icon: 18

    readonly property int regular: Font.Normal
    readonly property int medium: Font.Medium
}
