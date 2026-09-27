import QtQuick
import Quickshell.Hyprland
import qs.shared.theme

// One dot per workspace: filled for the focused one, dim for a workspace with
// nothing open in it. "Has anything open" is HyprlandWorkspace.toplevels, the
// live toplevel list Hyprland pushes — no polling of `hyprctl`.
//
// Workspaces are matched by name, not id: a workspace quickshell learned about
// from a toplevel event carries the right name but keeps id -1 until an IPC
// refresh lands, so ids are the less reliable half of the pair.
Row {
    id: root

    // Hyprland's workspace list stays empty until something asks for it once.
    Component.onCompleted: Hyprland.refreshWorkspaces()

    anchors.verticalCenter: parent.verticalCenter

    spacing: Config.spacingSmall

    readonly property var names: {
        const names = new Set();
        for (let i = 1; i <= Config.workspaceCount; i++)
            names.add(String(i));
        for (const w of Hyprland.workspaces.values)
            names.add(w.name);
        return Array.from(names).sort();
    }

    function workspaceFor(name: string): HyprlandWorkspace {
        for (const w of Hyprland.workspaces.values)
            if (w.name === name)
                return w;
        return null;
    }

    Repeater {
        model: root.names

        Rectangle {
            id: dot

            required property string modelData

            readonly property HyprlandWorkspace workspace: root.workspaceFor(modelData)
            readonly property bool focused: workspace?.focused ?? false
            readonly property bool occupied: (workspace?.toplevels.values.length ?? 0) > 0

            anchors.verticalCenter: parent.verticalCenter

            // The focused dot stretches into a pill; an empty one stays a dot
            // and fades back, so the row reads as "where I am, what is live".
            implicitWidth: focused ? 3 * Config.workspaceDot : Config.workspaceDot
            implicitHeight: Config.workspaceDot
            radius: height / 2

            color: focused ? Theme.accent : Theme.text
            opacity: focused || dot.occupied ? 1 : 0.3

            Behavior on implicitWidth {
                Motion {}
            }

            Behavior on opacity {
                Motion {
                    kind: Motion.Effects
                }
            }

            TapHandler {
                onTapped: Hyprland.dispatch(`workspace ${dot.modelData}`)
            }
        }
    }
}
