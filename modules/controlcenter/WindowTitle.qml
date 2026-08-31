import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property ShellScreen screen
    required property Session session

    implicitHeight: 36

    color:
        Colours.tPalette.m3surface

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin:
            Appearance.padding.normal

        anchors.rightMargin:
            Appearance.padding.small

        spacing: 8

        StyledText {
            text:
                qsTr("SETTINGS")

            color:
                Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.54
                )

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 500
            font.letterSpacing: 1
        }

        Rectangle {
            Layout.fillWidth: true

            implicitHeight: 1

            color:
                Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.24
                )
        }

        StyledText {
            text:
                `${String(
                    root.session.activeIndex + 1
                ).padStart(2, "0")} / ${String(
                    root.session.panes.length
                ).padStart(2, "0")}`

            color:
                Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.32
                )

            font.family:
                Appearance.font.family.mono

            font.pointSize:
                Appearance.font.size.smaller
        }

        Item {
            implicitWidth: 26
            implicitHeight: 26

            MaterialIcon {
                anchors.centerIn: parent

                text: "close"

                color:
                    Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        closeMouse.containsMouse
                        ? 0.88
                        : 0.50
                    )

                font.pointSize:
                    Appearance.font.size.small
            }

            MouseArea {
                id: closeMouse

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked:
                    QsWindow.window.destroy()
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 1

        color:
            Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.28
            )
    }
}
