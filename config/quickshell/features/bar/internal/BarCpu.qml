import QtQuick
import qs.features.bar
import qs.shared.services.metrics

// Mean clock across all cores. Display only.
BarItem {
    glyph: "memory"
    text: Metrics.cpuGHz.toFixed(1) + "GHz"
}
