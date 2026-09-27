import QtQuick

// The shell's only animation primitive. Every Behavior and Transition uses it,
// so retiming the whole shell is an edit to the four tokens in Config.
//
// Two kinds, and the split is the point. Spatial is anything geometric —
// position, size, anchors: it runs long and its curve overshoots (control point
// y > 1, so the value passes the target and settles back), which is what reads
// as mass. Effects is opacity and colour: short, and never overshoots — a fade
// that overshoots just flickers. One duration and one curve for both is what
// makes a shell feel stiff.
//
// Named Motion, not Animation: QtQuick already exports an abstract `Animation`
// base type, and an explicit `import QtQuick` outranks a same-directory file, so
// the collision would resolve to the abstract base and fail at instantiation.
NumberAnimation {
    enum Kind {
        Spatial,
        Effects
    }

    property int kind: Motion.Spatial

    readonly property bool isEffects: kind === Motion.Effects

    duration: isEffects ? Config.durationEffects : Config.durationSpatial
    easing.type: Easing.BezierSpline
    easing.bezierCurve: isEffects ? Config.curveEffects : Config.curveSpatial
}
