import QtQuick
import qs.shared.theme

// Several bar items read as one thing: a rounded plate behind them, tighter
// spacing inside it than the section uses between its items. Purely visual —
// the items inside stay whatever they were, popout trigger or not.
Rectangle {
    id: root

    default property alias content: row.data

    anchors.verticalCenter: parent.verticalCenter

    implicitWidth: row.implicitWidth + 2 * Config.spacing
    implicitHeight: row.implicitHeight + 2 * Config.spacingSmall

    radius: Config.radius
    color: Theme.surfaceAlt

    Row {
        id: row

        anchors.centerIn: parent

        spacing: Config.spacing
    }
}
