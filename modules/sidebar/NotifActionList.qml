pragma ComponentBehavior: Bound

import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var notif
    property bool copied
    property bool optionsExpanded

    spacing: Appearance.spacing.small
    Keys.onEscapePressed: optionsExpanded = false

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        NotifToolButton {
            visible: root.notif.actions.length > 0
            icon: "ellipsis"
            text: root.optionsExpanded ? qsTr("Hide notification actions") : qsTr("Notification actions")
            selected: root.optionsExpanded
            onClicked: root.optionsExpanded = !root.optionsExpanded
        }

        Item {
            Layout.fillWidth: true
        }

        NotifToolButton {
            icon: root.copied ? "check" : "copy"
            text: root.copied ? qsTr("Copied") : qsTr("Copy notification")
            onClicked: {
                Quickshell.clipboardText = root.notif.body;
                root.copied = true;
                copyTimer.restart();
            }
        }

        NotifToolButton {
            icon: "x"
            text: qsTr("Dismiss notification")
            onClicked: root.notif.close()
        }
    }

    NotifMenu {
        Layout.fillWidth: true
        expanded: root.optionsExpanded
        items: root.notif.actions
        onChosen: index => {
            root.optionsExpanded = false;
            const action = root.notif.actions[index];
            if (action.invoke)
                action.invoke();
            else if (!root.notif.resident)
                root.notif.close();
        }
    }

    Timer {
        id: copyTimer

        interval: 3000
        onTriggered: root.copied = false
    }
}
