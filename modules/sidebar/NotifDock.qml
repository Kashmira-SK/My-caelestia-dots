pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.containers
import qs.components.effects
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Props props
    required property var visibilities
    readonly property int notifCount: Notifs.list.reduce((acc, n) => n.closed ? acc : acc + 1, 0)

    anchors.fill: parent
    anchors.margins: Appearance.padding.normal

    Component.onCompleted: Notifs.list.forEach(n => n.popup = false)

    RowLayout {
        id: title

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Appearance.padding.small

        spacing: Appearance.spacing.normal

        StyledText {
            Layout.fillWidth: true
            text: root.notifCount > 0 ? qsTr("ACTIVE FEED") : qsTr("INBOX CLEAR")
            color: Colours.palette.m3outlineVariant
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            font.weight: 500
            font.letterSpacing: 1
            elide: Text.ElideRight
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: root.notifCount.toString().padStart(2, "0")
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.normal
            font.family: Appearance.font.family.mono
            font.weight: 500
        }

        NotifToolButton {
            visible: root.notifCount > 0
            icon: "list-x"
            text: qsTr("Clear all notifications")
            onClicked: clearTimer.start()
        }
    }

    ClippingRectangle {
        id: clipRect

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.spacing.normal

        radius: Appearance.rounding.small
        color: "transparent"

        Loader {
            anchors.centerIn: parent
            active: opacity > 0
            opacity: root.notifCount > 0 ? 0 : 1

            sourceComponent: AnimatedImage {
                source: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/bongocat1.gif`)
                sourceSize.width: Math.min(180, clipRect.width * 0.48)
                width: sourceSize.width
                height: width * 155 / 200
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                playing: visible
                speed: 0.65
                Accessible.name: qsTr("No notifications")

                layer.enabled: true
                layer.effect: Colouriser {
                    colorizationColor: Colours.palette.m3outlineVariant
                    // Retain the character's ink detail, not a flat silhouette.
                    brightness: 0
                }
            }

            Behavior on opacity {
                Anim {
                    duration: Appearance.anim.durations.extraLarge
                }
            }
        }

        StyledFlickable {
            id: view

            anchors.fill: parent

            flickableDirection: Flickable.VerticalFlick
            contentWidth: width
            contentHeight: notifList.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: view
            }

            NotifDockList {
                id: notifList

                props: root.props
                visibilities: root.visibilities
                container: view
            }
        }
    }

    Timer {
        id: clearTimer

        repeat: true
        interval: 50
        onTriggered: {
            let next = null;
            for (let i = 0; i < notifList.repeater.count; i++) {
                next = notifList.repeater.itemAt(i);
                if (!next?.closed)
                    break;
            }
            if (next)
                next.closeAll();
            else
                stop();
        }
    }
}
