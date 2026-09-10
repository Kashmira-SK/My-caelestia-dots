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
    readonly property real labelInset: Appearance.padding.small + frameLabel.implicitHeight / 2

    implicitWidth: listWrapper.width + padding * 2
    implicitHeight: searchWrapper.height + listWrapper.height + footer.implicitHeight + padding * 4 + labelInset

    StyledRect {
        anchors.fill: parent
        radius: root.rounding
        color: Qt.alpha(Colours.palette.m3surface, Colours.transparency.enabled ? Colours.transparency.base : 1)
    }

    Canvas {
        id: frame

        anchors.fill: parent
        anchors.margins: Appearance.padding.small
        anchors.topMargin: root.labelInset
        antialiasing: true

        property color outline: Qt.alpha(Colours.palette.m3outline, 0.65)
        property real rounding: Math.max(0, root.rounding - Appearance.padding.small)
        property real gapStart: frameLabel.x - x - Appearance.spacing.small
        property real gapEnd: gapStart + frameLabel.width + Appearance.spacing.small * 2

        onOutlineChanged: requestPaint()
        onRoundingChanged: requestPaint()
        onGapStartChanged: requestPaint()
        onGapEndChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const right = width - 0.5;
            const bottom = height - 0.5;
            const r = Math.min(rounding, width / 2, height / 2);
            ctx.strokeStyle = outline;
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(gapEnd, 0.5);
            ctx.lineTo(right - r, 0.5);
            ctx.quadraticCurveTo(right, 0.5, right, r);
            ctx.lineTo(right, bottom - r);
            ctx.quadraticCurveTo(right, bottom, right - r, bottom);
            ctx.lineTo(r, bottom);
            ctx.quadraticCurveTo(0.5, bottom, 0.5, bottom - r);
            ctx.lineTo(0.5, r);
            ctx.quadraticCurveTo(0.5, 0.5, r, 0.5);
            ctx.lineTo(gapStart, 0.5);
            ctx.stroke();
        }
    }

    StyledText {
        id: frameLabel

        x: root.padding + root.rounding
        y: Appearance.padding.small
        text: qsTr("LAUNCHER")
        color: Colours.palette.m3onSurfaceVariant
        font.family: Appearance.font.family.mono
        font.pointSize: Appearance.font.size.small
        font.weight: 600
        font.letterSpacing: 2
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
            maxHeight: Math.max(0, root.maxHeight - searchWrapper.implicitHeight - footer.implicitHeight - root.padding * 4 - root.labelInset)
            search: search
        }
    }

    Item {
        id: searchWrapper

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.padding
        anchors.topMargin: root.padding + root.labelInset

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
