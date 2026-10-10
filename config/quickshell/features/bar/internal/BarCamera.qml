import QtQuick
import qs.features.bar
import qs.shared.services.camera

// Lit while any application streams from any camera.
PrivacyItem {
    icon: available ? "videocam" : "videocam_off"
    available: Camera.available
    inUse: Camera.inUse
}
