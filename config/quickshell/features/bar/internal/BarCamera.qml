import QtQuick
import qs.features.bar
import qs.shared.services.camera

// Lit while any application streams from any camera.
PrivacyItem {
    icon: available ? "󰄀" : "󰗟"
    available: Camera.available
    inUse: Camera.inUse
}
