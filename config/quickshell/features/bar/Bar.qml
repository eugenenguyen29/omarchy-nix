import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import qs.features.bar.internal
import qs.shared.theme
import qs.shared.ui

// Slice entry point. Configuration arrives as properties from shell.qml; this
// file reads no files and no env vars of its own.
Scope {
    id: root

    required property bool enabled

    // Privacy pills (camera, microphone): true keeps them as a dimmed glyph when idle,
    // false shows them only while in use.
    property bool privacyAlwaysShown: true

    // Display flags, one per item; a hidden item lets its section close up.
    property bool showWorkspaces: true
    property bool showDate: true
    property bool showClock: true
    property bool showAudio: true
    property bool showNetwork: true
    property bool showPowerProfile: true
    property bool showCpu: true
    property bool showMemory: true
    property bool showCamera: true
    property bool showMicrophone: true

    // Hidden destroys the windows, so the reserved space goes with them.
    property bool shown: true

    // bind = SUPER SHIFT, SPACE, global, quickshell:barToggle
    GlobalShortcut {
        name: "barToggle"
        description: "Show or hide the bar"
        onPressed: root.shown = !root.shown
    }

    Variants {
        model: root.enabled && root.shown ? Quickshell.screens : []

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

            // A click anywhere outside the bar window closes the control centre.
            HyprlandFocusGrab {
                windows: [bar]
                active: popout.owner === controls
                onCleared: popout.owner = null
            }

            Surface {
                anchors.fill: parent

                // Paints Material.background as the bar colour.
                Pane {
                    id: strip

                    padding: 0

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    height: Config.barHeight

                    // Sections, left to right. Each is independent: add a widget
                    // to one, and pass it `popout` if it should open the panel —
                    // an item with no `popout` (or no `content`) is just text.
                    BarSection {
                        anchors.left: parent.left
                        anchors.leftMargin: Config.spacingLarge

                        BarWorkspaces {
                            visible: root.showWorkspaces
                            screen: bar.modelData
                        }
                    }

                    BarSection {
                        anchors.horizontalCenter: parent.horizontalCenter

                        BarDate {
                            visible: root.showDate
                            popout: popout
                        }

                        BarClock {
                            visible: root.showClock
                        }
                    }

                    BarSection {
                        anchors.right: parent.right
                        anchors.rightMargin: Config.spacingLarge

                        // Privacy pills stand alone — never inside a BarGroup.
                        BarCamera {
                            shown: root.showCamera
                            alwaysShown: root.privacyAlwaysShown
                        }

                        BarMicrophone {
                            shown: root.showMicrophone
                            alwaysShown: root.privacyAlwaysShown
                        }

                        BarGroup {
                            id: controls

                            popout: popout
                            // A third of the screen, whatever its resolution.
                            panel: Component {
                                ControlCenter {
                                    panelWidth: bar.width / 3 - popout.leftPadding - popout.rightPadding
                                }
                            }

                            BarNetwork {
                                visible: root.showNetwork
                            }

                            BarAudio {
                                visible: root.showAudio
                            }

                            BarPowerProfile {
                                visible: root.showPowerProfile
                            }

                            BarCpu {
                                visible: root.showCpu
                            }

                            BarMemory {
                                visible: root.showMemory
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
