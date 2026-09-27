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

            // The mask already limits input to bar + open popout, so one
            // handler over the whole window answers "is the pointer on either
            // of them" — and stays hovered while crossing from one to the other.
            Item {
                anchors.fill: parent

                HoverHandler {
                    id: hover
                }

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
                    // to one, and give it a `content` component if it should
                    // open the popout.
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
                            popout: popout
                        }
                    }

                    BarSection {
                        anchors.right: parent.right
                        anchors.rightMargin: Config.spacingLarge

                        // Placeholders until the real slices land: one loose
                        // item, then two that belong together.
                        BarItem {
                            icon: "󰕾"
                            text: "64%"
                        }

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
                    open: hover.hovered && content !== null
                }
            }
        }
    }
}
