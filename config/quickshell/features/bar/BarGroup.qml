import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material as M
import qs.shared.theme

// Several bar items read as one thing: an outlined plate behind them, tighter
// spacing inside it than the section uses between its items. A Frame, not a
// Pane: a Pane would be the bar's own colour.
//
// Hand it a `popout` and a `panel` and the whole plate becomes one click
// target that toggles the panel, centred on the bar rather than on the group.
// The click covers the items inside, so their own clicks never fire, and so
// does hover: the plate takes it and tints as one, the items never do. Unlike
// a BarItem the claim survives the pointer leaving — the bar's focus grab or a
// second click releases it.
Frame {
    id: root

    default property alias content: row.data

    property Popout popout: null
    property Component panel: null

    readonly property bool opensPopout: popout !== null && panel !== null

    anchors.verticalCenter: parent.verticalCenter

    // Items are bar-tall; the outline is inset so it sits inside the bar.
    topPadding: 0
    bottomPadding: 0
    horizontalPadding: Config.spacing
    topInset: Config.spacingSmall
    bottomInset: Config.spacingSmall

    Row {
        id: row

        spacing: Config.spacing
    }

    // Over the outline, so the tint reaches its edges like a ToolButton's ripple.
    Rectangle {
        parent: root.background
        anchors.fill: parent
        radius: parent.radius
        color: M.Material.rippleColor
        visible: area.containsMouse
    }

    MouseArea {
        id: area

        // The Frame itself, not its contentItem, so the padding clicks too.
        parent: root
        anchors.fill: parent
        z: 1
        enabled: root.opensPopout
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.popout.owner === root) {
                root.popout.owner = null;
                return;
            }
            root.popout.content = root.panel;
            root.popout.centerX = root.popout.parent.width / 2;
            root.popout.owner = root;
        }
    }
}
