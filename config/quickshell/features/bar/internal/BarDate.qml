import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material as M
import Quickshell
import qs.features.bar
import qs.shared.theme

BarItem {
    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    text: Qt.formatDate(clock.date, "ddd d MMM")
    color: M.Material.hintTextColor

    content: Component {
        Label {
            text: Qt.formatDate(clock.date, "dddd, d MMMM yyyy")
            font.pixelSize: Typography.title
        }
    }
}
