import QtQuick
import qs.shared.theme

// One group of bar widgets. The bar declares a few of these and anchors them;
// each widget inside decides on its own whether it drives the popout, by
// handing its BarItem a popout and content or not.
Row {
    anchors.verticalCenter: parent.verticalCenter

    spacing: Config.spacing
}
