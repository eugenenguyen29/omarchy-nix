import QtQuick
import qs.shared.theme

// A privacy notice: a pill that lights up while something is capturing you.
// The base owns the look; a concrete item only answers "is it in use" and "is
// there a device at all", by binding the two required properties — that is
// the whole tracking contract.
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

    anchors.verticalCenter: parent.verticalCenter
    visible: inUse || alwaysShown

    implicitWidth: glyph.implicitWidth + 2 * Config.spacing
    implicitHeight: glyph.implicitHeight + 2 * Config.spacingSmall

    radius: height / 2
    color: inUse ? Theme.success : "transparent"

    Text {
        id: glyph

        anchors.centerIn: parent
        text: root.icon
        color: root.inUse ? Theme.surface : root.available ? Theme.textMuted : Theme.error
        font.family: Typography.family
        font.pixelSize: Typography.body

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
                value: Theme.surface
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
