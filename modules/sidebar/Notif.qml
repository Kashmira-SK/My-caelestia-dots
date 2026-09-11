pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.config
import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property Notifs.Notif modelData
    required property bool expanded
    required property var visibilities

    // Use consistent outline categories, including notifications relayed by a
    // browser or KDE Connect. Sender images must not override these glyphs.
    readonly property string senderIcon: {
        const sender = (modelData.appName + " " + modelData.appIcon + " " + modelData.summary).toLowerCase();
        if (/whatsapp|telegram|signal|discord|message|chat/.test(sender))
            return "message-circle";
        if (/network|wi-fi|wifi|connection/.test(sender))
            return "wifi";
        if (/kde.?connect|phone/.test(sender))
            return "smartphone";
        if (/firefox|chromium|chrome|browser/.test(sender))
            return "globe";
        return "bell";
    }
    readonly property StyledText body: bodyText
    readonly property real nonAnimHeight: content.implicitHeight + Appearance.padding.normal * 2

    signal requestToggleExpand

    implicitHeight: nonAnimHeight

    clip: true
    radius: Appearance.rounding.small
    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.padding.normal
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            ColouredIcon {
                Layout.alignment: Qt.AlignVCenter
                implicitSize: 16
                source: Qt.resolvedUrl("../../assets/icons/lucide/" + root.senderIcon + ".svg")
                colour: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3onSurface : Colours.palette.m3onSecondaryContainer
            }

            StyledText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: root.modelData.appName
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                font.weight: 500
                elide: Text.ElideRight
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                animate: true
                text: root.modelData.timeStr
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
                font.family: Appearance.font.family.mono
            }

            NotifToolButton {
                Layout.alignment: Qt.AlignVCenter
                icon: "chevron-down"
                iconRotation: root.expanded ? 180 : 0
                text: root.expanded ? qsTr("Collapse notification") : qsTr("Expand notification")
                foreground: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : Colours.palette.m3onSurface
                onClicked: root.requestToggleExpand()
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: root.modelData.summary
            color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.normal
            font.weight: 500
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: root.expanded ? Number.MAX_SAFE_INTEGER : 1
        }

        StyledText {
            id: bodyText

            Layout.fillWidth: true
            visible: text.length > 0
            textFormat: Text.MarkdownText
            text: root.modelData.body.replace(/(.)\n(?!\n)/g, "$1\n\n")
            color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3secondary : Colours.palette.m3outline
            font.pointSize: Appearance.font.size.small
            wrapMode: Text.WordWrap
            maximumLineCount: root.expanded ? Number.MAX_SAFE_INTEGER : 1
            elide: root.expanded ? Text.ElideNone : Text.ElideRight

            onLinkActivated: link => {
                Quickshell.execDetached(["app2unit", "-O", "--", link]);
                root.visibilities.sidebar = false;
            }
        }

        Loader {
            Layout.fillWidth: true
            Layout.preferredHeight: root.expanded ? implicitHeight : 0
            visible: root.expanded
            active: root.expanded

            sourceComponent: NotifActionList {
                notif: root.modelData
            }
        }
    }

    Behavior on implicitHeight {
        Anim {
            duration: Appearance.anim.durations.expressiveDefaultSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
        }
    }
}
