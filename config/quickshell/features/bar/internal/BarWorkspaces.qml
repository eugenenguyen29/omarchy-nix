import QtQuick
import Quickshell
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

    // Every bar lists the same workspaces — SUPER+N is global — but each marks
    // the one on its own monitor.
    required property ShellScreen screen
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

    // Special workspaces are skipped by name: a stale workspace (see above) has
    // id -1 too, so the id cannot tell them apart. Numbered ones sort
    // numerically so 10 lands after 9; named ones follow, alphabetically.
    readonly property var names: {
        const names = new Set();
        for (let i = 1; i <= Config.workspaceCount; i++)
            names.add(String(i));
        for (const w of Hyprland.workspaces.values)
            if (!w.name.startsWith("special:"))
                names.add(w.name);
        return Array.from(names).sort((a, b) => {
            const x = Number(a), y = Number(b);
            if (Number.isInteger(x) && Number.isInteger(y))
                return x - y;
            if (Number.isInteger(x) !== Number.isInteger(y))
                return Number.isInteger(x) ? -1 : 1;
            return a.localeCompare(b);
        });
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
            readonly property bool shown: workspace?.active ?? false
            readonly property bool here: shown && workspace.monitor === root.monitor
            readonly property bool occupied: (workspace?.toplevels.values.length ?? 0) > 0

            anchors.verticalCenter: parent.verticalCenter

            // This monitor's workspace stretches into a pill; the one another
            // monitor shows stays a dot in the accent; an empty one fades back.
            // The row reads as "where I am, what else is on screen, what is live".
            implicitWidth: here ? 3 * Config.workspaceDot : Config.workspaceDot
            implicitHeight: Config.workspaceDot
            radius: height / 2

            color: shown ? Theme.accent : Theme.text
            opacity: shown || dot.occupied ? 1 : 0.3

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
