pragma ComponentBehavior: Bound

import qs.components
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities

    readonly property bool shouldBeActive:
        root.visibilities.wallpaperPicker

    readonly property real nonAnimWidth:
        content.implicitWidth

    readonly property real nonAnimHeight:
        content.implicitHeight

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    visible: opacity > 0
    enabled: root.shouldBeActive

    opacity: root.shouldBeActive ? 1 : 0
    scale: root.shouldBeActive ? 1 : 0.92

    onShouldBeActiveChanged: {
        if (!root.shouldBeActive)
            return;

        root.visibilities.launcher = false;
        root.visibilities.session = false;
        root.visibilities.dashboard = false;
    }

    Behavior on opacity {
        NumberAnimation {
            duration: root.shouldBeActive ? Appearance.anim.durations.normal : 260
            easing.type: root.shouldBeActive ? Easing.OutQuint : Easing.InOutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.shouldBeActive ? Appearance.anim.durations.normal : 260
            easing.type: root.shouldBeActive ? Easing.OutBack : Easing.InOutCubic
        }
    }

    Content {
        id: content

        anchors.centerIn: parent
        visibilities: root.visibilities
    }
}
