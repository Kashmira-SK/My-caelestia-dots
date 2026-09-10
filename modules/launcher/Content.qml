pragma ComponentBehavior: Bound

import "services"
import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    required property var panels
    required property real maxHeight

    readonly property int padding: Appearance.padding.large
    readonly property int rounding: Appearance.rounding.normal
    readonly property real headerHeight: frameLabel.implicitHeight + Appearance.spacing.small

    implicitWidth: listWrapper.width + padding * 2
    implicitHeight: searchWrapper.height + listWrapper.height + footer.implicitHeight + padding * 4 + headerHeight

    StyledRect {
        anchors.fill: parent
        radius: root.rounding
        color: Qt.alpha(Colours.palette.m3surface, Colours.transparency.enabled ? Colours.transparency.base : 1)
        border.width: 1
        border.color: Qt.alpha(Colours.palette.m3outline, 0.65)
    }

    Row {
        id: frameLabel

        x: root.padding
        y: root.padding
        spacing: Appearance.spacing.small

        StyledRect {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: Appearance.spacing.large
            implicitHeight: 1
            color: Qt.alpha(Colours.palette.m3outline, 0.65)
        }

        StyledText {
            text: qsTr("LAUNCHER")
            color: Colours.palette.m3onSurfaceVariant
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.small
            font.weight: 600
            font.letterSpacing: 2
        }

        StyledRect {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: Appearance.spacing.large
            implicitHeight: 1
            color: Qt.alpha(Colours.palette.m3outline, 0.65)
        }
    }

    Item {
        id: listWrapper

        implicitWidth: list.width
        implicitHeight: list.height

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: searchWrapper.bottom
        anchors.topMargin: root.padding

        ContentList {
            id: list

            visibilities: root.visibilities
            maxHeight: Math.max(0, root.maxHeight - searchWrapper.implicitHeight - footer.implicitHeight - root.padding * 4 - root.headerHeight)
            search: search
        }
    }

    Item {
        id: searchWrapper

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.padding
        anchors.topMargin: root.padding + root.headerHeight

        implicitHeight: Math.max(searchIcon.implicitHeight, search.implicitHeight, clearIcon.implicitHeight)

        StyledRect {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: 1
            color: Qt.alpha(Colours.palette.m3outlineVariant, 0.6)
        }

        MaterialIcon {
            id: searchIcon

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.padding

            text: "search"
            color: Colours.palette.m3onSurfaceVariant
        }

        StyledTextField {
            id: search

            anchors.left: searchIcon.right
            anchors.right: clearIcon.left
            anchors.leftMargin: Appearance.spacing.small
            anchors.rightMargin: Appearance.spacing.small

            topPadding: Appearance.padding.larger
            bottomPadding: Appearance.padding.larger
            font.pointSize: Appearance.font.size.larger

            placeholderText: qsTr("Search applications…")

            onAccepted: {
                const currentItem = list.currentList?.currentItem;
                if (currentItem) {
                    if (text.startsWith(Config.launcher.actionPrefix)) {
                        if (text.startsWith(`${Config.launcher.actionPrefix}calc `))
                            currentItem.onClicked();
                        else
                            currentItem.modelData.onClicked(list.currentList);
                    } else {
                        Apps.launch(currentItem.modelData);
                        root.visibilities.launcher = false;
                    }
                }
            }

            Keys.onUpPressed: list.currentList?.decrementCurrentIndex()
            Keys.onDownPressed: list.currentList?.incrementCurrentIndex()

            Keys.onEscapePressed: root.visibilities.launcher = false

            Keys.onPressed: event => {
                if (!Config.launcher.vimKeybinds)
                    return;

                if (event.modifiers & Qt.ControlModifier) {
                    if (event.key === Qt.Key_J) {
                        list.currentList?.incrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_K) {
                        list.currentList?.decrementCurrentIndex();
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Tab) {
                    list.currentList?.incrementCurrentIndex();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                    list.currentList?.decrementCurrentIndex();
                    event.accepted = true;
                }
            }

            Component.onCompleted: forceActiveFocus()

            Connections {
                target: root.visibilities

                function onSessionChanged(): void {
                    if (!root.visibilities.session)
                        search.forceActiveFocus();
                }
            }
        }

        MaterialIcon {
            id: clearIcon

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: root.padding

            width: search.text ? implicitWidth : implicitWidth / 2
            opacity: {
                if (!search.text)
                    return 0;
                if (mouse.pressed)
                    return 0.7;
                if (mouse.containsMouse)
                    return 0.8;
                return 1;
            }

            text: "close"
            color: Colours.palette.m3onSurfaceVariant

            MouseArea {
                id: mouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: search.text ? Qt.PointingHandCursor : undefined

                onClicked: search.text = ""
            }

            Behavior on width {
                Anim {
                    duration: Appearance.anim.durations.small
                }
            }

            Behavior on opacity {
                Anim {
                    duration: Appearance.anim.durations.small
                }
            }
        }
    }

    Item {
        id: footer

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: listWrapper.bottom
        anchors.topMargin: root.padding
        anchors.leftMargin: root.padding * 2
        anchors.rightMargin: root.padding * 2
        implicitHeight: Math.max(commandHint.implicitHeight, navigationHint.implicitHeight)

        StyledText {
            id: commandHint

            text: qsTr("%1 commands").arg(Config.launcher.actionPrefix)
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.small
            color: Colours.palette.m3onSurfaceVariant
        }

        StyledText {
            id: navigationHint

            anchors.right: parent.right
            text: qsTr("↑↓ select   esc close")
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.small
            color: Colours.palette.m3outline
        }
    }
}
