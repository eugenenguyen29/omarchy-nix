import QtQuick
import QtQuick.Controls
import Quickshell
import qs.features.bar
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
        Label {
            text: Qt.formatDateTime(clock.date, "HH:mm") + "  ·  UTC " + clock.date.toISOString().slice(11, 16)
            font.pixelSize: Typography.title
        }
    }
}
