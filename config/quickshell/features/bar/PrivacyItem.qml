import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material as M
import qs.shared.theme

// A privacy notice: a pill that lights up while something is capturing you
// (microphone, camera — anything). Its own kind of bar item, not a BarItem
// variant. The base owns the look; a concrete item only answers "is it in use"
// and "is there a device at all", by binding the two required properties —
// that is the whole tracking contract.
//
// Visibility is configuration (always shown, or only while in use, plus the
// display flag), arriving as properties like any other slice config.
//
// Not a Button: a status pill is not clickable, and a Button would bring
// ripples, press elevation, an idle fill, a too-tall default size and an accent
// (not success) highlight.
//
// Never put one inside a BarGroup. The notice must stand alone on the bar to
// be noticed, and a lit pill on the group's plate reads as just another item.
Rectangle {
    id: root

    required property string icon
    required property bool inUse
    required property bool available

    // False: the pill exists only while in use. True: it stays as a dimmed
    // glyph when idle, and turns to an error colour with no device.
    property bool alwaysShown: false

    // Lit-pill ink: the bar colour, so the glyph reads as cut out of the pill.
    readonly property color ink: M.Material.background

    // The display flag: false hides the pill whatever its state.
    property bool shown: true

    anchors.verticalCenter: parent.verticalCenter
    visible: shown && (inUse || alwaysShown)

    implicitWidth: glyph.implicitWidth + 2 * Config.spacing
    implicitHeight: glyph.implicitHeight + 2 * Config.spacingSmall

    radius: height / 2
    color: inUse ? Theme.success : "transparent"

    BarIcon {
        id: glyph

        anchors.centerIn: parent
        text: root.icon
        color: root.inUse ? root.ink : root.available ? M.Material.hintTextColor : Theme.error

        // Same health pill as BarItem, derived from the tracking contract so
        // concrete indicators never set it themselves.
        StatusDot {
            anchors.left: parent.right
            anchors.top: parent.top
            status: !root.available ? StatusDot.Error : root.inUse ? StatusDot.Active : StatusDot.Ready

            // The lit pill is already success-coloured, so an Active dot would
            // vanish into it: take the glyph's colour and pulse instead.
            // Binding restores StatusDot's own colour once capture stops.
            Binding on color {
                when: root.inUse
                value: root.ink
            }

            // alwaysRunToEnd lands the cycle back on full opacity when stopped.
            SequentialAnimation on opacity {
                running: root.inUse
                loops: Animation.Infinite
                alwaysRunToEnd: true

                Motion {
                    kind: Motion.Effects
                    to: 0
                }

                PauseAnimation {
                    duration: Config.durationSpatial
                }

                Motion {
                    kind: Motion.Effects
                    to: 1
                }

                PauseAnimation {
                    duration: Config.durationSpatial
                }
            }
        }
    }
}
