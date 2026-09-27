import QtQuick
import Quickshell
import qs.shared.theme

BarItem {
    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    text: Qt.formatDate(clock.date, "ddd d MMM")
    color: Theme.textMuted

    content: Component {
        Text {
            text: Qt.formatDate(clock.date, "dddd, d MMMM yyyy")
            color: Theme.text
            font.family: Typography.family
            font.pixelSize: Typography.title
        }
    }
}
