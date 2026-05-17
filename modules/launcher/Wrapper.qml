pragma ComponentBehavior: Bound

import qs.components
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property var panels

    readonly property bool shouldBeActive: visibilities.launcher && Config.launcher.enabled
    property int contentHeight

    readonly property real maxHeight: {
        let max = screen.height - Config.border.thickness * 2 - Appearance.spacing.large;
        if (visibilities.dashboard)
            max -= panels.dashboard.nonAnimHeight;
        return max;
    }

    onMaxHeightChanged: timer.start()

    visible: height > 0
    implicitHeight: 0
    implicitWidth: content.implicitWidth

    onShouldBeActiveChanged: {
        if (shouldBeActive) {
            timer.stop();
            hideAnim.stop();
            showAnim.start();
        } else {
            showAnim.stop();
            hideAnim.start();
        }
    }

    SequentialAnimation {
        id: showAnim

        ScriptAction {
            script: {
                root.implicitHeight = root.contentHeight;
                content.visible = true;
                content.opacity = 0;
                content.scale = 0.8;
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: content
                property: "opacity"
                to: 1
                duration: Appearance.anim.durations.normal
                easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: content
                property: "scale"
                to: 1
                duration: Appearance.anim.durations.normal
                easing.type: Easing.OutBack
            }
        }

        ScriptAction {
            script: root.implicitHeight = Qt.binding(() => content.implicitHeight)
        }
    }

    SequentialAnimation {
        id: hideAnim

        ParallelAnimation {
            NumberAnimation {
                target: content
                property: "opacity"
                to: 0
                duration: Appearance.anim.durations.small
                easing.type: Easing.Linear
            }

            NumberAnimation {
                target: content
                property: "scale"
                to: 0.9
                duration: Appearance.anim.durations.small
                easing.type: Easing.Linear
            }
        }

        ScriptAction {
            script: {
                content.visible = false;
                root.implicitHeight = 0;
                const c = content.item;
                if (c) c.search.text = "";
            }
        }
    }

    Connections {
        target: Config.launcher

        function onEnabledChanged(): void {
            timer.start();
        }

        function onMaxShownChanged(): void {
            timer.start();
        }
    }

    Connections {
        target: DesktopEntries.applications

        function onValuesChanged(): void {
            if (DesktopEntries.applications.values.length < Config.launcher.maxShown)
                timer.start();
        }
    }

    Timer {
        id: timer

        interval: Appearance.anim.durations.extraLarge

        onRunningChanged: {
            if (running && !root.shouldBeActive) {
                content.visible = false;
                content.active = true;
            } else {
                root.contentHeight = Math.min(root.maxHeight, content.implicitHeight);
                content.active = Qt.binding(() => root.shouldBeActive || root.visible);
                content.visible = true;
                if (showAnim.running) {
                    showAnim.stop();
                    showAnim.start();
                }
            }
        }
    }

    Loader {
        id: content

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        visible: false
        active: false
        opacity: 0
        scale: 0.8

        Component.onCompleted: timer.start()

        sourceComponent: Content {
            visibilities: root.visibilities
            panels: root.panels
            maxHeight: root.maxHeight

            Component.onCompleted: root.contentHeight = implicitHeight
        }
    }
}
