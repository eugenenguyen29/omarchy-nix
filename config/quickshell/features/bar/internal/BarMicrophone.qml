import QtQuick
import Quickshell.Services.Pipewire
import qs.features.bar

// Lit while any application records from a microphone. A recording app shows
// up as an input stream linked to an audio source device; the link only goes
// Active while samples flow, so a paused recorder drops the pill.
//
// ponytail: level meters (pavucontrol) open a capture stream too and light the
// pill; filter by stream name if that gets noisy.
PrivacyItem {
    icon: available ? "󰍬" : "󰍭"
    available: Pipewire.nodes.values.some(node => node.type === PwNodeType.AudioSource)
    inUse: Pipewire.linkGroups.values.some(group => group.source?.type === PwNodeType.AudioSource && group.target?.isStream && group.state === PwLinkState.Active)
}
