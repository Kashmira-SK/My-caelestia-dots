pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick

StyledSlider {
    id: root
    implicitHeight: 30

    background: StyledClippingRect {
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        width: root.availableWidth
        height: 22
        radius: Appearance.rounding.panel
        color: Colours.palette.m3surfaceContainerHighest

        StyledRect {
            width: parent.width * root.position
            height: parent.height
            x: root.mirrored ? parent.width - width : 0
            color: Colours.palette.m3primary
        }
    }

    handle: StyledRect {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 10
        implicitHeight: 22
        radius: 3
        color: Colours.palette.m3primary

        StyledRect {
            anchors.centerIn: parent
            width: 2
            height: 12
            radius: 1
            color: Colours.palette.m3onPrimary
        }
    }
}
