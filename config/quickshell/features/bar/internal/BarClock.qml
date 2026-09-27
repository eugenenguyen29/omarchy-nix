import QtQuick
import Quickshell
import qs.shared.theme

// SystemClock, never a bare Timer: quickshell aligns the tick to the wall clock
// and only wakes at the requested precision.
BarItem {
    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, "HH:mm")

    content: Component {
        Text {
            text: Qt.formatDateTime(clock.date, "HH:mm") + "  ·  UTC " + clock.date.toISOString().slice(11, 16)
            color: Theme.text
            font.family: Typography.family
            font.pixelSize: Typography.title
        }
    }
}
