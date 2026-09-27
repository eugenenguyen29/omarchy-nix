import QtQuick
import Quickshell
import qs.shared.theme

PopoutTrigger {
    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    content: Component {
        Text {
            text: Qt.formatDate(clock.date, "dddd, d MMMM yyyy")
            color: Theme.text
            font.family: Typography.family
            font.pixelSize: Typography.title
        }
    }

    Text {
        text: Qt.formatDate(clock.date, "ddd d MMM")
        color: Theme.textMuted
        font.family: Typography.family
        font.pixelSize: Typography.body
        font.weight: Typography.medium
    }
}
