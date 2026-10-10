import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material as M
import qs.shared.theme

// The plain bar item: a nerd-font glyph, optionally with a label after it.
// Hand it a `popout` and a `content` component and hovering it grows the panel;
// leave either out and it stays just the text. That is the whole opt-in — there
// is no separate wrapper item to remember.
ToolButton {
    id: root

    // `glyph`, not `icon`: AbstractButton already owns `icon`.
    property string glyph
    property color color: M.Material.foreground

    property Popout popout: null
    property Component content: null

    // Opt-in health of whatever backs this item; see StatusDot. Groups have no
    // such thing, which is why it lives here and not on BarGroup.
    property int status: StatusDot.None

    readonly property bool opensPopout: popout !== null && content !== null

    anchors.verticalCenter: parent.verticalCenter

    // Material's default is taller than the bar; the insets only shape the ripple.
    implicitHeight: Config.barHeight
    // Material's background has a touch-target minimum width; hug the content.
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    horizontalPadding: Config.spacingSmall
    focusPolicy: Qt.NoFocus
    hoverEnabled: true

    onHoveredChanged: {
        if (!opensPopout)
            return;
        if (!hovered) {
            // Only ever release your own claim: the next item may have taken
            // it already on the same mouse move.
            if (popout.owner === root)
                popout.owner = null;
            return;
        }
        popout.content = content;
        popout.centerX = mapToItem(popout.parent, width / 2, 0).x;
        popout.owner = root;
    }

    contentItem: Row {
        spacing: Config.spacingSmall

        BarIcon {
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            color: root.color
            visible: text !== ""

            StatusDot {
                anchors.left: parent.right
                anchors.top: parent.top
                status: root.status
            }
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.color
            font.weight: Typography.medium
            visible: text !== ""
        }
    }
}
