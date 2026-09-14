pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.utils
import qs.config
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    clip: true

    required property ShellScreen screen
    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    readonly property string activeSpecial: (Config.bar.workspaces.perMonitorWorkspaces ? monitor : Hypr.focusedMonitor)?.lastIpcObject?.specialWorkspace?.name ?? ""

    ListView {
        id: view

        anchors.fill: parent
        clip: true
        spacing: Appearance.spacing.normal
        interactive: false

        currentIndex: model.values.findIndex(w => w.name === root.activeSpecial)
        onCurrentIndexChanged: currentIndex = Qt.binding(() => model.values.findIndex(w => w.name === root.activeSpecial))

        model: ScriptModel {
            values: Hypr.workspaces.values.filter(w => w.name.startsWith("special:") && (!Config.bar.workspaces.perMonitorWorkspaces || w.monitor === root.monitor))
        }

        preferredHighlightBegin: 0
        preferredHighlightEnd: height
        highlightRangeMode: ListView.StrictlyEnforceRange

        highlightFollowsCurrentItem: false
        highlight: Item {
            y: view.currentItem?.y ?? 0
            implicitHeight: view.currentItem?.size ?? 0

            Behavior on y {
                Anim {}
            }
        }

        delegate: ColumnLayout {
            id: ws

            required property HyprlandWorkspace modelData
            readonly property int size: label.Layout.preferredHeight + (hasWindows ? windows.implicitHeight + Appearance.padding.small : 0)
            property int wsId
            property bool hasWindows

            anchors.left: view.contentItem.left
            anchors.right: view.contentItem.right

            spacing: 0

            Component.onCompleted: {
                wsId = modelData.id;
                hasWindows = Config.bar.workspaces.showWindowsOnSpecialWorkspaces && modelData.lastIpcObject.windows > 0;
            }

            // Hacky thing cause modelData gets destroyed before the remove anim finishes
            Connections {
                target: ws.modelData

                function onIdChanged(): void {
                    if (ws.modelData)
                        ws.wsId = ws.modelData.id;
                }

                function onLastIpcObjectChanged(): void {
                    if (ws.modelData)
                        ws.hasWindows = Config.bar.workspaces.showWindowsOnSpecialWorkspaces && ws.modelData.lastIpcObject.windows > 0;
                }
            }

            Connections {
                target: Config.bar.workspaces

                function onShowWindowsOnSpecialWorkspacesChanged(): void {
                    if (ws.modelData)
                        ws.hasWindows = Config.bar.workspaces.showWindowsOnSpecialWorkspaces && ws.modelData.lastIpcObject.windows > 0;
                }
            }

            Item {
                id: label
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.preferredWidth: Config.bar.sizes.innerWidth - Appearance.padding.small * 2
                Layout.preferredHeight: Layout.preferredWidth
                readonly property bool selected: ws.modelData?.name === root.activeSpecial
                readonly property string glyph: {
                    const name = ws.modelData?.name ?? "";
                    if (name === "special:term") return "monitor";
                    if (name === "special:magic") return "orbit";
                    if (name === "special:scratch1") return "moon";
                    if (name === "special:scratch2") return "globe";
                    return "orbit";
                }

                StyledRect {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    radius: 4
                    rotation: 45
                    border.width: label.selected ? 1 : 0
                    border.color: Colours.palette.m3tertiary
                }

                ColouredIcon {
                    anchors.centerIn: parent
                    implicitSize: 14
                    source: Qt.resolvedUrl("../../../../assets/icons/lucide/" + label.glyph + ".svg")
                    colour: label.selected ? Colours.palette.m3tertiary : Colours.palette.m3onSurfaceVariant
                }
            }

            Loader {
                id: windows

                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.preferredHeight: implicitHeight

                visible: active
                active: ws.hasWindows

                sourceComponent: Column {
                    spacing: 0

                    add: Transition {
                        Anim {
                            properties: "scale"
                            from: 0
                            to: 1
                            easing.bezierCurve: Appearance.anim.curves.standardDecel
                        }
                    }

                    move: Transition {
                        Anim {
                            properties: "scale"
                            to: 1
                            easing.bezierCurve: Appearance.anim.curves.standardDecel
                        }
                        Anim {
                            properties: "x,y"
                        }
                    }

                    Repeater {
                        model: ScriptModel {
                            values: Hypr.toplevels.values.filter(c => c.workspace?.id === ws.wsId)
                        }

                        MaterialIcon {
                            required property var modelData

                            grade: 0
                            text: Icons.getAppCategoryIcon(modelData.lastIpcObject.class, "terminal")
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }

                Behavior on Layout.preferredHeight {
                    Anim {}
                }
            }
        }

        add: Transition {
            Anim {
                properties: "scale"
                from: 0
                to: 1
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
        }

        remove: Transition {
            Anim {
                property: "scale"
                to: 0.5
                duration: Appearance.anim.durations.small
            }
            Anim {
                property: "opacity"
                to: 0
                duration: Appearance.anim.durations.small
            }
        }

        move: Transition {
            Anim {
                properties: "scale"
                to: 1
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
            Anim {
                properties: "x,y"
            }
        }

        displaced: Transition {
            Anim {
                properties: "scale"
                to: 1
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
            Anim {
                properties: "x,y"
            }
        }
    }

    StyledRect {
        visible: Config.bar.workspaces.activeIndicator && view.currentItem !== null
        width: 2
        height: 16
        radius: 1
        x: 0
        y: (view.currentItem?.y ?? 0) - view.contentY + (Config.bar.sizes.innerWidth - Appearance.padding.small * 2 - height) / 2
        color: Colours.palette.m3tertiary
        Behavior on y {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        property real startY

        anchors.fill: view

        drag.target: view.contentItem
        drag.axis: Drag.YAxis
        drag.maximumY: 0
        drag.minimumY: Math.min(0, view.height - view.contentHeight - Appearance.padding.small)

        onPressed: event => startY = event.y

        onClicked: event => {
            if (Math.abs(event.y - startY) > drag.threshold)
                return;

            const ws = view.itemAt(event.x + view.contentX, event.y + view.contentY);
            if (ws?.modelData)
                Hypr.dispatch(`togglespecialworkspace ${ws.modelData.name.slice(8)}`);

        }
    }
}
