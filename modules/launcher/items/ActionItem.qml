import "../services"
import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    required property var modelData
    required property var list

    readonly property bool selected: ListView.isCurrentItem

    implicitHeight: Config.launcher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.normal

        function onClicked(): void {
            root.modelData?.onClicked(root.list);
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger
        anchors.margins: Appearance.padding.smaller

        MaterialIcon {
            id: icon

            text: root.modelData?.icon ?? ""
            font.pointSize: Appearance.font.size.extraLarge

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.right: enterIcon.left
            anchors.rightMargin: Appearance.spacing.normal
            anchors.verticalCenter: icon.verticalCenter

            implicitHeight: name.implicitHeight + (desc.visible ? desc.implicitHeight : 0)

            StyledText {
                id: name

                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.normal
                font.weight: root.selected ? 600 : 400
                width: parent.width
                elide: Text.ElideRight
            }

            StyledText {
                id: desc

                text: root.modelData?.desc ?? ""
                visible: text.length > 0
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3outline

                elide: Text.ElideRight
                width: parent.width

                anchors.top: name.bottom
            }
        }

        MaterialIcon {
            id: enterIcon

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "keyboard_return"
            font.pointSize: Appearance.font.size.normal
            color: Colours.palette.m3primary
            opacity: root.selected ? 1 : 0
        }
    }
}
