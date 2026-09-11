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
            icon: "ellipsis"
            text: qsTr("Notification panel actions")
            selected: panelMenu.opened
            onClicked: panelMenu.opened ? panelMenu.close() : panelMenu.open()
        }
    }

    NotifMenu {
        id: panelMenu

        x: root.width - width
        y: title.y + title.height + Appearance.spacing.small
        width: Math.min(260, root.width)
        items: [{ text: qsTr("Clear all notifications") }]
        onChosen: clearTimer.start()
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

            sourceComponent: ColumnLayout {
                spacing: Appearance.spacing.normal

                Image {
                    asynchronous: true
                    source: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/dino.png`)
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: clipRect.width * 0.48

                    layer.enabled: true
                    layer.effect: Colouriser {
                        colorizationColor: Colours.palette.m3outlineVariant
                        brightness: 1
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Appearance.spacing.small
                    text: qsTr("QUEUE EMPTY")
                    color: Colours.palette.m3outlineVariant
                    font.pointSize: Appearance.font.size.large
                    font.family: Appearance.font.family.mono
                    font.weight: 600
                    font.letterSpacing: 3
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Nothing needs your attention")
                    color: Colours.palette.m3outlineVariant
                    font.pointSize: Appearance.font.size.small
                    font.family: Appearance.font.family.mono
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
