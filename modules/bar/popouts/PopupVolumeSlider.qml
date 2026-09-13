pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick

StyledSlider {
    id: root
    implicitHeight: 30

    background: Item {
        x: root.leftPadding + root.handle.width / 2
        y: root.topPadding + (root.availableHeight - height) / 2
        width: Math.max(0, root.availableWidth - root.handle.width)
        height: 20

        // The blocks are a visual scale, not volume steps: input remains continuous.
        Repeater {
            model: 24
            StyledRect {
                required property int index
                readonly property int levelIndex: root.mirrored ? 23 - index : index
                width: Math.max(1, (parent.width - 23 * 3) / 24)
                height: 6 + levelIndex * 14 / 23
                x: index * (width + 3)
                y: parent.height - height
                radius: 1.5
                color: Colours.palette.m3surfaceContainerHighest

                StyledRect {
                    width: parent.width * Math.max(0, Math.min(1, root.position * 24 - parent.levelIndex))
                    height: parent.height
                    x: root.mirrored ? parent.width - width : 0
                    radius: parent.radius
                    color: Colours.palette.m3primary
                }
            }
        }
    }

    handle: StyledRect {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 10
        implicitHeight: 26
        radius: 3
        color: Qt.alpha(Colours.palette.m3primary, 0)
        border.width: 1
        border.color: Colours.palette.m3primary
    }
}
