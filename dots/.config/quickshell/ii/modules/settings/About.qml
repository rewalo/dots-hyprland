import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "box"
        title: Translation.tr("System Info")

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            spacing: 4

            // OS Row
            RowLayout {
                spacing: 8
                IconImage {
                    implicitSize: 24
                    source: Quickshell.iconPath(SystemInfo.logo)
                }
                StyledText {
                    text: SystemInfo.distroName
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Medium
                }
            }

            // System Details Grid
            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                columns: 2
                rowSpacing: 6
                columnSpacing: 24

                // Kernel
                StyledText {
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: Translation.tr("Kernel:")
                }
                StyledText {
                    color: Appearance.colors.colOnSurface
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: SystemInfo.kernelVersion
                }

                // Uptime
                StyledText {
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: Translation.tr("Uptime:")
                }
                StyledText {
                    color: Appearance.colors.colOnSurface
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: DateTime.uptime
                }

                // Window Manager
                StyledText {
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: Translation.tr("Window Manager:")
                }
                StyledText {
                    color: Appearance.colors.colOnSurface
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: SystemInfo.windowManager
                }

                // Motherboard
                StyledText {
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: Translation.tr("Motherboard:")
                }
                StyledText {
                    color: Appearance.colors.colOnSurface
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: SystemInfo.motherboard
                }

                // CPU
                StyledText {
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: Translation.tr("CPU:")
                }
                StyledText {
                    color: Appearance.colors.colOnSurface
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: SystemInfo.cpuModel
                }

                // GPU
                StyledText {
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: Translation.tr("GPU:")
                }
                StyledText {
                    color: Appearance.colors.colOnSurface
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: SystemInfo.gpuModel
                }

                // Memory
                StyledText {
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: Translation.tr("Memory:")
                }
                StyledText {
                    color: Appearance.colors.colOnSurface
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: SystemInfo.memoryInfo
                }

                // Disk
                StyledText {
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: Translation.tr("Disk:")
                }
                StyledText {
                    color: Appearance.colors.colOnSurface
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: `${SystemInfo.diskName} ${SystemInfo.diskType} - ${(ResourceUsage.diskFree / (1024 * 1024)).toFixed(0)} GB free`
                }
            }

            // Package Counts
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 12
                spacing: 4

                // Separator line
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Appearance.colors.colOutlineVariant
                }

                // Packages Header
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnSurfaceVariant
                    text: Translation.tr("Packages")
                }

                // Packages Row
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 24

                    // Pacman
                    Column {
                        spacing: 2
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.larger
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnSurface
                            text: SystemInfo.pacmanCount
                        }
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                            text: "pacman"
                        }
                    }

                    // AUR
                    Column {
                        spacing: 2
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.larger
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnSurface
                            text: SystemInfo.aurCount
                        }
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                            text: "AUR"
                        }
                    }

                    // Flatpak
                    Column {
                        spacing: 2
                        visible: SystemInfo.flatpakCount > 0
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.larger
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnSurface
                            text: SystemInfo.flatpakCount
                        }
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                            text: "flatpak"
                        }
                    }

                    // Snap
                    Column {
                        spacing: 2
                        visible: SystemInfo.snapCount > 0
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.larger
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnSurface
                            text: SystemInfo.snapCount
                        }
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                            text: "snap"
                        }
                    }

                    // AppImage
                    Column {
                        spacing: 2
                        visible: SystemInfo.appimageCount > 0
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.larger
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnSurface
                            text: SystemInfo.appimageCount
                        }
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                            text: "AppImage"
                        }
                    }
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 5

            RippleButtonWithIcon {
                materialIcon: "auto_stories"
                mainText: Translation.tr("Documentation")
                onClicked: {
                    Qt.openUrlExternally(SystemInfo.documentationUrl)
                }
            }
            RippleButtonWithIcon {
                materialIcon: "support"
                mainText: Translation.tr("Help & Support")
                onClicked: {
                    Qt.openUrlExternally(SystemInfo.supportUrl)
                }
            }
            RippleButtonWithIcon {
                materialIcon: "bug_report"
                mainText: Translation.tr("Report a Bug")
                onClicked: {
                    Qt.openUrlExternally(SystemInfo.bugReportUrl)
                }
            }
            RippleButtonWithIcon {
                materialIcon: "policy"
                materialIconFill: false
                mainText: Translation.tr("Privacy Policy")
                onClicked: {
                    Qt.openUrlExternally(SystemInfo.privacyPolicyUrl)
                }
            }

        }

    }

    ContentSection {
        icon: "folder_managed"
        title: Translation.tr("Dotfiles")

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            spacing: 4

            // Dotfiles Name
            RowLayout {
                spacing: 8
                IconImage {
                    implicitSize: 24
                    source: Quickshell.iconPath("illogical-impulse")
                }
                StyledText {
                    text: Translation.tr("illogical-impulse")
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Medium
                }
            }

            // URL
            StyledText {
                Layout.leftMargin: 32
                font.pixelSize: Appearance.font.pixelSize.normal
                text: "https://github.com/rewalo/dots-hyprland"
                textFormat: Text.MarkdownText
                onLinkActivated: (link) => {
                    Qt.openUrlExternally(link)
                }
                PointingHandLinkHover {}
            }
        }

        Flow {
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 5

            RippleButtonWithIcon {
                materialIcon: "auto_stories"
                mainText: Translation.tr("Documentation")
                onClicked: {
                    Qt.openUrlExternally("https://github.com/rewalo/dots-hyprland")
                }
            }
            RippleButtonWithIcon {
                materialIcon: "adjust"
                materialIconFill: false
                mainText: Translation.tr("Issues")
                onClicked: {
                    Qt.openUrlExternally("https://github.com/rewalo/dots-hyprland/issues")
                }
            }
            RippleButtonWithIcon {
                materialIcon: "forum"
                mainText: Translation.tr("Discussions")
                onClicked: {
                    Qt.openUrlExternally("https://github.com/rewalo/dots-hyprland/discussions")
                }
            }
            RippleButtonWithIcon {
                materialIcon: "favorite"
                mainText: Translation.tr("Donate")
                onClicked: {
                    Qt.openUrlExternally("https://github.com/sponsors/rewalo")
                }
            }
        }
    }
}
