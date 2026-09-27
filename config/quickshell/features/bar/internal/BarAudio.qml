import QtQuick
import qs.shared.services.audio

// Output volume, and the knob for it: scroll to change, click to mute.
// The glyph carries the level, so the row still reads at a glance when the
// label is the same width for 10% and 90%.
BarItem {
    id: root

    property real step: 0.05

    readonly property int percent: Math.round(Audio.volume * 100)

    icon: Audio.muted || percent === 0 ? "󰖁" : percent < 34 ? "󰕿" : percent < 67 ? "󰖀" : "󰕾"
    text: Audio.muted ? "" : `${percent}%`

    // Debug: one line per change of volume, mute or output device. Delete once
    // the wiring has earned your trust.
    readonly property string state: `${percent}% ${Audio.muted ? "muted" : "unmuted"} via ${Audio.sink?.description ?? "nothing"}`

    // Without acceptedDevices this reacts to a real mouse wheel only — a laptop
    // touchpad's two-finger scroll is filtered out before the handler sees it.
    // angleDelta is scaled rather than thresholded, so one wheel click (120) is
    // exactly one step while a touchpad glides in fractions of one.
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onWheel: event => Audio.setVolume(Audio.volume + event.angleDelta.y / 120 * root.step)
    }

    TapHandler {
        onTapped: Audio.toggleMute()
    }
}
