pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property string title
    required property string detail
    default property alias actions: controls.data

    Layout.fillWidth: true
    implicitHeight: Math.max(labels.implicitHeight, controls.implicitHeight)

    ColumnLayout {
        id: labels
        anchors.left: parent.left
        anchors.right: controls.left
        anchors.rightMargin: Appearance.spacing.normal
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacing.small

        StyledText {
            objectName: "connectionTitle"
            Layout.fillWidth: true
            text: root.title
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            font.weight: 500
            wrapMode: Text.Wrap
        }

        StyledText {
            objectName: "connectionDetail"
            Layout.fillWidth: true
            text: root.detail
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.small
            wrapMode: Text.Wrap
        }
    }

    RowLayout {
        id: controls
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacing.small
    }
}
