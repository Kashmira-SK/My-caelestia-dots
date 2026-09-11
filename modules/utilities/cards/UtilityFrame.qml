pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    required property string title
    property real rounding: Appearance.rounding.normal
    property color fillColour: Colours.tPalette.m3surfaceContainer
    readonly property real headingHeight: heading.implicitHeight

    anchors.fill: parent

    Canvas {
        id: frame

        anchors.fill: parent
        anchors.topMargin: root.headingHeight / 2
        antialiasing: true
        property color outline: Colours.tPalette.m3outlineVariant
        property color fillColour: root.fillColour
        property real gapStart: heading.x - Appearance.spacing.small
        property real gapEnd: heading.x + heading.width + Appearance.spacing.small
        property real rounding: root.rounding
        onOutlineChanged: requestPaint()
        onFillColourChanged: requestPaint()
        onGapStartChanged: requestPaint()
        onGapEndChanged: requestPaint()
        onRoundingChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const right = width - 0.5;
            const bottom = height - 0.5;
            const r = Math.min(rounding, width / 2, height / 2);
            ctx.strokeStyle = outline;
            ctx.fillStyle = fillColour;
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
            // Canvas fills the open path as a closed shape, but leaves the
            // heading gap open when stroking. Fill and border share one edge.
            ctx.fill();
            ctx.stroke();
        }
    }

    StyledText {
        id: heading

        x: root.rounding + Appearance.padding.small
        text: root.title
        font.family: Appearance.font.family.mono
        font.pointSize: Appearance.font.size.small
        font.weight: 500
        font.letterSpacing: 1
    }
}
