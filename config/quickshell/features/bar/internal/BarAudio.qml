import QtQuick
import qs.features.bar
import qs.shared.services.audio

// Output volume. Glyph only, Android-style: the icon changes at
// the 25% and 75% checkpoints instead of printing a number.
BarItem {
    id: root

    readonly property int percent: Math.round(Audio.volume * 100)

    glyph: Audio.muted || percent === 0 ? "volume_off" : percent <= 25 ? "volume_mute" : percent <= 75 ? "volume_down" : "volume_up"
    status: !Audio.available ? StatusDot.Error : Audio.playing ? StatusDot.Active : StatusDot.Ready
}
