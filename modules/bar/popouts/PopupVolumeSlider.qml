pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick

StyledSlider {
    id: root
    implicitHeight: 30

    background: StyledRect {
        x: root.leftPadding + root.handle.width / 2
        y: root.topPadding + (root.availableHeight - height) / 2
        width: Math.max(0, root.availableWidth - root.handle.width)
        height: 4
        radius: 2
        color: Colours.palette.m3surfaceContainerHighest

        StyledRect {
            width: parent.width * root.position
            height: parent.height
            x: root.mirrored ? parent.width - width : 0
            radius: parent.radius
            color: Colours.palette.m3primary
        }
    }

    handle: StyledRect {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 10
        implicitHeight: 16
        radius: 3
        color: Colours.palette.m3primary
    }
}
