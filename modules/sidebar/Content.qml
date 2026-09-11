import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Props props
    required property var visibilities

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: Appearance.spacing.normal

        StyledRect {
            id: panel

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: frameLabel.implicitHeight / 2

            radius: Appearance.rounding.normal
            color: Colours.tPalette.m3surfaceContainerLow

            Canvas {
                id: frame

                anchors.fill: parent
                antialiasing: true

                property color outline: Colours.tPalette.m3outlineVariant
                property real rounding: panel.radius
                property real gapStart: frameLabel.x - Appearance.spacing.small
                property real gapEnd: frameLabel.x + frameLabel.width + Appearance.spacing.small

                onOutlineChanged: requestPaint()
                onRoundingChanged: requestPaint()
                onGapStartChanged: requestPaint()
                onGapEndChanged: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    const right = width - 0.5;
                    const bottom = height - 0.5;
                    const r = Math.min(rounding, width / 2, height / 2);
                    ctx.strokeStyle = outline;
                    ctx.lineWidth = 1;
                    ctx.beginPath();
                    ctx.moveTo(gapEnd, 0.5);
                    ctx.lineTo(right - r, 0.5);
                    ctx.quadraticCurveTo(right, 0.5, right, r);
                    ctx.lineTo(right, bottom - r);
                    ctx.quadraticCurveTo(right, bottom, right - r, bottom);
                    ctx.lineTo(r, bottom);
                    ctx.quadraticCurveTo(0.5, bottom, 0.5, bottom - r);
                    ctx.lineTo(0.5, r);
                    ctx.quadraticCurveTo(0.5, 0.5, r, 0.5);
                    ctx.lineTo(gapStart, 0.5);
                    ctx.stroke();
                }
            }

            StyledText {
                id: frameLabel

                x: panel.radius + Appearance.padding.normal
                y: -implicitHeight / 2
                text: qsTr("NOTIFICATIONS")
                color: Colours.palette.m3outline
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.small
                font.weight: 600
                font.letterSpacing: 2
            }

            NotifDock {
                props: root.props
                visibilities: root.visibilities
            }
        }

        StyledRect {
            Layout.topMargin: Appearance.padding.large - layout.spacing
            Layout.fillWidth: true
            implicitHeight: 1

            color: Colours.tPalette.m3outlineVariant
        }
    }
}
