import QtQuick
import qs.features.bar
import qs.shared.services.audio

// Output volume; click to mute. The glyph carries the level, so the row still
// reads at a glance when the label is the same width for 10% and 90%.
BarItem {
    id: root

    readonly property int percent: Math.round(Audio.volume * 100)

    icon: Audio.muted || percent === 0 ? "󰖁" : percent < 34 ? "󰕿" : percent < 67 ? "󰖀" : "󰕾"
    text: Audio.muted ? "" : `${percent}%`
    // Percentage first, glyph last.
    layoutDirection: Qt.RightToLeft
    status: !Audio.available ? StatusDot.Error : Audio.playing ? StatusDot.Active : StatusDot.Ready

    TapHandler {
        onTapped: Audio.toggleMute()
    }
}
