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

    readonly property bool hasImage: modelData.image.length > 0
    readonly property bool hasAppIcon: modelData.appIcon.length > 0
    readonly property int iconSize: Math.round(Config.notifs.sizes.image * 0.5)
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

            Item {
                Layout.alignment: Qt.AlignVCenter
                visible: root.hasImage || root.hasAppIcon
                implicitWidth: root.iconSize
                implicitHeight: root.iconSize

                Component {
                    id: imageComp

                    Image {
                        source: Qt.resolvedUrl(root.modelData.image)
                        fillMode: Image.PreserveAspectCrop
                        cache: false
                        asynchronous: true
                        width: root.iconSize
                        height: root.iconSize
                    }
                }

                Component {
                    id: appIconComp

                    ColouredIcon {
                        implicitSize: root.iconSize
                        source: Quickshell.iconPath(root.modelData.appIcon)
                        colour: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3onSurface : Colours.palette.m3onSecondaryContainer
                        layer.enabled: root.modelData.appIcon.endsWith("symbolic")
                    }
                }

                Loader {
                    anchors.centerIn: parent
                    active: root.hasImage || root.hasAppIcon
                    sourceComponent: root.hasImage ? imageComp : appIconComp
                }
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
