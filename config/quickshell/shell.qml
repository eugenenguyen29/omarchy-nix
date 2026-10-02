import Quickshell
import qs.features.bar

// Composition root: one line per slice, nothing else. The only file allowed to
// import qs.features.*.
ShellRoot {
    Bar {
        enabled: true
    }
}
