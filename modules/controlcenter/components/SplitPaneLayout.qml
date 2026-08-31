pragma ComponentBehavior: Bound

import qs.components
import qs.config
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    spacing: 0

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

        Layout.preferredWidth: Math.floor(parent.width * root.leftWidthRatio)
        Layout.minimumWidth: root.leftMinimumWidth
        Layout.fillHeight: true

        Loader {
            id: leftLoader

            anchors.fill: parent
            anchors.leftMargin: Appearance.padding.large
            anchors.rightMargin: Appearance.padding.large
            anchors.topMargin: Appearance.padding.normal
            anchors.bottomMargin: Appearance.padding.large

            sourceComponent: root.leftContent

            Component.onCompleted: {
                for (const key in root.leftLoaderProperties)
                    leftLoader[key] = root.leftLoaderProperties[key];
            }
        }
    }

    Item {
        Layout.preferredWidth: Appearance.spacing.large + 1
        Layout.fillHeight: true

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: Appearance.padding.normal
            anchors.bottomMargin: Appearance.padding.large

            width: 1
            color: Colours.palette.m3outlineVariant
            opacity: 0.18
        }
    }

    Item {
        id: rightPane

        Layout.fillWidth: true
        Layout.fillHeight: true

        Loader {
            id: rightLoader

            anchors.fill: parent
            anchors.leftMargin: Appearance.padding.large
            anchors.rightMargin: Appearance.padding.large
            anchors.topMargin: Appearance.padding.normal
            anchors.bottomMargin: Appearance.padding.large

            sourceComponent: root.rightContent

            Component.onCompleted: {
                for (const key in root.rightLoaderProperties)
                    rightLoader[key] = root.rightLoaderProperties[key];
            }
        }
    }
}
