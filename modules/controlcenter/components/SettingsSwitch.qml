pragma ComponentBehavior: Bound
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls

Controls.Switch {
    id: root
    property int cLayer: 0
    padding: 0
    implicitWidth: 36
    implicitHeight: 24
    indicator: Rectangle {
        implicitWidth: 36
        implicitHeight: 21
        y: (root.height - height) / 2
        radius: 11
        color: root.checked ? Colours.palette.m3primary : Colours.palette.m3surfaceContainerHighest
        border.width: root.activeFocus || !root.checked ? 1 : 0
        border.color: root.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
        Rectangle {
            x: root.checked ? 18 : 3
            y: 3
            width: 15; height: 15; radius: 8
            color: root.checked ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
            Behavior on x { NumberAnimation { duration: 120 * Appearance.anim.durations.scale } }
        }
    }
}
