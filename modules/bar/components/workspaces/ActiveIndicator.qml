import qs.components
import qs.services
import qs.config
import QtQuick

StyledRect {
    id: root
    required property int activeWsId
    required property Repeater workspaces
    required property Item mask

    readonly property int currentWsIdx: ((activeWsId - 1) % Config.bar.workspaces.shown + Config.bar.workspaces.shown) % Config.bar.workspaces.shown
    readonly property Item current: workspaces.count > 0 ? workspaces.itemAt(currentWsIdx) : null

    // A position marker, without stretching or recolouring the workspace text.
    y: mask.y + (current?.y ?? 0) + (Config.bar.sizes.innerWidth - Appearance.padding.small * 2 - height) / 2
    implicitWidth: 3
    implicitHeight: 16
    radius: 1.5
    color: Colours.palette.m3primary

    Behavior on y {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }
}
