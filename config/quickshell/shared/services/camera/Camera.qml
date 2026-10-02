pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Whether any camera is streaming, from the kernel rather than PipeWire:
// many apps open /dev/video* directly, bypassing the graph. PipeWire only
// lists the cameras — its v4l2 monitor already
// follows hotplug and skips metadata-only nodes.
//
// uvcvideo powers the USB device up only while frames flow — a bare open or a
// capability probe leaves it suspended — so the device's runtime-PM state is
// exactly "in use". It drops back autosuspend_delay_ms (2s) after capture stops.
// sysfs sends no change notifications, hence the poll.
//
// ponytail: v4l2 (USB/UVC) cameras only; libcamera-only MIPI sensors have no
// api.v4l2.path and no USB power state to read. The power state is per USB
// device, so a webcam's built-in microphone recording also reads as "in use";
// interfaces carry no runtime-PM state of their own, so telling them apart
// needs a different signal (e.g. watching who holds /dev/video* open).
Singleton {
    id: root

    // Properties stay empty until bound, so bind every video source and only
    // then keep the ones backed by a v4l2 device.
    readonly property var sources: Pipewire.nodes.values.filter(node => node.type === PwNodeType.VideoSource && !node.isStream)
    readonly property var cameras: root.sources.filter(node => node.properties["api.v4l2.path"])

    readonly property bool available: devices.instances.some(device => device.present)
    readonly property bool inUse: devices.instances.some(device => device.active)

    PwObjectTracker {
        objects: root.sources
    }

    Variants {
        id: devices

        model: root.cameras

        // /dev/videoN's sysfs device is the UVC interface; its parent is the
        // USB device that owns the power state. The kernel resolves the ..
        // after following the symlink.
        FileView {
            required property PwNode modelData

            property bool present: false
            readonly property bool active: present && text().trim() === "active"

            path: modelData.properties["api.v4l2.path"].replace("/dev/", "/sys/class/video4linux/") + "/device/../power/runtime_status"
            onLoaded: present = true
            onLoadFailed: present = false
        }
    }

    Timer {
        interval: 1000
        running: devices.instances.length > 0
        repeat: true
        // Devices without a power file (v4l2loopback, platform cameras) failed
        // their first load; retrying them would only log the failure each tick.
        onTriggered: devices.instances.filter(device => device.present).forEach(device => device.reload())
    }
}
