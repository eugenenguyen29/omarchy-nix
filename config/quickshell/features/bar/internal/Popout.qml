import QtQuick
import QtQuick.Shapes
import qs.shared.theme

// The single panel that grows out of the bar. One instance per bar window;
// PopoutTriggers hand it their content component and their centre on the bar,
// so moving between widgets slides and resizes this rather than reopening it.
Item {
    id: root

    // Set by whichever PopoutTrigger the pointer is over. Never cleared on
    // exit — keeping the last content alive is what lets it fade out while the
    // panel shrinks.
    property Component content: null
    property real centerX: 0
    property bool open: false

    // Radius of the concave fillets, which sit outside the content box on both
    // sides; the panel is therefore wider than its content by 2 * this.
    readonly property int wing: Metrics.radiusLarge

    implicitWidth: loader.implicitWidth + 2 * (wing + Metrics.spacingLarge)
    implicitHeight: loader.implicitHeight + 2 * Metrics.spacing

    width: implicitWidth
    height: open ? implicitHeight : 0
    x: Math.max(0, Math.min(parent.width - width, centerX - width / 2))

    Behavior on x {
        NumberAnimation {
            duration: Metrics.duration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: Metrics.duration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: Metrics.duration
            easing.type: Easing.OutCubic
        }
    }

    // One path for the whole outline: the top edge spans the body plus whatever
    // width the fillets currently claim, and two counterclockwise arcs fall
    // inward to the body edges, which is what reads as an inverted corner. Two
    // separate corner items would show a seam as they animate.
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // Below `wing` the outline has no fillets left to show and is just a
        // wide, flat sliver — the shape of a rectangle, not of a closing panel.
        // Fading those last pixels out retires it before it reads as one.
        opacity: Math.min(1, root.height / root.wing)

        ShapePath {
            id: path

            readonly property real w: root.width
            readonly property real h: root.height

            // A fillet can never be deeper than the panel is tall, so it drains
            // away over the last `wing` pixels of the close. Its horizontal
            // reach drains with it while the body edges stay pinned at `wing`,
            // so the outline ends on the body width. Deriving the body edges
            // from `r` instead would walk them out to 0 and `w`, and the close
            // would end on a full-width slab.
            readonly property real r: Math.min(root.wing, h)
            readonly property real rb: Math.max(0, Math.min(Metrics.radiusLarge, h - r, (w - 2 * root.wing) / 2))

            fillColor: Theme.surface
            strokeWidth: 0

            startX: root.wing - path.r
            startY: 0

            PathLine {
                x: path.w - root.wing + path.r
                y: 0
            }

            PathArc {
                x: path.w - root.wing
                y: path.r
                radiusX: path.r
                radiusY: path.r
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: path.w - root.wing
                y: path.h - path.rb
            }

            PathArc {
                x: path.w - root.wing - path.rb
                y: path.h
                radiusX: path.rb
                radiusY: path.rb
            }

            PathLine {
                x: root.wing + path.rb
                y: path.h
            }

            PathArc {
                x: root.wing
                y: path.h - path.rb
                radiusX: path.rb
                radiusY: path.rb
            }

            PathLine {
                x: root.wing
                y: path.r
            }

            PathArc {
                x: root.wing - path.r
                y: 0
                radiusX: path.r
                radiusY: path.r
                direction: PathArc.Counterclockwise
            }
        }
    }

    Item {
        x: root.wing
        width: root.width - 2 * root.wing
        height: root.height
        clip: true

        // Driven by `open` rather than by measured height: deriving it from
        // root.implicitHeight read this subtree's own implicit size back into
        // one of its visual properties, which Qt flags as a binding loop.
        // Half the panel duration, and on the way in it waits out the other
        // half, so content still arrives after the panel and leaves before it.
        opacity: root.open ? 1 : 0

        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation {
                    duration: root.open ? Metrics.duration / 2 : 0
                }

                NumberAnimation {
                    duration: Metrics.duration / 2
                    easing.type: Easing.OutCubic
                }
            }
        }

        Loader {
            id: loader

            anchors.horizontalCenter: parent.horizontalCenter
            y: Metrics.spacing

            sourceComponent: root.content
        }
    }
}
