pragma ComponentBehavior: Bound

import "../controlcenter"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.config
import QtQuick
import QtQuick.Layouts

StyledFlickable {
    id: root

    property var tabs: []
    property string activeTab: ""
    property bool isSaving: false

    signal tabSelected(string tabId)

    flickableDirection: Flickable.VerticalFlick
    contentHeight: navigationColumn.implicitHeight

    StyledScrollBar.vertical: StyledScrollBar {
        flickable: root
    }

    ColumnLayout {
        id: navigationColumn

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Appearance.spacing.small

        RowLayout {
            id: navigationHeaderRow

            Layout.fillWidth: true
            spacing: Appearance.spacing.smaller

            StyledText {
                id: navigationTitle

                text: qsTr("Cheatsheet")
                font.pointSize: Appearance.font.size.large
                font.weight: 500
                color: Colours.palette.m3onSurface
            }

            Item {
                Layout.fillWidth: true
            }

            IconButton {
                id: saveStatusIcon

                icon: root.isSaving ? "sync" : "menu_book"
                type: IconButton.Text
                label.animate: true
                enabled: false
            }
        }

        StyledText {
            id: navigationSubtitle

            Layout.fillWidth: true
            Layout.bottomMargin: Appearance.spacing.small

            text: qsTr("Quick notes, commands, repos and binds")
            wrapMode: Text.WordWrap
            font.pointSize: Appearance.font.size.small
            color: Colours.palette.m3onSurfaceVariant
        }

        Repeater {
            id: tabRepeater

            model: root.tabs

            NavigationEntry {
                required property var modelData
                required property int index

                Layout.fillWidth: true

                label: modelData.label
                tabId: modelData.id
                active: root.activeTab === modelData.id

                onClicked: {
                    root.tabSelected(modelData.id)
                }
            }
        }
    }

    component NavigationEntry: Item {
        id: navigationEntry

        property string label: ""
        property string tabId: ""
        property bool active: false

        signal clicked()

        implicitHeight: entryBackground.implicitHeight

        StyledRect {
            id: entryBackground

            anchors.left: parent.left
            anchors.right: parent.right

            radius: Appearance.rounding.full
            color: navigationEntry.active ? Colours.palette.m3secondaryContainer : "transparent"
            implicitHeight: entryLabel.implicitHeight + Appearance.padding.normal * 2

            StateLayer {
                id: entryStateLayer

                color: navigationEntry.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface

                function onClicked(): void {
                    navigationEntry.clicked()
                }
            }

            StyledText {
                id: entryLabel

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Appearance.padding.normal

                text: navigationEntry.label
                font.pointSize: Appearance.font.size.small
                font.capitalization: Font.Capitalize
                color: navigationEntry.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            }

            Behavior on color {
                Anim {}
            }
        }
    }
}
