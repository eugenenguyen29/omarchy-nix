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

            // The window is bar + popout tall, but only the bar reserves space
            // and only bar + open popout take input — so the desktop below is
            // untouched and the pointer never falls through the joint between
            // the two while sliding down.
            color: "transparent"
            exclusiveZone: Config.barHeight

            mask: Region {
                item: strip

                Region {
                    item: popout
                }
            }

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Config.barHeight + popout.implicitHeight

            Item {
                anchors.fill: parent

                Rectangle {
                    id: strip

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    height: Config.barHeight
                    color: Theme.surface

                    // Sections, left to right. Each is independent: add a widget
                    // to one, and pass it `popout` if it should open the panel —
                    // an item with no `popout` (or no `content`) is just text.
                    BarSection {
                        anchors.left: parent.left
                        anchors.leftMargin: Config.spacingLarge

                        BarWorkspaces {}
                    }

                    BarSection {
                        anchors.horizontalCenter: parent.horizontalCenter

                        BarDate {
                            popout: popout
                        }

                        BarClock {
                        }
                    }

                    BarSection {
                        anchors.right: parent.right
                        anchors.rightMargin: Config.spacingLarge

                        // Real item, then two placeholders that belong
                        // together until their slices land.
                        BarAudio {}

                        BarGroup {
                            BarItem {
                                icon: "󰍛"
                                text: "12%"
                            }

                            BarItem {
                                icon: "󰾆"
                                text: "7.4G"
                            }
                        }
                    }
                }

                Popout {
                    id: popout

                    y: Config.barHeight
                }
            }
        }
    }
}
