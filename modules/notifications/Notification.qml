pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.config
import qs.modules.sidebar as Sidebar
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property Notifs.Notif modelData
    readonly property bool hasImage: modelData.image.length > 0
    readonly property bool hasAppIcon: modelData.appIcon.length > 0
    readonly property real nonAnimHeight: inner.implicitHeight + Appearance.padding.normal * 2
    readonly property color ink: modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3error : Colours.palette.m3primary
    property bool expanded: Config.notifs.openExpanded

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.small
    border.width: 1
    border.color: root.modelData.urgency === NotificationUrgency.Critical ? root.ink : Colours.palette.m3outlineVariant
    clip: true
    implicitWidth: Config.notifs.sizes.width
    implicitHeight: nonAnimHeight

    Behavior on implicitHeight {
        Anim {
            duration: Appearance.anim.durations.expressiveDefaultSpatial
        }
    }

    x: Config.notifs.sizes.width
    Component.onCompleted: {
        x = 0;
        modelData.lock(this);
    }
    Component.onDestruction: modelData.unlock(this)

    Behavior on x {
        Anim {
            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
        }
    }

    MouseArea {
        property int startY

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.expanded && body.hoveredLink ? Qt.PointingHandCursor : pressed ? Qt.ClosedHandCursor : undefined
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        preventStealing: true

        onEntered: root.modelData.timer.stop()
        onExited: {
            if (!pressed)
                root.modelData.timer.start();
        }

        drag.target: parent
        drag.axis: Drag.XAxis

        onPressed: event => {
            root.modelData.timer.stop();
            startY = event.y;
            if (event.button === Qt.MiddleButton)
                root.modelData.close();
        }
        onReleased: event => {
            if (!containsMouse)
                root.modelData.timer.start();

            if (Math.abs(root.x) < Config.notifs.sizes.width * Config.notifs.clearThreshold)
                root.x = 0;
            else
                root.modelData.popup = false;
        }
        onPositionChanged: event => {
            if (pressed) {
                const diffY = event.y - startY;
                if (Math.abs(diffY) > Config.notifs.expandThreshold)
                    root.expanded = diffY > 0;
            }
        }
        onClicked: event => {
            if (!Config.notifs.actionOnClick || event.button !== Qt.LeftButton)
                return;

            const actions = root.modelData.actions;
            if (actions?.length === 1)
                actions[0].invoke();
        }

        ColumnLayout {
            id: inner

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                ColouredIcon {
                    implicitSize: 16
                    source: root.hasAppIcon ? Quickshell.iconPath(root.modelData.appIcon) : Qt.resolvedUrl("../../assets/icons/lucide/bell.svg")
                    colour: root.ink
                    layer.enabled: !root.hasAppIcon || root.modelData.appIcon.endsWith("symbolic")
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.modelData.appName || qsTr("Notification")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    text: root.modelData.timeStr
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                    font.family: Appearance.font.family.mono
                }

                Sidebar.NotifToolButton {
                    icon: "chevron-down"
                    iconRotation: root.expanded ? 180 : 0
                    text: root.expanded ? qsTr("Collapse notification") : qsTr("Expand notification")
                    onClicked: root.expanded = !root.expanded
                }

                Sidebar.NotifToolButton {
                    icon: "x"
                    text: qsTr("Dismiss notification")
                    onClicked: root.modelData.close()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                ClippingRectangle {
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: Config.notifs.sizes.image
                    Layout.preferredHeight: Config.notifs.sizes.image
                    visible: root.hasImage
                    radius: Appearance.rounding.small
                    color: "transparent"

                    Image {
                        anchors.fill: parent
                        source: root.hasImage ? Qt.resolvedUrl(root.modelData.image) : ""
                        fillMode: Image.PreserveAspectCrop
                        cache: false
                        asynchronous: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.smaller

                    StyledText {
                        Layout.fillWidth: true
                        text: root.modelData.summary
                        textFormat: Text.PlainText
                        color: Colours.palette.m3onSurface
                        font.weight: Font.Medium
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: root.expanded ? Number.MAX_SAFE_INTEGER : 1
                        elide: Text.ElideRight
                    }

                    StyledText {
                        id: body

                        Layout.fillWidth: true
                        visible: text.length > 0
                        text: root.modelData.body
                        textFormat: Text.MarkdownText
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: root.expanded ? Number.MAX_SAFE_INTEGER : 1
                        elide: Text.ElideRight

                        onLinkActivated: link => {
                            if (!root.expanded)
                                return;
                            Quickshell.execDetached(["app2unit", "-O", "--", link]);
                            root.modelData.popup = false;
                        }
                    }
                }
            }

            Flow {
                id: actions

                Layout.fillWidth: true
                visible: root.expanded && root.modelData.actions.length > 0
                spacing: Appearance.spacing.small

                Repeater {
                    model: root.modelData.actions

                    delegate: StyledRect {
                        id: action

                        required property var modelData

                        width: Math.min(actions.width, actionText.implicitWidth + Appearance.padding.normal * 2)
                        height: actionText.implicitHeight + Appearance.padding.small * 2
                        radius: Appearance.rounding.small / 2
                        color: "transparent"
                        border.width: 1
                        border.color: Colours.palette.m3outlineVariant

                        StateLayer {
                            radius: action.radius
                            color: root.ink
                            function onClicked(): void {
                                action.modelData.invoke();
                            }
                        }

                        StyledText {
                            id: actionText

                            anchors.centerIn: parent
                            width: Math.max(0, parent.width - Appearance.padding.normal * 2)
                            text: action.modelData.text
                            textFormat: Text.PlainText
                            color: root.ink
                            font.pointSize: Appearance.font.size.small
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                    }
                }
            }
        }
    }
}
