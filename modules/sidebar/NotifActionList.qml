pragma ComponentBehavior: Bound

import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property var notif
    property bool copied

    spacing: Appearance.spacing.small

    NotifToolButton {
        visible: root.notif.actions.length > 0
        icon: "ellipsis"
        text: qsTr("Notification actions")
        selected: actionMenu.opened
        onClicked: actionMenu.opened ? actionMenu.close() : actionMenu.open()
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

    NotifMenu {
        id: actionMenu

        y: root.height + Appearance.spacing.small
        width: root.width
        items: root.notif.actions
        onChosen: index => {
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
