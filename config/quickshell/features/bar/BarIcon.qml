import QtQuick
import QtQuick.Controls
import qs.shared.theme

// One Material Symbol, named by `text` ("wifi", "volume_up"). Rounded and
// filled, like Android's quick settings. Every glyph on the bar is one of these
// so the set never mixes styles.
Label {
    font.family: Typography.icons
    font.pixelSize: Typography.icon
    font.variableAxes: ({
            "FILL": 1
        })
}
