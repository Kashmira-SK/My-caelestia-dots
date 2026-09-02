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
            duration: Appearance.anim.durations.normal
            easing.type: Easing.OutQuint
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.OutBack
        }
    }

    Content {
        id: content

        anchors.centerIn: parent
        visibilities: root.visibilities
    }
}
