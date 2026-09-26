pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property int barHeight: 28

    // 4px spacing grid.
    readonly property int spacingSmall: 4
    readonly property int spacing: 8
    readonly property int spacingLarge: 16

    readonly property int radius: 6

    readonly property int durationFast: 120
    readonly property int duration: 200
}
