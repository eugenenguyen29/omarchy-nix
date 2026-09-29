pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

// Read side of PipeWire: the current output, everything you could switch to,
// and the volume of the current one.
//
// Pipewire.nodes lists every node in the graph — microphones, and one stream
// node per playing application. Output *devices* are the sinks that are not
// streams.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property var sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream)

    // audio is null until the node is both ready and tracked, so both are
    // guarded rather than assumed.
    readonly property real volume: root.sink?.audio?.volume ?? 0
    readonly property bool muted: root.sink?.audio?.muted ?? false

    // False when there is no default output, or it is not bound yet — the
    // volume above is then a placeholder 0, not a reading.
    readonly property bool available: root.sink?.ready === true && root.sink.audio !== null

    // Some application stream is actively feeding the output. A paused player
    // keeps its link but drops out of Active.
    readonly property bool playing: sinkLinks.linkGroups.some(group => group.target === root.sink && group.source?.isStream && group.state === PwLinkState.Active)

    // Turning the knob is an unmute: reaching for the volume while muted means
    // "I want to hear this", never "make silence quieter". Lives here so every
    // caller — bar, OSD, keybinding — behaves the same way.
    function setVolume(volume: real): void {
        if (!root.sink?.audio)
            return;
        root.sink.audio.muted = false;
        root.sink.audio.volume = Math.max(0, Math.min(1, volume));
    }

    function toggleMute(): void {
        if (root.sink?.audio)
            root.sink.audio.muted = !root.sink.audio.muted;
    }

    // PipeWire sends property updates only for objects something has bound;
    // without this every node reports a volume of 0 forever.
    PwObjectTracker {
        objects: root.sinks
    }

    PwNodeLinkTracker {
        id: sinkLinks

        node: root.sink
    }
}
