import QtQuick

// Wraps a bar widget so hovering it drives the shared Popout. The content
// Component is declared here, next to the widget it belongs to — the popout
// keeps no registry of names.
Item {
    id: root

    required property Popout popout
    property Component content: null

    anchors.verticalCenter: parent.verticalCenter

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    HoverHandler {
        onHoveredChanged: {
            if (!root.content)
                return;
            if (!hovered) {
                // Only ever release your own claim: the next trigger may have
                // taken it already on the same mouse move.
                if (root.popout.owner === root)
                    root.popout.owner = null;
                return;
            }
            root.popout.content = root.content;
            root.popout.centerX = root.mapToItem(root.popout.parent, root.width / 2, 0).x;
            root.popout.owner = root;
        }
    }
}
