pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property real clockSize: Math.min(width, height - dateRow.implicitHeight - Appearance.spacing.normal - Appearance.padding.large * 2) - Appearance.padding.large * 2
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

        StyledRect {
            anchors.fill: parent
            radius: width / 2
            color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
            border.color: Colours.palette.m3outlineVariant
            border.width: 1
        }

        Repeater {
            model: 60

            Item {
                required property int index
                anchors.centerIn: parent
                width: 1
                height: parent.height
                rotation: index * 6

                StyledRect {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: index % 5 === 0 ? 6 : 10

                    implicitWidth: index % 5 === 0 ? (index % 15 === 0 ? 2.5 : 1.5) : 1
                    implicitHeight: index % 5 === 0 ? (index % 15 === 0 ? 14 : 10) : 4
                    radius: 1
                    color: index % 15 === 0
                        ? Colours.palette.m3primary
                        : index % 5 === 0
                            ? Colours.palette.m3onSurfaceVariant
                            : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.3)
                }
            }
        }

        Canvas {
            id: leafCanvas
            anchors.centerIn: parent
            width: root.clockSize * 0.28
            height: root.clockSize * 0.28

            property color leafColour: Qt.alpha(Colours.palette.m3tertiary, 0.5)
            onLeafColourChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                var cx = width / 2;
                var cy = height / 2;

                ctx.strokeStyle = leafColour;
                ctx.fillStyle = leafColour;
                ctx.lineWidth = 0.8;

                for (var i = 0; i < 4; i++) {
                    ctx.save();
                    ctx.translate(cx, cy);
                    ctx.rotate((Math.PI / 2) * i);

                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, -height * 0.38);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.ellipse(-width * 0.09, -height * 0.38, width * 0.18, height * 0.20);
                    ctx.fill();

                    ctx.beginPath();
                    ctx.ellipse(-width * 0.12, -height * 0.22, width * 0.10, height * 0.11);
                    ctx.fill();
                    ctx.beginPath();
                    ctx.ellipse(width * 0.02, -height * 0.22, width * 0.10, height * 0.11);
                    ctx.fill();

                    ctx.restore();
                }
            }

            Component.onCompleted: requestPaint()
        }

        Item {
            anchors.centerIn: parent
            width: 6
            height: parent.height
            rotation: (root.hours % 12) * 30 + root.minutes * 0.5

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: -4

                implicitWidth: 4
                implicitHeight: root.clockSize * 0.24
                radius: 2
                color: Colours.palette.m3onSurface
            }

            Behavior on rotation {
                Anim {
                    duration: Appearance.anim.durations.large
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }
        }

        Item {
            anchors.centerIn: parent
            width: 4
            height: parent.height
            rotation: root.minutes * 6 + root.seconds * 0.1

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: -4

                implicitWidth: 2.5
                implicitHeight: root.clockSize * 0.34
                radius: 2
                color: Colours.palette.m3onSurfaceVariant
            }

            Behavior on rotation {
                Anim {
                    duration: Appearance.anim.durations.large
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }
        }

        Item {
            anchors.centerIn: parent
            width: 2
            height: parent.height
            rotation: root.seconds * 6

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: -(root.clockSize * 0.07)

                implicitWidth: 1.5
                implicitHeight: root.clockSize * 0.38
                radius: 1
                color: Colours.palette.m3primary
            }

            Behavior on rotation {
                Anim { duration: 200 }
            }
        }

        StyledRect {
            anchors.centerIn: parent
            implicitWidth: 10
            implicitHeight: 10
            radius: width / 2
            color: Colours.palette.m3primary
        }
    }

    Row {
        id: dateRow

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clockFace.bottom
        anchors.topMargin: Appearance.spacing.normal
        spacing: 5

        StyledText {
            text: {
                const days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
                return days[new Date().getDay()] + ",";
            }
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.smaller
        }

        StyledText {
            text: {
                const months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
                return months[new Date().getMonth()];
            }
            color: Colours.palette.m3primary
            font.pointSize: Appearance.font.size.smaller
            font.weight: 500
        }

        StyledText {
            text: {
                const d = new Date();
                return d.getDate() + ", " + d.getFullYear();
            }
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.smaller
        }
    }
}
