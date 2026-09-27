import QtQuick
import qs.shared.theme

// The plain bar item: a nerd-font glyph, optionally with a label after it.
Row {
    id: root

    property string icon
    property alias text: label.text
    property color color: Theme.text

    anchors.verticalCenter: parent.verticalCenter

    spacing: Config.spacingSmall

    Text {
        text: root.icon
        color: root.color
        font.family: Typography.family
        font.pixelSize: Typography.body
    }

    Text {
        id: label

        color: root.color
        font.family: Typography.family
        font.pixelSize: Typography.body
        font.weight: Typography.medium
        visible: text !== ""
    }
}
