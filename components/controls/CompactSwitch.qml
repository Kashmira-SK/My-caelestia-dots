pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick

StyledSwitch {
    id: root

    // Keep Awake's compact track and sliding thumb, without changing the
    // existing switch palette or its native keyboard/toggle behaviour.
    indicator: StyledRect {
        id: track
        objectName: "compactTrack"
        implicitWidth: 40
        implicitHeight: 22
        radius: Appearance.rounding.small / 2
        color: root.checked ? Colours.palette.m3primary : Colours.layer(Colours.palette.m3surfaceContainerHighest, root.cLayer)

        StyledRect {
            objectName: "compactThumb"
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 14
            radius: Appearance.rounding.small / 3
            x: root.checked ? track.width - width - 4 : 4
            color: root.checked ? Colours.palette.m3onPrimary : Colours.layer(Colours.palette.m3outline, root.cLayer + 1)

            Behavior on x {
                NumberAnimation {
                    duration: 120
                }
            }
        }

        StyledRect {
            anchors.fill: parent
            radius: parent.radius
            color: root.checked ? Colours.palette.m3primary : Colours.palette.m3onSurface
            opacity: root.pressed ? 0.1 : root.hovered ? 0.08 : 0
        }
    }
}
