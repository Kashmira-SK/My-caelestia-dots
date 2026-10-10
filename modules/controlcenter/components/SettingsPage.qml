pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

StyledFlickable {
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds;
    id: root
    default property alias contents: body.data
    property string title: ""
    property string description: ""
    onTitleChanged: contentY = 0
    clip: true
    contentHeight: body.implicitHeight + 50
    flickableDirection: Flickable.VerticalFlick
    StyledScrollBar.vertical: StyledScrollBar { animatePosition: false; flickable: root }
    ColumnLayout {
        id: body
        width: Math.max(0, root.width - 56)
        x: 28
        y: 25
        spacing: 22
        ColumnLayout {
            visible: root.title !== ""
            Layout.fillWidth: true
            spacing: 7
            StyledText { text: root.title; Layout.fillWidth: true; wrapMode: Text.WordWrap; font.pointSize: 16.5 * Appearance.font.size.scale; font.weight: 600 }
            StyledText { visible: root.description !== ""; text: root.description; Layout.fillWidth: true; wrapMode: Text.WordWrap; font.pointSize: 9.75 * Appearance.font.size.scale; color: Colours.palette.m3onSurfaceVariant }
        }
    }
}
