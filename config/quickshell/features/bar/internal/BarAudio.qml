import QtQuick
import qs.features.bar
import qs.shared.services.audio

// Output volume; click to mute. Glyph only, Android-style: the icon changes at
// the 25% and 75% checkpoints instead of printing a number.
BarItem {
    id: root

    readonly property int percent: Math.round(Audio.volume * 100)

    icon: Audio.muted || percent === 0 ? "󰖁" : percent <= 25 ? "󰕿" : percent <= 75 ? "󰖀" : "󰕾"
    status: !Audio.available ? StatusDot.Error : Audio.playing ? StatusDot.Active : StatusDot.Ready

    TapHandler {
        onTapped: Audio.toggleMute()
    }
}
