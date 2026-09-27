import QtQuick
import qs.shared.theme

// One group of bar widgets. The bar declares a few of these and anchors them;
// each widget inside decides on its own whether it drives the popout, by
// being a PopoutTrigger or not.
Row {
    anchors.verticalCenter: parent.verticalCenter

    spacing: Config.spacing
}
