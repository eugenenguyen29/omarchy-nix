import QtQuick
import qs.shared.theme

// The small pill on a bar item's corner that says whether the thing behind the
// item is there at all. None draws nothing, so items that have no backing
// service pay nothing for it.
Rectangle {
    id: root

    enum Status {
        None,
        Ready,
        Active,
        Error
    }

    property int status: StatusDot.None

    visible: status !== StatusDot.None
    implicitWidth: 6
    implicitHeight: 4
    radius: height / 2
    color: status === StatusDot.Error ? Theme.error : status === StatusDot.Active ? Theme.success : Theme.accent
}
