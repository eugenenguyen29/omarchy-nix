import QtQuick
import Quickshell
import qs.shared.theme

// SystemClock, never a bare Timer: quickshell aligns the tick to the wall clock
// and only wakes at the requested precision.
Row {
    id: root

    required property Popout popout

    spacing: Metrics.spacing

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    PopoutTrigger {
        popout: root.popout

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

    PopoutTrigger {
        popout: root.popout

        content: Component {
            Text {
                text: Qt.formatDateTime(clock.date, "HH:mm") + "  ·  UTC " + clock.date.toISOString().slice(11, 16)
                color: Theme.text
                font.family: Typography.family
                font.pixelSize: Typography.title
            }
        }

        Text {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.text
            font.family: Typography.family
            font.pixelSize: Typography.body
            font.weight: Typography.medium
        }
    }
}
