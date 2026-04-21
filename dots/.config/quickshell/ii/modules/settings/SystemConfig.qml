import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    forceWidth: true

    // Update states: 0=idle, 1=updating, 2=complete
    property int updateState: 0
    property string updateLog: ""
    property int lastLogSize: 0
    property int staleCount: 0

    function runUpdate() {
        updateState = 1;
        updateLog = "";
        lastLogSize = 0;
        staleCount = 0;
        updateIcon.rotation = 0;
        Quickshell.execDetached(["bash", "-c", "pkexec pacman -Syu --noconfirm > /tmp/qs-update.log 2>&1"]);
        // Start checking after pkexec has had time to show password prompt
        startCheckTimer.restart();
    }

    // Delay before checking completion to allow pkexec to start
    Timer {
        id: startCheckTimer
        interval: 2000
        onTriggered: {
            logPoller.running = true;
            completionChecker.running = true;
        }
    }

    function finishUpdate(state) {
        completionChecker.stop();
        logPoller.stop();
        updateState = state;
        updateIcon.rotation = 0;
        Updates.refresh();
    }

    // Poll the update log file more frequently
    Timer {
        id: logPoller
        interval: 50
        repeat: true
        onTriggered: {
            logReader.running = true;
        }
    }

    // Read last few lines of log for status
    Process {
        id: logReader
        command: ["bash", "-c", "tail -n 3 /tmp/qs-update.log 2>/dev/null || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim().split('\n').pop();
                if (line) updateLog = line;
            }
        }
    }

    // Check if pacman process has finished
    Timer {
        id: completionChecker
        interval: 500
        repeat: true
        onTriggered: {
            processChecker.running = true;
        }
    }

    Process {
        id: processChecker
        // Check if pkexec or pacman is still running
        command: ["bash", "-c", "pgrep -x 'pkexec|pacman' > /dev/null && echo 'running' || echo 'done'"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (updateState !== 1) return;
                const output = text.trim();

                if (output === "running") {
                    // still running, check log staleness
                    sizeChecker.running = true;
                    return;
                }

                // process finished - check if pacman actually ran
                completionReader.running = true;
            }
        }
    }

    // Read full log for pacman sync check
    Process {
        id: completionReader
        command: ["bash", "-c", "cat /tmp/qs-update.log 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (updateState !== 1) return;
                const logContent = text || "";

                // If no pacman sync output at all, likely cancelled before starting
                if (!logContent.includes("synchronizing") && !logContent.includes(" targets")) {
                    finishUpdate(0);
                    return;
                }

                // pacman finished successfully
                finishUpdate(2);
            }
        }
    }

    // Track log staleness to detect stuck states
    Process {
        id: sizeChecker
        command: ["bash", "-c", "wc -c < /tmp/qs-update.log 2>/dev/null || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const size = parseInt(text.trim()) || 0;
                if (size === lastLogSize) {
                    staleCount++;
                    // If log hasn't changed for ~3 seconds while pacman is running, force check
                    if (staleCount > 6) {
                        processChecker.running = true;
                    }
                } else {
                    staleCount = 0;
                    lastLogSize = size;
                }
            }
        }
    }

    ContentSection {
        icon: "deployed_code_update"
        title: Translation.tr("System Updates")

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MaterialSymbol {
                id: updateIcon
                iconSize: 28
                text: {
                    if (updateState === 1) return "sync";
                    if (updateState === 2) return "check_circle";
                    return Updates.count > 0 ? "system_update" : "check_circle";
                }
                color: {
                    if (updateState === 1 || updateState === 2) return Appearance.m3colors.m3primary;
                    return Updates.count > 0 ? Appearance.colors.colPrimary : Appearance.colors.colSubtext;
                }
                SequentialAnimation on rotation {
                    running: updateState === 1
                    loops: Animation.Infinite
                    NumberAnimation { duration: 1000; from: 0; to: 360 }
                }
            }
            ColumnLayout {
                spacing: 2
                StyledText {
                    text: {
                        if (updateState === 2) return Translation.tr("Updates installed");
                        if (Updates.checking) return Translation.tr("Checking...");
                        if (Updates.count > 0) return Translation.tr("%1 updates available").arg(Updates.count);
                        return Translation.tr("System up to date");
                    }
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnSecondaryContainer
                }
                StyledText {
                    visible: updateState === 1 && updateLog !== ""
                    text: updateLog
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colSubtext
                }
            }
        }

        StyledIndeterminateProgressBar {
            Layout.fillWidth: true
            Layout.topMargin: 8
            visible: updateState === 1
        }

        RowLayout {
            spacing: 8
            Layout.topMargin: 12

            RippleButtonWithIcon {
                materialIcon: "refresh"
                mainText: Translation.tr("Check now")
                enabled: !Updates.checking && updateState === 0
                onClicked: Updates.refresh()
            }
            RippleButtonWithIcon {
                id: updateButton
                materialIcon: {
                    if (updateState === 1) return "sync";
                    if (updateState === 2) return "check";
                    return "upgrade";
                }
                mainText: {
                    if (updateState === 1) return Translation.tr("Updating...");
                    if (updateState === 2) return Translation.tr("Done");
                    return Translation.tr("Run system update");
                }
                enabled: updateState === 0 && Updates.count > 0
                colBackground: Appearance.m3colors.m3primaryContainer
                textColor: Appearance.m3colors.m3onPrimaryContainer
                onClicked: {
                    if (updateState === 2) {
                        updateState = 0;
                        updateLog = "";
                    } else {
                        runUpdate();
                    }
                }
            }
        }

        ConfigSwitch {
            buttonIcon: "av_timer"
            text: Translation.tr("Enable update checks")
            checked: Config.options.updates.enableCheck
            onCheckedChanged: {
                Config.options.updates.enableCheck = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "notifications"
            text: Translation.tr("Notify when updates are available")
            enabled: Config.options.updates.enableCheck
            checked: Config.options.updates.notifyAvailableInBackground ?? false
            onCheckedChanged: {
                Config.options.updates.notifyAvailableInBackground = checked;
            }
        }

        ConfigSpinBox {
            icon: "schedule"
            text: Translation.tr("Check interval (mins)")
            value: Config.options.updates.checkInterval
            from: 30
            to: 1440
            stepSize: 30
            onValueChanged: {
                Config.options.updates.checkInterval = value;
            }
        }
    }

    ContentSection {
        icon: "computer"
        title: Translation.tr("System Tools")

        ContentSubsection {
            title: Translation.tr("Open system applications")
            tooltip: Translation.tr("Launch these from the config (edit apps.* in config.json to customize)")

            Flow {
                Layout.fillWidth: true
                spacing: 8
                Layout.topMargin: 8

                RippleButtonWithIcon {
                    materialIcon: "bluetooth"
                    mainText: Translation.tr("Bluetooth")
                    onClicked: Quickshell.execDetached(["bash", "-c", Config.options.apps.bluetooth])
                }
                RippleButtonWithIcon {
                    materialIcon: "wifi"
                    mainText: Translation.tr("Network")
                    onClicked: Quickshell.execDetached(["bash", "-c", Config.options.apps.network])
                }
                RippleButtonWithIcon {
                    materialIcon: "person"
                    mainText: Translation.tr("User accounts")
                    onClicked: Quickshell.execDetached(["bash", "-c", Config.options.apps.manageUser])
                }
                RippleButtonWithIcon {
                    materialIcon: "monitoring"
                    mainText: Translation.tr("Task manager")
                    onClicked: Quickshell.execDetached(["bash", "-c", Config.options.apps.taskManager])
                }
                RippleButtonWithIcon {
                    materialIcon: "volume_up"
                    mainText: Translation.tr("Volume mixer")
                    onClicked: {
                        Audio.launchConfigurableShellCommand(Config.options.apps.volumeMixer);
                    }
                }
                RippleButtonWithIcon {
                    materialIcon: "terminal"
                    mainText: Translation.tr("Terminal")
                    onClicked: Quickshell.execDetached(["bash", "-c", Config.options.apps.terminal])
                }
            }
        }
    }
}
