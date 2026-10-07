import Caelestia.Services
import QtQuick
import qs.components
import qs.config
import qs.services

Item {
    id: root

    required property bool playing
    property real phase: 0
    readonly property real peak: {
        let value = 0;
        for (let i = 0; i < Audio.cava.values.length; i++)
            value = Math.max(value, Audio.cava.values[i] ?? 0);
        return value;
    }

    implicitWidth: 270
    implicitHeight: 116
    Accessible.name: playing ? qsTr("Playing media signal visualiser") : qsTr("Idle orbital relay")

    ServiceRef {
        service: Audio.cava
    }

    Item {
        id: relay

        anchors.fill: parent

        Item {
            id: leftWing

            anchors.right: core.left
            anchors.rightMargin: 16
            anchors.verticalCenter: core.verticalCenter
            width: 92
            height: 58

            StyledRect {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 18
                implicitHeight: 1
                color: Colours.palette.m3outlineVariant
            }

            Repeater {
                model: 7

                StyledRect {
                    required property int index
                    readonly property int cavaIndex: Math.min(Config.services.visualiserBars - 1, Math.floor((6 - index) * Config.services.visualiserBars / 14))
                    readonly property real level: Audio.cava.values[cavaIndex] ?? 0

                    x: index * 11
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 8
                    implicitHeight: root.playing ? 15 + level * 34 : 15 + index % 2 * 3
                    radius: 1
                    color: Qt.alpha(Colours.palette.m3secondary, root.playing ? 0.42 + level * 0.48 : 0.24)

                    Behavior on implicitHeight {
                        NumberAnimation {
                            duration: 90
                        }
                    }
                }
            }
        }

        Item {
            id: rightWing

            anchors.left: core.right
            anchors.leftMargin: 16
            anchors.verticalCenter: core.verticalCenter
            width: 92
            height: 58

            StyledRect {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 18
                implicitHeight: 1
                color: Colours.palette.m3outlineVariant
            }

            Repeater {
                model: 7

                StyledRect {
                    required property int index
                    readonly property int cavaIndex: Math.min(Config.services.visualiserBars - 1, Math.floor((index + 7) * Config.services.visualiserBars / 14))
                    readonly property real level: Audio.cava.values[cavaIndex] ?? 0

                    x: 18 + index * 11
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 8
                    implicitHeight: root.playing ? 15 + level * 34 : 15 + index % 2 * 3
                    radius: 1
                    color: Qt.alpha(Colours.palette.m3secondary, root.playing ? 0.42 + level * 0.48 : 0.24)

                    Behavior on implicitHeight {
                        NumberAnimation {
                            duration: 90
                        }
                    }
                }
            }
        }

        StyledRect {
            id: orbit

            anchors.centerIn: parent
            implicitWidth: 62 + root.peak * 10
            implicitHeight: implicitWidth
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: Qt.alpha(Colours.palette.m3primary, root.playing ? 0.58 : 0.24)

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -2
                implicitWidth: 5
                implicitHeight: 5
                radius: width / 2
                color: Colours.palette.m3primary
            }

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: root.playing ? 7000 : 14000
                loops: Animation.Infinite
                running: root.visible
            }

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 100
                }
            }
        }

        StyledRect {
            id: core

            anchors.centerIn: parent
            implicitWidth: 30 + root.peak * 5
            implicitHeight: implicitWidth
            radius: width / 2
            color: Colours.palette.m3surfaceContainerHighest
            border.width: 1
            border.color: Colours.palette.m3primary

            StyledRect {
                anchors.centerIn: parent
                implicitWidth: 7 + root.peak * 4
                implicitHeight: implicitWidth
                radius: width / 2
                color: root.playing ? Colours.palette.m3primary : Colours.palette.m3outline
            }

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 90
                }
            }
        }

        transform: Translate {
            y: Math.sin(root.phase * 0.8) * 3
        }
    }

    Timer {
        interval: 50
        repeat: true
        running: root.visible
        onTriggered: root.phase += 0.05
    }
}
