import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material as M
import qs.shared.theme

// The root item of every window: paints nothing, and is the only place the
// Material theme, accent and font are set. Everything visible is its child.
Pane {
    padding: 0
    background: null

    M.Material.theme: Theme.theme
    M.Material.accent: Theme.accent
    font.family: Typography.family
    font.pixelSize: Typography.body
}
