pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var notif
    property bool copied

    Layout.fillWidth: true
    spacing: Appearance.spacing.small

    Repeater {
        model: root.notif.actions

        ActionButton {
            required property var modelData

            Layout.fillWidth: true
            text: modelData.text
            onClicked: {
                if (modelData.invoke)
                    modelData.invoke();
                else if (!root.notif.resident)
                    root.notif.close();
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        ActionButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            icon: "close"
            text: qsTr("Dismiss")
            onClicked: root.notif.close()
        }

        ActionButton {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            icon: root.copied ? "inventory" : "content_copy"
            text: root.copied ? qsTr("Copied") : qsTr("Copy")
            onClicked: {
                Quickshell.clipboardText = root.notif.body;
                root.copied = true;
                copyTimer.restart();
            }
        }
    }

    Timer {
        id: copyTimer

        interval: 3000
        onTriggered: root.copied = false
    }

    component ActionButton: StyledRect {
        id: action

        required property string text
        property string icon

        signal clicked

        implicitHeight: actionContent.implicitHeight + Appearance.padding.small * 2
        radius: actionStateLayer.pressed ? Appearance.rounding.small / 2 : Appearance.rounding.small
        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 4)

        StateLayer {
            id: actionStateLayer

            function onClicked(): void {
                action.clicked();
            }
        }

        RowLayout {
            id: actionContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Appearance.padding.normal
            anchors.rightMargin: Appearance.padding.normal
            spacing: Appearance.spacing.small

            MaterialIcon {
                visible: action.icon.length > 0
                text: action.icon
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: action.text
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Behavior on radius {
            Anim {
                duration: Appearance.anim.durations.expressiveFastSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
            }
        }
    }
}
