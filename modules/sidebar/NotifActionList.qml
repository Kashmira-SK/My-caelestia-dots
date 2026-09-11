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
            alignment: Text.AlignLeft
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
        id: utilityActions

        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        ActionButton {
            Layout.maximumWidth: (utilityActions.width - utilityActions.spacing) / 2
            text: qsTr("Dismiss")
            onClicked: root.notif.close()
        }

        ActionButton {
            Layout.maximumWidth: (utilityActions.width - utilityActions.spacing) / 2
            text: root.copied ? qsTr("Copied") : qsTr("Copy")
            onClicked: {
                Quickshell.clipboardText = root.notif.body;
                root.copied = true;
                copyTimer.restart();
            }
        }

        Item {
            Layout.fillWidth: true
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
        property int alignment: Text.AlignHCenter

        signal clicked

        implicitWidth: actionLabel.implicitWidth + Appearance.padding.normal * 2
        implicitHeight: actionLabel.implicitHeight + Appearance.padding.small * 2
        radius: 0
        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 4)

        StateLayer {
            id: actionStateLayer

            function onClicked(): void {
                action.clicked();
            }
        }

        StyledText {
            id: actionLabel

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Appearance.padding.normal
            anchors.rightMargin: Appearance.padding.normal
            text: action.text
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            wrapMode: Text.Wrap
            horizontalAlignment: action.alignment
        }
    }
}
