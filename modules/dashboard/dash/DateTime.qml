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

    // ── Clock face ────────────────────────────────────────────────────────
    Item {
        id: clockFace

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Appearance.padding.large

        width: root.clockSize
        height: root.clockSize

        // Dark face
        StyledRect {
            anchors.fill: parent
            radius: width / 2
            color: Qt.rgba(0.09, 0.09, 0.08, 0.95)
            border.color: Qt.rgba(1, 1, 1, 0.06)
            border.width: 1
        }

        // Hour tick marks (12 + 60 minute dots style)
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
                        ? Qt.rgba(0.83, 0.66, 0.30, 0.9)   // gold for 12/3/6/9
                        : index % 5 === 0
                            ? Qt.rgba(0.85, 0.85, 0.80, 0.45)  // white-ish for other hours
                            : Qt.rgba(0.85, 0.85, 0.80, 0.15)  // very faint minutes
                }
            }
        }

        // Botanical leaf canvas at center
        Canvas {
            id: leafCanvas
            anchors.centerIn: parent
            width: root.clockSize * 0.28
            height: root.clockSize * 0.28

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                var cx = width / 2;
                var cy = height / 2;
                var leafColor = Qt.rgba(0.28, 0.42, 0.22, 0.55);

                ctx.strokeStyle = leafColor;
                ctx.fillStyle = leafColor;
                ctx.lineWidth = 0.8;

                // Draw 4 leaves rotated around center
                for (var i = 0; i < 4; i++) {
                    ctx.save();
                    ctx.translate(cx, cy);
                    ctx.rotate((Math.PI / 2) * i);

                    // Stem
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, -height * 0.38);
                    ctx.stroke();

                    // Leaf blob
                    ctx.beginPath();
                    ctx.ellipse(-width * 0.09, -height * 0.38, width * 0.18, height * 0.20);
                    ctx.fill();

                    // Side mini leaves
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

        // Hour hand — off-white, thick
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
                color: Qt.rgba(0.92, 0.90, 0.86, 0.95)
            }

            Behavior on rotation {
                Anim {
                    duration: Appearance.anim.durations.large
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }
        }

        // Minute hand — off-white, thinner
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
                color: Qt.rgba(0.88, 0.86, 0.82, 0.85)
            }

            Behavior on rotation {
                Anim {
                    duration: Appearance.anim.durations.large
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }
        }

        // Second hand — gold
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
                color: Qt.rgba(0.83, 0.66, 0.30, 1.0)   // gold
            }

            Behavior on rotation {
                Anim { duration: 200 }
            }
        }

        // Center cap
        StyledRect {
            anchors.centerIn: parent
            implicitWidth: 10
            implicitHeight: 10
            radius: width / 2
            color: Qt.rgba(0.83, 0.66, 0.30, 1.0)   // gold dot
        }
    }

    // ── Date label ────────────────────────────────────────────────────────
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
            color: Qt.rgba(0.75, 0.73, 0.68, 0.85)
            font.pointSize: Appearance.font.size.smaller
        }

        StyledText {
            text: {
                const months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
                return months[new Date().getMonth()];
            }
            color: Qt.rgba(0.83, 0.66, 0.30, 1.0)   // gold highlight on month
            font.pointSize: Appearance.font.size.smaller
            font.weight: 500
        }

        StyledText {
            text: {
                const d = new Date();
                return d.getDate() + ", " + d.getFullYear();
            }
            color: Qt.rgba(0.75, 0.73, 0.68, 0.85)
            font.pointSize: Appearance.font.size.smaller
        }
    }
}
