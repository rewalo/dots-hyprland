pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Provides some system info: distro, username, hardware, etc.
 */
Singleton {
    id: root
    property string distroName: "Unknown"
    property string distroId: "unknown"
    property string distroIcon: "linux-symbolic"
    property string username: "user"
    property string homeUrl: ""
    property string documentationUrl: ""
    property string supportUrl: ""
    property string bugReportUrl: ""
    property string privacyPolicyUrl: ""
    property string logo: ""
    property string desktopEnvironment: ""
    property string windowingSystem: ""
    property string kernelVersion: ""
    property string windowManager: ""
    property string cpuModel: ""
    property string gpuModel: ""
    property string motherboard: ""
    property string memoryInfo: ""
    property string diskName: ""
    property string diskType: ""
    property int pacmanCount: 0
    property int aurCount: 0
    property int flatpakCount: 0
    property int snapCount: 0
    property int appimageCount: 0

    Timer {
        triggeredOnStart: true
        interval: 1
        running: true
        repeat: false
        onTriggered: {
            getUsername.running = true
            getKernel.running = true
            getCpuModel.running = true
            getGpuModel.running = true
            getMotherboard.running = true
            getMemoryInfo.running = true
            getDiskInfo.running = true
            getPacmanCount.running = true
            getAurCount.running = true
            getFlatpakCount.running = true
            getSnapCount.running = true
            getAppimageCount.running = true
            getWindowManager.running = true
            fileOsRelease.reload()
            const textOsRelease = fileOsRelease.text()

            // Extract the friendly name (PRETTY_NAME field, fallback to NAME)
            const prettyNameMatch = textOsRelease.match(/^PRETTY_NAME="(.+?)"/m)
            const nameMatch = textOsRelease.match(/^NAME="(.+?)"/m)
            distroName = prettyNameMatch ? prettyNameMatch[1] : (nameMatch ? nameMatch[1].replace(/Linux/i, "").trim() : "Unknown")

            // Extract the ID
            const idMatch = textOsRelease.match(/^ID="?(.+?)"?$/m)
            distroId = idMatch ? idMatch[1] : "unknown"

            // Extract additional URLs and logo
            const homeUrlMatch = textOsRelease.match(/^HOME_URL="(.+?)"/m)
            homeUrl = homeUrlMatch ? homeUrlMatch[1] : ""
            const documentationUrlMatch = textOsRelease.match(/^DOCUMENTATION_URL="(.+?)"/m)
            documentationUrl = documentationUrlMatch ? documentationUrlMatch[1] : ""
            const supportUrlMatch = textOsRelease.match(/^SUPPORT_URL="(.+?)"/m)
            supportUrl = supportUrlMatch ? supportUrlMatch[1] : ""
            const bugReportUrlMatch = textOsRelease.match(/^BUG_REPORT_URL="(.+?)"/m)
            bugReportUrl = bugReportUrlMatch ? bugReportUrlMatch[1] : ""
            const privacyPolicyUrlMatch = textOsRelease.match(/^PRIVACY_POLICY_URL="(.+?)"/m)
            privacyPolicyUrl = privacyPolicyUrlMatch ? privacyPolicyUrlMatch[1] : ""
            const logoFieldMatch = textOsRelease.match(/^LOGO="?(.+?)"?$/m)
            logo = logoFieldMatch ? logoFieldMatch[1] : ""

            // Update the distroIcon property based on distroId
            switch (distroId) {
                case "artix":
                case "arch": distroIcon = "arch-symbolic"; break;
                case "endeavouros": distroIcon = "endeavouros-symbolic"; break;
                case "cachyos": distroIcon = "cachyos-symbolic"; break;
                case "nixos": distroIcon = "nixos-symbolic"; break;
                case "fedora": distroIcon = "fedora-symbolic"; break;
                case "linuxmint":
                case "ubuntu":
                case "zorin":
                case "popos": distroIcon = "ubuntu-symbolic"; break;
                case "debian":
                case "raspbian":
                case "kali": distroIcon = "debian-symbolic"; break;
                case "funtoo":
                case "gentoo": distroIcon = "gentoo-symbolic"; break;
                default: distroIcon = "linux-symbolic"; break;
            }
            if (textOsRelease.toLowerCase().includes("nyarch")) {
                distroIcon = "nyarch-symbolic"
            }

            if (logo.trim().length === 0) {
                logo = distroIcon
            }

        }
    }

    Process {
        id: getUsername
        command: ["whoami"]
        stdout: SplitParser {
            onRead: data => {
                root.username = data.trim()
            }
        }
    }

    Process {
        id: getKernel
        command: ["uname", "-r"]
        stdout: SplitParser {
            onRead: data => {
                root.kernelVersion = data.trim()
            }
        }
    }

    Process {
        id: getCpuModel
        command: ["bash", "-c", "model=$(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | sed 's/^ *//'); speed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null | awk '{printf \"(%.2f GHz)\", $1/1000000}'); echo \"$model $speed\""]
        stdout: SplitParser {
            onRead: data => {
                root.cpuModel = data.trim()
            }
        }
    }

    Process {
        id: getGpuModel
        command: ["bash", "-c", "gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 | xargs); if [ -n \"$gpu\" ]; then echo \"$gpu [Discrete]\"; else lspci -nn | grep -i nvidia | grep -E 'VGA|Display' | head -1 | sed 's/.*VGA compatible controller.*: //' | sed 's/\\[10de.*//' | sed 's/NVIDIA Corporation //' | xargs; fi"]
        stdout: SplitParser {
            onRead: data => {
                const gpu = data.trim()
                if (gpu.length > 0) {
                    root.gpuModel = gpu
                } else {
                    root.gpuModel = "Unknown"
                }
            }
        }
    }

    Process {
        id: getMotherboard
        command: ["bash", "-c", "cat /sys/class/dmi/id/board_vendor 2>/dev/null | tr -d '\\n'; echo -n ' '; cat /sys/class/dmi/id/board_name 2>/dev/null | tr -d '\\n'"]
        stdout: SplitParser {
            onRead: data => {
                const mb = data.trim()
                if (mb.length > 1) {
                    root.motherboard = mb
                } else {
                    root.motherboard = "Unknown"
                }
            }
        }
    }

    Process {
        id: getMemoryInfo
        command: ["bash", "-c", "type=$(inxi -m 2>/dev/null | grep -oP '(DDR\\d+)' | head -1); total=$(free -b | grep Mem | awk '{printf \"%.1f\", $2/1024/1024/1024}'); if [ -n \"$type\" ]; then echo \"$total GB $type\"; else echo \"$total GB\"; fi"]
        stdout: SplitParser {
            onRead: data => {
                root.memoryInfo = data.trim()
            }
        }
    }

    Process {
        id: getDiskInfo
        command: ["bash", "-c", "nvme=$(lsblk -d -o NAME,TYPE 2>/dev/null | grep nvme | head -1 | awk '{print $1}'); if [ -n \"$nvme\" ]; then model=$(cat /sys/block/$nvme/device/model 2>/dev/null | tr -d ' '); type='NVMe'; echo \"$model ($type)\"; else echo 'Unknown SSD'; fi"]
        stdout: SplitParser {
            onRead: data => {
                const disk = data.trim()
                if (disk.length > 0 && disk !== "Unknown SSD") {
                    const match = disk.match(/^(.+?)\s*\((.+?)\)$/)
                    if (match) {
                        root.diskName = match[1]
                        root.diskType = match[2]
                    } else {
                        root.diskName = disk
                        root.diskType = "SSD"
                    }
                } else {
                    root.diskName = "Unknown"
                    root.diskType = "SSD"
                }
            }
        }
    }

    Process {
        id: getWindowManager
        command: ["bash", "-c", "hyprctl version 2>/dev/null | head -1 | grep -oP 'Hyprland \\K[0-9.]+' || echo 'Hyprland'"]
        stdout: SplitParser {
            onRead: data => {
                const wm = data.trim()
                if (wm.length > 0 && wm.includes(".")) {
                    root.windowManager = "Hyprland " + wm + " (Wayland)"
                } else {
                    root.windowManager = "Hyprland (Wayland)"
                }
            }
        }
    }

    Process {
        id: getPacmanCount
        command: ["bash", "-c", "pacman -Q | wc -l"]
        stdout: SplitParser {
            onRead: data => {
                root.pacmanCount = parseInt(data.trim()) || 0
            }
        }
    }

    Process {
        id: getAurCount
        command: ["bash", "-c", "pacman -Qem | wc -l"]
        stdout: SplitParser {
            onRead: data => {
                root.aurCount = parseInt(data.trim()) || 0
            }
        }
    }

    Process {
        id: getFlatpakCount
        command: ["bash", "-c", "flatpak list 2>/dev/null | wc -l"]
        stdout: SplitParser {
            onRead: data => {
                root.flatpakCount = parseInt(data.trim()) || 0
            }
        }
    }

    Process {
        id: getSnapCount
        command: ["bash", "-c", "snap list 2>/dev/null | tail -n +2 | wc -l"]
        stdout: SplitParser {
            onRead: data => {
                root.snapCount = parseInt(data.trim()) || 0
            }
        }
    }

    Process {
        id: getAppimageCount
        command: ["bash", "-c", "find /home/$USER -name '*.AppImage' -type f 2>/dev/null | wc -l"]
        stdout: SplitParser {
            onRead: data => {
                root.appimageCount = parseInt(data.trim()) || 0
            }
        }
    }

    Process {
        id: getDesktopEnvironment
        running: true
        command: ["bash", "-c", "echo $XDG_CURRENT_DESKTOP,$WAYLAND_DISPLAY"]
        stdout: StdioCollector {
            id: deCollector
            onStreamFinished: {
                const [desktop, wayland] = deCollector.text.split(",")
                root.desktopEnvironment = desktop.trim()
                root.windowingSystem = wayland.trim().length > 0 ? "Wayland" : "X11" // Are there others? 🤔
            }
        }
    }

    FileView {
        id: fileOsRelease
        path: "/etc/os-release"
    }
}
