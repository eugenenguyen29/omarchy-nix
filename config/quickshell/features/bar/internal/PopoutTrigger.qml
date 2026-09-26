import QtQuick

// Wraps a bar widget so hovering it drives the shared Popout. The content
// Component is declared here, next to the widget it belongs to — the popout
// keeps no registry of names.
Item {
    id: root

    required property Popout popout
    property Component content: null

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    HoverHandler {
        onHoveredChanged: {
            if (!hovered || !root.content)
                return;
            root.popout.content = root.content;
            root.popout.centerX = root.mapToItem(root.popout.parent, root.width / 2, 0).x;
        }
    }
}
