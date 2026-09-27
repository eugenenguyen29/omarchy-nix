import QtQuick
import qs.shared.theme

// The plain bar item: a nerd-font glyph, optionally with a label after it.
// Hand it a `popout` and a `content` component and hovering it grows the panel;
// leave either out and it stays just the text. That is the whole opt-in — there
// is no separate wrapper item to remember.
Row {
    id: root

    property string icon
    property alias text: label.text
    property color color: Theme.text

    property Popout popout: null
    property Component content: null

    readonly property bool opensPopout: popout !== null && content !== null

    anchors.verticalCenter: parent.verticalCenter

    spacing: Config.spacingSmall

    HoverHandler {
        enabled: root.opensPopout

        onHoveredChanged: {
            if (!root.opensPopout)
                return;
            if (!hovered) {
                // Only ever release your own claim: the next item may have taken
                // it already on the same mouse move.
                if (root.popout.owner === root)
                    root.popout.owner = null;
                return;
            }
            root.popout.content = root.content;
            root.popout.centerX = root.mapToItem(root.popout.parent, root.width / 2, 0).x;
            root.popout.owner = root;
        }
    }

    Text {
        text: root.icon
        color: root.color
        font.family: Typography.family
        font.pixelSize: Typography.body
        visible: text !== ""
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
