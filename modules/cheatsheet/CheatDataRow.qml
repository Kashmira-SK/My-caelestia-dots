pragma ComponentBehavior: Bound

import qs.components
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int rowIndex: 0
    default property alias rowChildren: rowLayout.data

    implicitHeight: rowLayout.implicitHeight + Appearance.padding.normal * 2

    StyledRect {
        anchors.fill: parent
        radius: Appearance.rounding.small
        color: Qt.alpha(Colours.tPalette.m3surfaceContainer, root.rowIndex % 2 === 0 ? 0.5 : 0.8)
    }

    RowLayout {
        id: rowLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Appearance.padding.normal

        spacing: Appearance.spacing.normal
    }
}
