pragma ComponentBehavior: Bound

import "NavigationField.js" as Field
import QtQuick
import qs.components
import qs.config
import qs.services

StyledClippingRect {
    id: root

    required property real dayProgress
    required property string timeText
    required property string dateText
    required property string greeting
    required property string osText
    required property string wmText
    required property string uptimeText

    property bool animating: true
    property real phase: 0

    radius: Appearance.rounding.panel
    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
    Accessible.name: qsTr("Celestial navigation dashboard")

    Canvas {
        id: arrayCanvas

        objectName: "navigationArrayCanvas"
        anchors.fill: parent
        onAvailableChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            const centreX = width * 0.5;
            const centreY = height * 0.5;
            const dayRadius = Math.min(width, height) * 0.225;
            const systemNodes = [[width * 0.18, height * 0.29], [width * 0.13, height * 0.50], [width * 0.18, height * 0.71]];

            const dot = (x, y, alpha, size, colour) => {
                ctx.globalAlpha = alpha;
                ctx.fillStyle = colour;
                ctx.fillRect(x - size / 2, y - size / 2, size, size);
            };
            const dottedLine = (x1, y1, x2, y2, alpha) => {
                const length = Math.hypot(x2 - x1, y2 - y1);
                const steps = Math.max(1, Math.floor(length / 7));
                for (let step = 0; step <= steps; step++) {
                    const progress = step / steps;
                    dot(x1 + (x2 - x1) * progress, y1 + (y2 - y1) * progress, alpha, 0.8, Colours.palette.m3outlineVariant);
                }
            };

            for (let i = 0; i < Field.starCount(width, height); i++) {
                const star = Field.star(i, root.phase, width, height);
                dot(star.x, star.y, star.alpha, star.size, Colours.palette.m3onSurfaceVariant);
            }

            for (let nodeIndex = 0; nodeIndex < systemNodes.length; nodeIndex++) {
                const node = systemNodes[nodeIndex];
                const angle = Math.atan2(node[1] - centreY, node[0] - centreX);
                const edgeX = centreX + Math.cos(angle) * dayRadius;
                const edgeY = centreY + Math.sin(angle) * dayRadius;
                dottedLine(node[0], node[1], edgeX, edgeY, 0.24);

                ctx.globalAlpha = 0.34;
                ctx.strokeStyle = Colours.palette.m3outlineVariant;
                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.arc(node[0], node[1], 11, 0, Math.PI * 2);
                ctx.stroke();

                const satelliteAngle = root.phase * (0.3 + nodeIndex * 0.04) + nodeIndex * 2.1;
                dot(node[0] + Math.cos(satelliteAngle) * 11, node[1] + Math.sin(satelliteAngle) * 11, 0.8, 3.2, Colours.palette.m3secondary);

                const pulse = Field.signalPoint(root.phase, nodeIndex / 3, node[0], node[1], edgeX, edgeY);
                dot(pulse.x, pulse.y, pulse.alpha * 0.55, 2.4, Colours.palette.m3primary);
            }

            ctx.lineWidth = 1;
            for (let segment = 0; segment < 48; segment++) {
                const start = -Math.PI / 2 + segment / 48 * Math.PI * 2 + 0.018;
                const end = -Math.PI / 2 + (segment + 1) / 48 * Math.PI * 2 - 0.018;
                const completed = (segment + 1) / 48 <= root.dayProgress;
                ctx.globalAlpha = completed ? 0.82 : 0.22;
                ctx.strokeStyle = completed ? Colours.palette.m3primary : Colours.palette.m3outlineVariant;
                ctx.lineWidth = completed ? 2 : 1;
                ctx.beginPath();
                ctx.arc(centreX, centreY, dayRadius, start, end);
                ctx.stroke();
            }

            ctx.globalAlpha = 0.18;
            ctx.strokeStyle = Colours.palette.m3secondary;
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.arc(centreX, centreY, dayRadius - 15, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(centreX, centreY, dayRadius + 13, 0, Math.PI * 2);
            ctx.stroke();

            const marker = Field.ringPoint(root.dayProgress, centreX, centreY, dayRadius);
            ctx.globalAlpha = 0.96;
            ctx.fillStyle = Colours.palette.m3primary;
            ctx.beginPath();
            ctx.arc(marker.x, marker.y, 5, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalAlpha = 0.18 + Math.sin(root.phase * 1.8) * 0.04;
            ctx.beginPath();
            ctx.arc(marker.x, marker.y, 10, 0, Math.PI * 2);
            ctx.fill();

            ctx.globalAlpha = 0.3;
            ctx.strokeStyle = Colours.palette.m3outlineVariant;
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(centreX - 7, centreY);
            ctx.lineTo(centreX + 7, centreY);
            ctx.moveTo(centreX, centreY - 7);
            ctx.lineTo(centreX, centreY + 7);
            ctx.stroke();
            ctx.globalAlpha = 1;
        }
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Appearance.padding.large * 1.4
        text: qsTr("CELESTIAL NAVIGATION ARRAY")
        color: Colours.palette.m3outline
        font.family: Appearance.font.family.mono
        font.pointSize: Appearance.font.size.small
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 3
    }

    Column {
        anchors.centerIn: parent
        width: 190
        spacing: Appearance.spacing.small

        StyledText {
            width: parent.width
            text: root.timeText
            color: Colours.palette.m3onSurface
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.extraLarge * 1.45
            font.weight: 500
            horizontalAlignment: Text.AlignHCenter
        }

        StyledText {
            width: parent.width
            text: root.dateText
            color: Colours.palette.m3onSurfaceVariant
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.smaller
            horizontalAlignment: Text.AlignHCenter
        }

        StyledText {
            width: parent.width
            text: qsTr("DAY %1%").arg(Math.round(root.dayProgress * 100))
            color: Colours.palette.m3primary
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.smaller
            font.weight: 600
            font.letterSpacing: 2
            horizontalAlignment: Text.AlignHCenter
        }
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        anchors.topMargin: Math.min(parent.width, parent.height) * 0.225 + Appearance.spacing.large
        text: root.greeting
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Appearance.font.size.normal
        font.weight: 600
    }

    InfoNode {
        nodeY: root.height * 0.29
        labelText: qsTr("SYS / OS")
        valueText: root.osText
    }

    InfoNode {
        nodeY: root.height * 0.50
        nodeX: root.width * 0.13
        labelText: qsTr("SYS / WM")
        valueText: root.wmText
    }

    InfoNode {
        nodeY: root.height * 0.71
        labelText: qsTr("SYS / UPTIME")
        valueText: root.uptimeText
    }

    Timer {
        interval: 50
        repeat: true
        running: root.visible && root.animating
        onTriggered: root.phase += 0.05
    }

    onPhaseChanged: arrayCanvas.requestPaint()
    onDayProgressChanged: arrayCanvas.requestPaint()

    component InfoNode: Item {
        id: infoNode

        required property real nodeY
        required property string labelText
        required property string valueText
        property real nodeX: root.width * 0.18

        x: nodeX - width - 20
        y: nodeY - height / 2
        width: 118
        height: 42

        Column {
            anchors.fill: parent
            spacing: 2

            StyledText {
                width: parent.width
                text: infoNode.labelText
                color: Colours.palette.m3outline
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.smaller
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1.5
                horizontalAlignment: Text.AlignRight
            }

            StyledText {
                width: parent.width
                text: infoNode.valueText
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                font.weight: 500
                maximumLineCount: 1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
