import QtQuick
import Quickshell
import qs.features.bar.internal
import qs.shared.theme

// Slice entry point. Configuration arrives as properties from shell.qml; this
// file reads no files and no env vars of its own.
Scope {
    id: root

    required property bool enabled

    Variants {
        model: root.enabled ? Quickshell.screens : []

        PanelWindow {
            id: bar

            required property var modelData

            screen: bar.modelData
            color: Theme.surface

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Metrics.barHeight

            Clock {
                anchors.centerIn: parent
            }
        }
    }
}
