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

    StyledText {
        id: indicator

        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.preferredHeight: Config.bar.sizes.innerWidth - Appearance.padding.small * 2

        animate: false
        font.family: Appearance.font.family.mono
        font.pointSize: Appearance.font.size.small
        text: {
            const ws = Hypr.workspaces.values.find(w => w.id === root.ws);
            const wsName = !ws || ws.name == root.ws ? String(root.ws).padStart(2, "0") : ws.name[0];
            let displayName = wsName.toString();
            if (Config.bar.workspaces.capitalisation.toLowerCase() === "upper") {
                displayName = displayName.toUpperCase();
            } else if (Config.bar.workspaces.capitalisation.toLowerCase() === "lower") {
                displayName = displayName.toLowerCase();
            }
            // Retire the stock dot/Pacman labels; retain explicitly customized labels.
            const configured = Config.bar.workspaces;
            const label = configured.label.trim() === "" ? displayName : configured.label || displayName;
            const occupiedLabel = configured.occupiedLabel === "󰮯" ? label : configured.occupiedLabel || label;
            const activeLabel = configured.activeLabel === "󰮯" ? label : configured.activeLabel || (root.isOccupied ? occupiedLabel : label);
            return root.activeWsId === root.ws ? activeLabel : root.isOccupied ? occupiedLabel : label;
        }
        color: root.activeWsId === root.ws ? Colours.palette.m3primary : root.isOccupied ? Colours.palette.m3onSurface : Colours.layer(Colours.palette.m3outlineVariant, 2)
        verticalAlignment: Qt.AlignVCenter

        Rectangle {
            anchors.left: parent.right
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            visible: root.isOccupied
            width: 3
            height: 3
            radius: 1.5
            color: indicator.color
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
