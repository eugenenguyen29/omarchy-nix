import QtQuick
import Quickshell
import qs.shared.theme

// SystemClock, never a bare Timer: quickshell aligns the tick to the wall clock
// and only wakes at the requested precision.
Text {
    id: root

    text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")

    color: Theme.text
    font.family: Typography.family
    font.pixelSize: Typography.body
    font.weight: Typography.medium

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }
}
