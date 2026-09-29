import QtQuick
import QtQuick.Shapes
import qs.shared.theme

// The single panel that grows out of the bar. One instance per bar window;
// BarItems hand it their content component and their centre on the bar,
// so moving between widgets slides and resizes this rather than reopening it.
Item {
    id: root

    // Set by whichever BarItem the pointer is over. Never cleared on
    // exit — keeping the last content alive is what lets it fade out while the
    // panel shrinks.
    property Component content: null
    property real centerX: 0

    // The trigger the pointer is on, or null. Ownership is what makes the panel
    // belong to one item rather than to the bar: hovering a section with no
    // trigger in it claims nothing, so nothing opens.
    property Item owner: null

    // Hovering the panel itself holds it open, so the pointer can cross from
    // the trigger down into it without the panel closing under it.
    readonly property bool open: root.owner !== null || hover.hovered

    HoverHandler {
        id: hover
    }

    // Radius of the concave fillets, which sit outside the content box on both
    // sides; the panel is therefore wider than its content by 2 * this.
    readonly property int wing: Config.radiusFillet

    implicitWidth: loader.implicitWidth + 2 * (wing + Config.spacingLarge)
    implicitHeight: loader.implicitHeight + 2 * Config.spacing

    width: implicitWidth
    height: open ? implicitHeight : 0
    x: Math.max(0, Math.min(parent.width - width, centerX - width / 2))

    // x only means anything while the panel is on screen. Ungated, the first
    // open animates it from wherever the previous trigger left it, so the panel
    // slides in from the side instead of growing out of the bar.
    Behavior on x {
        enabled: root.height > 0

        Motion {}
    }

    Behavior on width {
        Motion {}
    }

    Behavior on height {
        Motion {}
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
        opacity: root.wing > 0 ? Math.min(1, root.height / root.wing) : 1

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
            readonly property real rb: Math.max(0, Math.min(Config.radiusLarge, h - r, (w - 2 * root.wing) / 2))

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
        // On the way in the fade waits out half the panel's travel first, so
        // content still arrives after the panel and leaves before it.
        opacity: root.open ? 1 : 0

        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation {
                    duration: root.open ? Config.durationSpatial / 2 : 0
                }

                Motion {
                    kind: Motion.Effects
                }
            }
        }

        Loader {
            id: loader

            anchors.horizontalCenter: parent.horizontalCenter
            y: Config.spacing

            sourceComponent: root.content
        }
    }
}
