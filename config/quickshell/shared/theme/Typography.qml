pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string family: "Caskaydia Mono Nerd Font"

    // Type scale. Only the sizes the shell actually uses exist.
    readonly property int caption: 11
    readonly property int body: 13
    readonly property int title: 16

    readonly property int regular: Font.Normal
    readonly property int medium: Font.Medium
}
