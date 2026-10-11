import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material as M
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.features.bar
import qs.shared.services.audio
import qs.shared.theme

// Android-style quick settings: radio tiles on top, level sliders below. Tiles
// are Material buttons, filled with the accent while their radio is on.
ColumnLayout {
    id: root

    // The internal panel. brightnessctl's own default here is the Touch Bar.
    // ponytail: hardcoded for the T2 MacBook; make it a Bar property once a
    // second machine runs this shell.
    readonly property string backlight: "acpi_video0"

    // Set by the bar. A Layout owns its implicitWidth, so the width goes in
    // through a child's preferred width instead.
    property real panelWidth

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    // 0..1, read once per open; the backlight sends no change notifications.
    property real brightness: 1

    spacing: Config.spacing

    // Quick-settings level: a thick pill track, the accent fill carrying the
    // glyph at its start, no handle. The fill never shrinks below a circle so
    // the glyph always has somewhere to sit.
    component LevelSlider: Slider {
        id: slider

        property string glyph

        signal glyphTapped

        padding: 0
        implicitHeight: Config.sliderHeight
        handle: null

        background: Rectangle {
            radius: height / 2
            color: Qt.alpha(M.Material.foreground, 0.12)

            Rectangle {
                id: fill

                x: Config.spacingSmall
                y: Config.spacingSmall
                height: parent.height - 2 * Config.spacingSmall
                width: Math.max(height, slider.visualPosition * (parent.width - 2 * Config.spacingSmall))
                radius: height / 2
                color: slider.enabled ? M.Material.accentColor : M.Material.sliderDisabledColor

                BarIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    x: (fill.height - width) / 2
                    text: slider.glyph
                    color: M.Material.background

                    // Takes the press before the slider does, so a tap on
                    // the glyph never moves the level.
                    TapHandler {
                        onTapped: slider.glyphTapped()
                    }
                }
            }
        }
    }

    // A radio tile: icon then name. Two labels, because the icon is a
    // different font from the name.
    component Tile: Button {
        id: tile

        property string glyph

        Layout.fillWidth: true
        // Equal preferred widths split the row evenly whatever the labels.
        Layout.preferredWidth: 1

        contentItem: Row {
            spacing: Config.spacing

            BarIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: tile.glyph
                color: tile.highlighted ? M.Material.background : M.Material.foreground
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: tile.text
                color: tile.highlighted ? M.Material.background : M.Material.foreground
                font.weight: Typography.medium
            }
        }
    }

    RowLayout {
        Layout.preferredWidth: root.panelWidth
        spacing: Config.spacing

        Tile {
            glyph: Networking.wifiEnabled ? "wifi" : "wifi_off"
            text: "Wi-Fi"
            highlighted: Networking.wifiEnabled
            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        Tile {
            glyph: root.adapter?.enabled ? "bluetooth" : "bluetooth_disabled"
            text: "Bluetooth"
            enabled: root.adapter !== null
            highlighted: root.adapter?.enabled ?? false
            onClicked: root.adapter.enabled = !root.adapter.enabled
        }
    }

    LevelSlider {
        Layout.fillWidth: true
        glyph: Audio.muted ? "volume_off" : "volume_up"
        enabled: Audio.available
        value: Audio.volume
        onMoved: Audio.setVolume(value)
        onGlyphTapped: Audio.toggleMute()
    }

    LevelSlider {
        Layout.fillWidth: true
        glyph: "brightness_medium"
        // Never 0: a black panel has no slider left to drag back.
        from: 0.01
        value: root.brightness
        // ponytail: one process per drag step; debounce if it ever lags.
        onMoved: Quickshell.execDetached(["brightnessctl", "-q", "-d", root.backlight, "set", Math.round(value * 100) + "%"])
    }

    // `-m info` prints device,class,current,percent,max.
    Process {
        running: true
        command: ["brightnessctl", "-m", "-d", root.backlight, "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [, , current, , max] = text.trim().split(",");
                if (Number(max) > 0)
                    root.brightness = Number(current) / Number(max);
            }
        }
    }
}
