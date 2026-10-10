//@ pragma RespectSystemStyle
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Material
//@ pragma Env QT_QUICK_CONTROLS_MATERIAL_VARIANT=Dense

import Quickshell
import qs.features.bar
import qs.shared.config

// Composition root: one line per slice, nothing else. The only file allowed to
// import qs.features.*.
ShellRoot {
    Bar {
        enabled: true
        showWorkspaces: ShellConfig.bar.showWorkspaces
        showDate: ShellConfig.bar.showDate
        showClock: ShellConfig.bar.showClock
        showAudio: ShellConfig.bar.showAudio
        showNetwork: ShellConfig.bar.showNetwork
        showPowerProfile: ShellConfig.bar.showPowerProfile
        showCpu: ShellConfig.bar.showCpu
        showMemory: ShellConfig.bar.showMemory
        showCamera: ShellConfig.bar.showCamera
        showMicrophone: ShellConfig.bar.showMicrophone
        privacyAlwaysShown: ShellConfig.bar.privacyAlwaysShown
    }
}
