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

    // Keep the inset fill, without repeating the notification panel's outline
    // around every utility.
    StyledRect {
        anchors.fill: parent
        anchors.topMargin: root.headingHeight / 2
        radius: root.rounding
        color: root.fillColour
    }

    StyledText {
        id: heading

        x: root.rounding + Appearance.padding.normal
        text: root.title
        color: Colours.palette.m3outline
        font.family: Appearance.font.family.mono
        font.pointSize: Appearance.font.size.small
        font.weight: 600
        font.letterSpacing: 2
    }
}
