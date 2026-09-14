pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick

StyledSlider {
    id: root
    implicitHeight: 30

    background: Rectangle {
        x: root.leftPadding + root.handle.width / 2
        y: root.topPadding + (root.availableHeight - height) / 2
        width: Math.max(0, root.availableWidth - root.handle.width)
        height: 8
        radius: 4
        color: Colours.palette.m3surfaceContainerHighest

        Rectangle {
            width: parent.width * root.position
            height: parent.height
            radius: parent.radius
            x: root.mirrored ? parent.width - width : 0
            color: Colours.palette.m3primary
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 18
        implicitHeight: 18
        radius: Appearance.rounding.panel
        color: Colours.palette.m3primary

        Rectangle {
            anchors.centerIn: parent
            width: 2
            height: 8
            radius: 1
            color: Colours.palette.m3onPrimary
        }
    }
}
