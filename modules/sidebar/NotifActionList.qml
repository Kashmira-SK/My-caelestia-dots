pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Flow {
    id: root

    required property var notif
    property bool copied

    Layout.fillWidth: true
    spacing: Appearance.spacing.small

    Repeater {
        model: root.notif.actions

        ActionButton {
            required property var modelData

            text: modelData.text
            onClicked: {
                if (modelData.invoke)
                    modelData.invoke();
                else if (!root.notif.resident)
                    root.notif.close();
            }
        }
    }

    ActionButton {
        text: qsTr("Dismiss")
        onClicked: root.notif.close()
    }

    ActionButton {
        text: root.copied ? qsTr("Copied") : qsTr("Copy")
        onClicked: {
            Quickshell.clipboardText = root.notif.body;
            root.copied = true;
            copyTimer.restart();
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

        signal clicked

        width: Math.min(implicitWidth, root.width)
        implicitWidth: labelMetrics.width + Appearance.padding.small * 2
        implicitHeight: actionLabel.implicitHeight + Appearance.padding.small * 2
        radius: 0
        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 4)

        TextMetrics {
            id: labelMetrics

            font: actionLabel.font
            text: action.text
        }

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
            anchors.leftMargin: Appearance.padding.small
            anchors.rightMargin: Appearance.padding.small
            text: action.text
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
