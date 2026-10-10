pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// System load readings in plain units. Callers see numbers only, so the source
// behind them can change without touching any of them.
//
// Read from /proc, which sends no change notifications, hence the poll.
//
// ponytail: polls even when nothing displays the readings; gate the timer on a
// consumer count if that ever shows up in a profile.
Singleton {
    id: root

    // Mean clock across all cores.
    readonly property real cpuGHz: {
        const mhz = cpuinfo.text().match(/^cpu MHz\s*:\s*[\d.]+/gm)?.map(line => Number(line.split(":")[1])) ?? [];
        return mhz.reduce((sum, value) => sum + value, 0) / Math.max(1, mhz.length) / 1000;
    }

    // What is not available to new allocations, so reclaimable cache does not
    // count.
    readonly property real memoryUsedGiB: (meminfoField("MemTotal") - meminfoField("MemAvailable")) / 1048576

    function meminfoField(name: string): real {
        return Number(meminfo.text().match(new RegExp(name + ":\\s+(\\d+)"))?.[1] ?? 0);
    }

    FileView {
        id: cpuinfo

        path: "/proc/cpuinfo"
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuinfo.reload();
            meminfo.reload();
        }
    }
}
