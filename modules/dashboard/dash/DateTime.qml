pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    readonly property real clockSize: Math.min(width, height - dateLabel.implicitHeight - Appearance.spacing.normal - Appearance.padding.large * 2) - Appearance.padding.large * 2
    readonly property int hours: Time.hour
    readonly property int minutes: Time.minute
    readonly property int seconds: Time.second

    Item {
        id: clockFace

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Appearance.padding.large

        width: root.clockSize
        height: root.clockSize

        // Clock face background circle
        StyledRect {
            anchors.fill: parent
            radius: width / 2
            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        }

        // Hour tick marks
        Repeater {
            model: 12

            Item {
                required property int index

                anchors.centerIn: parent
                width: 2
                height: parent.height

                rotation: index * 30

                StyledRect {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 8

                    implicitWidth: index % 3 === 0 ? 3 : 1.5
                    implicitHeight: index % 3 === 0 ? 16 : 10
                    radius: Appearance.rounding.full
                    color: index % 3 === 0 ? Colours.palette.m3primary : Colours.palette.m3outline
                }
            }
        }

        // Minute tick marks
        Repeater {
            model: 60

            Item {
                required property int index

                anchors.centerIn: parent
                width: 1
                height: parent.height

                rotation: index * 6
                visible: index % 5 !== 0

                StyledRect {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 12

                    implicitWidth: 1
                    implicitHeight: 4
                    radius: Appearance.rounding.full
                    color: Colours.palette.m3outlineVariant
                    opacity: 0.5
                }
            }
        }

        // Hour hand
        Item {
            anchors.centerIn: parent
            width: 6
            height: parent.height

            rotation: (root.hours % 12) * 30 + root.minutes * 0.5

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter

                implicitWidth: 4
                implicitHeight: root.clockSize * 0.22
                radius: 2
                color: Colours.palette.m3primary
            }

            Behavior on rotation {
                Anim {
                    duration: Appearance.anim.durations.large
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }
        }

        // Minute hand
        Item {
            anchors.centerIn: parent
            width: 4
            height: parent.height

            rotation: root.minutes * 6 + root.seconds * 0.1

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter

                implicitWidth: 3
                implicitHeight: root.clockSize * 0.32
                radius: 2
                color: Colours.palette.m3secondary
            }

            Behavior on rotation {
                Anim {
                    duration: Appearance.anim.durations.large
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }
        }

        // Second hand
        Item {
            anchors.centerIn: parent
            width: 2
            height: parent.height

            rotation: root.seconds * 6

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: -(root.clockSize * 0.06)

                implicitWidth: 1.5
                implicitHeight: root.clockSize * 0.36
                radius: 1
                color: Colours.palette.m3tertiary
            }

            Behavior on rotation {
                Anim {
                    duration: 200
                }
            }
        }

        // Center dot
        StyledRect {
            anchors.centerIn: parent
            implicitWidth: 8
            implicitHeight: 8
            radius: width / 2
            color: Colours.palette.m3primary
        }
    }

    // Date label below clock
    StyledText {
        id: dateLabel

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clockFace.bottom
        anchors.topMargin: Appearance.spacing.normal

        text: {
            const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
            const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            const now = new Date();
            return `${days[now.getDay()]}, ${months[now.getMonth()]} ${now.getDate()}, ${now.getFullYear()}`;
        }
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Appearance.font.size.small
    }
}
