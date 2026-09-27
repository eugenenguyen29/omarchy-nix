pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property int barHeight: 32

    // 4px spacing grid.
    readonly property int spacingSmall: 4
    readonly property int spacing: 8
    readonly property int spacingLarge: 16

    readonly property int radius: 6

    // Workspaces always drawn, even while empty — matches the persistent set
    // waybar shows. Live workspaces above this number appear on top.
    readonly property int workspaceCount: 5
    readonly property int workspaceDot: 8

    // Panel-scale rounding: the popout's bottom corners.
    readonly property int radiusLarge: 12

    // The concave fillets that blend the popout's top edge into the bar. Sets
    // how far the panel overhangs its content on each side, so it is free of
    // radiusLarge — the two curves never meet.
    readonly property int radiusFillet: 6

    // Motion, in two families — see Motion.qml for why they are split. Spatial
    // is geometry and runs long; effects is opacity and colour and runs short.
    readonly property int durationSpatial: 500
    readonly property int durationEffects: 200

    // Cubic bezier control points, in the order easing.bezierCurve wants them:
    // c1, c2, end. The spatial curve's first control point sits above 1, so the
    // value overshoots its target and settles back; the effects curve stays
    // below, because a fade must not overshoot.
    readonly property var curveSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
    readonly property var curveEffects: [0.34, 0.8, 0.34, 1, 1, 1]
}
