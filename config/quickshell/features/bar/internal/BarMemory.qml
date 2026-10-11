import QtQuick
import qs.features.bar
import qs.shared.services.metrics

// RAM in use. Display only.
BarItem {
    glyph: "memory_alt"
    text: Metrics.memoryUsedGiB.toFixed(1) + "G"
}
