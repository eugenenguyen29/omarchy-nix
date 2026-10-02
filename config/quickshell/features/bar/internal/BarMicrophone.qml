import QtQuick
import qs.features.bar
import qs.shared.services.audio

// Lit while any application records from the default microphone. The link
// only goes Active while samples flow, so a paused recorder drops the pill.
//
// ponytail: level meters (pavucontrol) open a capture stream too and light the
// pill; filter by stream name if that gets noisy.
PrivacyItem {
    icon: available ? "󰍬" : "󰍭"
    available: Audio.sourceAvailable
    inUse: Audio.recording
}
