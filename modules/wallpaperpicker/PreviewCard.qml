pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    property string imagePath: ""
    property real overlayOpacity: 0
    property int borderWidth: 1
    property color borderColour: Qt.alpha(Colours.palette.m3outlineVariant, 0.25)
    readonly property bool ready: image.status === Image.Ready
    readonly property bool failed: image.status === Image.Error

    signal activated()

    StyledClippingRect {
        anchors.fill: parent
        radius: Appearance.rounding.large
        color: Colours.palette.m3surfaceContainer
        border.width: root.borderWidth
        border.color: root.borderColour

        MaterialIcon {
            anchors.centerIn: parent
            text: "wallpaper"
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.extraLarge * 2.5
        }

        Image {
            id: image

            anchors.fill: parent
            source: root.imagePath
                ? Qt.resolvedUrl(root.imagePath.split("/").map(encodeURIComponent).join("/"))
                : ""
            // Fixed decode size: scaling a card must never trigger another load.
            sourceSize: Qt.size(660, 372)
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            cache: true
            smooth: true
        }

        StyledRect {
            visible: root.overlayOpacity > 0
            anchors.fill: parent
            radius: Appearance.rounding.large
            // Follow the slide directly; StyledRect animates changes to color.
            color: Colours.palette.m3surface
            opacity: root.overlayOpacity
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activated()
        }
    }
}
