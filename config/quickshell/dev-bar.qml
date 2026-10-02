import Quickshell
import qs.features.bar

// Slice harness: `qs -p config/quickshell/dev-bar.qml`. Must live at the config
// root — `-p <file>` rebases the `qs` module root onto the file's directory.
ShellRoot {
    Bar {
        enabled: true
    }
}
