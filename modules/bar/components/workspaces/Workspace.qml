import qs.components
import qs.services
import qs.utils
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property int index
    required property int activeWsId
    required property var occupied
    required property int groupOffset

    readonly property bool isWorkspace: true // Flag for finding workspace children
    // Unanimated prop for others to use as reference
    readonly property int size: implicitHeight + (hasWindows ? Appearance.padding.small : 0)

    readonly property int ws: groupOffset + index + 1
    readonly property bool isOccupied: occupied[ws] ?? false
    readonly property bool hasWindows: isOccupied && Config.bar.workspaces.showWindows

    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: Config.bar.sizes.innerWidth
    Layout.preferredHeight: size

    spacing: 0

    Item {
        id: indicator
        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.preferredWidth: Config.bar.sizes.innerWidth
        Layout.preferredHeight: Config.bar.sizes.innerWidth - Appearance.padding.small * 2

        readonly property bool selected: root.activeWsId === root.ws
        readonly property color ink: selected ? Colours.palette.m3primary : root.isOccupied ? Colours.palette.m3onSurface : Colours.layer(Colours.palette.m3outlineVariant, 2)

        // Hollow idle point, solid occupied point, orbit around the active point.
        Rectangle {
            anchors.centerIn: parent
            width: indicator.selected ? 16 : 8
            height: width
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: indicator.ink

            Rectangle {
                anchors.centerIn: parent
                width: indicator.selected ? 6 : 4
                height: width
                radius: width / 2
                visible: root.isOccupied || indicator.selected
                color: indicator.ink
            }
        }
    }

    Loader {
        id: windows

        Layout.alignment: Qt.AlignHCenter
        Layout.fillHeight: true
        Layout.topMargin: -Config.bar.sizes.innerWidth / 10

        visible: active
        active: root.hasWindows

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
                    values: Hypr.toplevels.values.filter(c => c.workspace?.id === root.ws)
                }

                MaterialIcon {
                    required property var modelData

                    grade: 0
                    text: Icons.getAppCategoryIcon(modelData.lastIpcObject.class, "terminal")
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }

    Behavior on Layout.preferredHeight {
        Anim {}
    }
}
