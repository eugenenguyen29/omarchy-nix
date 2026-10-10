import QtQuick
import Quickshell.Networking
import qs.features.bar

// Connection state, glyph only. A connected wired link wins over Wi-Fi, so a
// docked laptop shows the cable even while Wi-Fi stays up. Wi-Fi strength
// steps through four bars, like the volume glyph. Display only.
BarItem {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property bool wired: devices.some(device => device.type === DeviceType.Wired && device.connected)
    readonly property var wifi: devices.find(device => device.type === DeviceType.Wifi)?.networks.values.find(network => network.connected) ?? null
    readonly property real strength: wifi?.signalStrength ?? 0

    glyph: wired ? "lan" : !Networking.wifiEnabled ? "wifi_off" : !wifi ? "signal_wifi_0_bar" : strength <= 0.25 ? "network_wifi_1_bar" : strength <= 0.5 ? "network_wifi_2_bar" : strength <= 0.75 ? "network_wifi_3_bar" : "signal_wifi_4_bar"
}
