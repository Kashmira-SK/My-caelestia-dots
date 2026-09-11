pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property Props props
    required property Flickable container
    required property var visibilities

    readonly property alias repeater: repeater
    readonly property int spacing: Appearance.spacing.small
    property bool flag

    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: {
        const item = repeater.itemAt(repeater.count - 1);
        return item ? item.y + item.implicitHeight : 0;
    }

    Repeater {
        id: repeater

        model: ScriptModel {
            values: [...Notifs.list]
            onValuesChanged: root.flagChanged()
        }

        MouseArea {
            id: notif

            required property int index
            required property Notifs.Notif modelData

            readonly property bool closed: modelData.closed
            readonly property alias nonAnimHeight: notifCard.nonAnimHeight
            property bool expanded: Config.notifs.openExpanded
            property int startY

            function closeAll(): void {
                modelData.close();
            }

            y: {
                root.flag;
                let y = 0;
                for (let i = 0; i < index; i++) {
                    const item = repeater.itemAt(i);
                    if (!item.closed)
                        y += item.nonAnimHeight + root.spacing;
                }
                return y;
            }

            containmentMask: QtObject {
                function contains(p: point): bool {
                    if (!root.container.contains(notif.mapToItem(root.container, p)))
                        return false;
                    return notifCard.contains(p);
                }
            }

            implicitWidth: root.width
            implicitHeight: notifCard.implicitHeight

            hoverEnabled: true
            cursorShape: notifCard.body?.hoveredLink ? Qt.PointingHandCursor : pressed ? Qt.ClosedHandCursor : undefined
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            preventStealing: true
            enabled: !closed

            drag.target: this
            drag.axis: Drag.XAxis

            onPressed: event => {
                startY = event.y;
                if (event.button === Qt.RightButton)
                    expanded = !expanded;
                else if (event.button === Qt.MiddleButton)
                    modelData.close();
            }
            onPositionChanged: event => {
                if (pressed) {
                    const diffY = event.y - startY;
                    if (Math.abs(diffY) > Config.notifs.expandThreshold)
                        expanded = diffY > 0;
                }
            }
            onReleased: {
                if (Math.abs(x) < width * Config.notifs.clearThreshold)
                    x = 0;
                else
                    modelData.close();
            }

            Component.onCompleted: modelData.lock(this)
            Component.onDestruction: modelData.unlock(this)

            ParallelAnimation {
                running: true

                Anim {
                    target: notif
                    property: "opacity"
                    from: 0
                    to: 1
                }
                Anim {
                    target: notif
                    property: "scale"
                    from: 0.7
                    to: 1
                }
            }

            ParallelAnimation {
                running: notif.closed
                onFinished: notif.modelData.unlock(notif)

                Anim {
                    target: notif
                    property: "opacity"
                    to: 0
                }
                Anim {
                    target: notif
                    property: "x"
                    to: notif.x >= 0 ? notif.width : -notif.width
                }
            }

            Notif {
                id: notifCard

                anchors.fill: parent
                modelData: notif.modelData
                expanded: notif.expanded
                visibilities: root.visibilities
                onRequestToggleExpand: notif.expanded = !notif.expanded
            }

            Behavior on x {
                Anim {
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }

            Behavior on y {
                Anim {
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }
        }
    }
}
