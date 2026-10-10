pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Item {
    id: root

    property bool singlePane: false
    property bool showRightPane: false
    property bool showBackButton: showRightPane
    signal backRequested

    property Component leftContent: null
    property Component rightContent: null

    property real leftWidthRatio: 0.4
    property int leftMinimumWidth: 420
    property var leftLoaderProperties: ({})
    property var rightLoaderProperties: ({})

    property alias leftLoader: leftLoader
    property alias rightLoader: rightLoader

    Item {
        id: leftPane
        visible: !root.singlePane || !root.showRightPane
        width: root.singlePane ? root.width : Math.max(root.leftMinimumWidth, Math.floor(root.width * root.leftWidthRatio))
        height: root.height

        Loader {
            id: leftLoader

            clip: true
            anchors.fill: parent
            anchors.leftMargin: root.singlePane ? 28 : Appearance.padding.large
            anchors.rightMargin: root.singlePane ? 28 : Appearance.padding.large
            anchors.topMargin: root.singlePane ? 25 : Appearance.padding.normal
            anchors.bottomMargin: root.singlePane ? 25 : Appearance.padding.large

            sourceComponent: root.leftContent

            Component.onCompleted: {
                for (const key in root.leftLoaderProperties)
                    leftLoader[key] = root.leftLoaderProperties[key];
            }
        }
    }

    Item {
        visible: !root.singlePane
        x: leftPane.width
        width: Appearance.spacing.large + 1
        height: root.height

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: root.singlePane ? 25 : Appearance.padding.normal
            anchors.bottomMargin: root.singlePane ? 25 : Appearance.padding.large

            width: 1
            color: Colours.palette.m3outlineVariant
            opacity: 0.18
        }
    }

    Item {
        id: rightPane
        visible: !root.singlePane || root.showRightPane
        Controls.AbstractButton {
            id: back
            visible: root.singlePane && root.showBackButton
            x: 28; y: 18
            implicitWidth: backText.implicitWidth + 20
            implicitHeight: 32
            Accessible.name: qsTr("Back to list")
            onClicked: root.backRequested()
            background: Rectangle { radius: 6; color: Qt.alpha(Colours.palette.m3primary, back.hovered ? 0.12 : 0.05); border.width: back.activeFocus ? 1 : 0; border.color: Colours.palette.m3primary }
            contentItem: StyledText { id: backText; text: qsTr("‹  Back to list"); font.pointSize: 9.75 * Appearance.font.size.scale; color: Colours.palette.m3primary; verticalAlignment: Text.AlignVCenter }
            leftPadding: 10
        }

        x: root.singlePane ? 0 : leftPane.width + Appearance.spacing.large + 1
        width: root.width - x
        height: root.height

        Loader {
            id: rightLoader

            clip: true
            anchors.fill: parent
            anchors.leftMargin: root.singlePane ? 28 : Appearance.padding.large
            anchors.rightMargin: root.singlePane ? 28 : Appearance.padding.large
            anchors.topMargin: root.singlePane ? (root.showBackButton ? 64 : 25) : Appearance.padding.normal
            anchors.bottomMargin: root.singlePane ? 25 : Appearance.padding.large

            sourceComponent: root.rightContent

            Component.onCompleted: {
                for (const key in root.rightLoaderProperties)
                    rightLoader[key] = root.rightLoaderProperties[key];
            }
        }
    }
}
