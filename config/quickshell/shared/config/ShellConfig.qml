pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The user's config.json, next to whichever root file started the shell. Read
// only, never written back. The defaults below apply to a missing key or file at
// startup; a key removed while running keeps its last value until a restart.
Singleton {
    readonly property JsonObject theme: adapter.theme
    readonly property JsonObject bar: adapter.bar

    FileView {
        path: Quickshell.shellDir + "/config.json"
        // The first frame already has the file's values.
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter

            property JsonObject theme: JsonObject {
                property bool dark: true
                property string accent: "Teal"
            }

            property JsonObject bar: JsonObject {
                property bool showWorkspaces: true
                property bool showDate: true
                property bool showClock: true
                property bool showAudio: true
                property bool showNetwork: true
                property bool showPowerProfile: true
                property bool showCpu: true
                property bool showMemory: true
                property bool showCamera: true
                property bool showMicrophone: true
                property bool privacyAlwaysShown: true
            }
        }
    }
}
