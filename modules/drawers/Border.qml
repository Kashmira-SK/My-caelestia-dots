pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property Item bar

    anchors.fill: parent

    StyledRect {
        anchors.fill: parent
        color: Colours.palette.m3surface

        layer.enabled: true
        layer.effect: MultiEffect {
            maskSource: mask
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }
    }

    Item {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.margins: Config.border.thickness
            anchors.leftMargin: root.bar.floating ? Config.border.thickness : root.bar.implicitWidth
            radius: Config.border.rounding
        }
    }

    // Use the same surface/opacity pipeline as the attached border, but draw a
    // separate rounded rail. Its width follows the existing reveal animation.
    StyledRect {
        visible: root.bar.floating && root.bar.visible
        x: root.bar.edgeGap
        y: root.bar.edgeGap
        width: Math.max(0, root.bar.width - root.bar.edgeGap)
        height: Math.max(0, root.height - root.bar.edgeGap * 2)
        radius: Math.min(6, width / 2)
        color: Colours.palette.m3surface
    }
}
