import "../services"
import qs.components
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    required property DesktopEntry modelData
    required property PersistentProperties visibilities

    readonly property bool selected: ListView.isCurrentItem
    readonly property string description: (modelData?.comment || modelData?.genericName || "").trim()

    implicitHeight: Config.launcher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.small

        function onClicked(): void {
            Apps.launch(root.modelData);
            root.visibilities.launcher = false;
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger
        anchors.margins: Appearance.padding.smaller

        IconImage {
            id: icon

            source: Quickshell.iconPath(root.modelData?.icon, "image-missing")
            implicitSize: parent.height * 0.7

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.right: indicators.left
            anchors.rightMargin: Appearance.spacing.normal
            anchors.verticalCenter: icon.verticalCenter

            implicitHeight: name.implicitHeight + (comment.visible ? comment.implicitHeight : 0)

            StyledText {
                id: name

                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.normal
                font.weight: root.selected ? 600 : 400
                width: parent.width
                elide: Text.ElideRight
            }

            StyledText {
                id: comment

                text: root.description
                visible: text.length > 0 && text.toLowerCase() !== name.text.trim().toLowerCase()
                font.pointSize: Appearance.font.size.small
                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, root.selected ? 0.9 : 0.65)

                elide: Text.ElideRight
                width: parent.width

                anchors.top: name.bottom
            }
        }

        Row {
            id: indicators

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            spacing: Appearance.spacing.small

            Loader {
                anchors.verticalCenter: parent.verticalCenter
                active: root.modelData && Strings.testRegexList(Config.launcher.favouriteApps, root.modelData.id)

                sourceComponent: MaterialIcon {
                    text: "favorite"
                    fill: 0
                    font.pointSize: Appearance.font.size.small
                    color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.5)
                }
            }

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: "keyboard_return"
                font.pointSize: Appearance.font.size.normal
                color: Colours.palette.m3primary
                opacity: root.selected ? 1 : 0
            }
        }
    }
}
