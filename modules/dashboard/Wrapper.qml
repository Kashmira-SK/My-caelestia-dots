pragma ComponentBehavior: Bound

import qs.components
import qs.components.filedialog
import qs.config
import qs.services
import qs.utils
import Caelestia
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    readonly property PersistentProperties dashState: PersistentProperties {
        property int currentTab
        property int gifIndex: 0
        property date currentDate: new Date()

        reloadableId: "dashboardState"
    }
    readonly property FileDialog facePicker: FileDialog {
        title: qsTr("Select a profile picture")
        filterLabel: qsTr("Image files")
        filters: Images.validImageExtensions
        onAccepted: path => {
            if (CUtils.copyFile(Qt.resolvedUrl(path), Qt.resolvedUrl(`${Paths.home}/.face`)))
                Quickshell.execDetached(["notify-send", "-a", "caelestia-shell", "-u", "low", "-h", `STRING:image-path:${path}`, "Profile picture changed", `Profile picture changed to ${Paths.shortenHome(path)}`]);
            else
                Quickshell.execDetached(["notify-send", "-a", "caelestia-shell", "-u", "critical", "Unable to change profile picture", `Failed to change profile picture to ${Paths.shortenHome(path)}`]);
        }
    }

    readonly property real nonAnimHeight: state === "visible" ? (content.item?.nonAnimHeight ?? 0) : pill.implicitHeight

    // Always visible now — the pill IS the collapsed dashboard, not a separate thing
    visible: !root.visibilities.islandHidden
    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    onStateChanged: {
        if (state === "visible" && timer.running) {
            timer.triggered();
            timer.stop();
        }
    }

    states: State {
        name: "visible"
        when: root.visibilities.dashboard && Config.dashboard.enabled

        PropertyChanges {
            root.implicitWidth: content.implicitWidth
            root.implicitHeight: content.implicitHeight
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                property: "implicitWidth"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
            Anim {
                target: root
                property: "implicitHeight"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                property: "implicitWidth"
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
            Anim {
                target: root
                property: "implicitHeight"
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Timer {
        id: timer

        running: true
        interval: Appearance.anim.durations.extraLarge
        onTriggered: {
            content.active = Qt.binding(() => (root.visibilities.dashboard && Config.dashboard.enabled) || root.visible);
            content.visible = true;
        }
    }

    // ── Collapsed pill — clock / visualizer / recording ─────────────────────
    Pill {
        id: pill

        visibilities: root.visibilities
        dashState: root.dashState

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        opacity: root.state === "visible" ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            Anim { duration: Appearance.anim.durations.expressiveEffects }
        }
    }

    // ── Collapse handle — visible only while expanded ────────────────────────
    Item {
        id: collapseHandle

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 80
        height: 18
        z: 10

        opacity: root.state === "visible" ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            Anim { duration: Appearance.anim.durations.expressiveEffects }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 44; height: 4; radius: 2
            color: Colours.palette.m3surfaceVariant
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.visibilities.dashboard = false
        }
    }

    // ── Expanded dashboard content ────────────────────────────────────────
    Loader {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        opacity: root.state === "visible" ? 1 : 0
        visible: false
        active: true

        Behavior on opacity {
            Anim { duration: Appearance.anim.durations.expressiveEffects }
        }

        sourceComponent: Content {
            visibilities: root.visibilities
            state: root.dashState
            facePicker: root.facePicker
        }
    }
}
