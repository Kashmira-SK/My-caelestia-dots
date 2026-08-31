pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import qs.modules.controlcenter
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen
    required property Session session
    required property bool initialOpeningComplete

    implicitHeight: 44

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.normal
        anchors.rightMargin: Appearance.padding.normal

        spacing: Appearance.spacing.small

        Repeater {
            model: PaneRegistry.count

            NavItem {
                required property int index

                Layout.fillWidth: true

                paneIndex: index
                icon: PaneRegistry.getByIndex(index).icon
                label: PaneRegistry.getByIndex(index).label
            }
        }

        Loader {
            active: !root.session.floating
            visible: active

            sourceComponent: Item {
                implicitWidth: 30
                implicitHeight: 30

                MaterialIcon {
                    anchors.centerIn: parent

                    text: "select_window"

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        floatMouse.containsMouse ? 0.84 : 0.46
                    )

                    font.pointSize: Appearance.font.size.small
                }

                MouseArea {
                    id: floatMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.session.root.close();

                        WindowFactory.create(null, {
                            active: root.session.active,
                            navExpanded: root.session.navExpanded
                        });
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 1

        color: Qt.alpha(
            Colours.palette.m3outlineVariant,
            0.24
        )
    }

    component NavItem: Item {
        id: item

        required property int paneIndex
        required property string icon
        required property string label

        readonly property bool active:
            root.session.active === label

        implicitHeight: 43

        RowLayout {
            id: itemContent

            anchors.centerIn: parent

            spacing: 6

            StyledText {
                text:
                    String(
                        item.paneIndex + 1
                    ).padStart(2, "0")

                color:
                    item.active
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.26
                    )

                font.family:
                    Appearance.font.family.mono

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 500
            }

            MaterialIcon {
                text: item.icon

                fill:
                    item.active ? 1 : 0

                color:
                    item.active
                    ? Qt.alpha(
                        Colours.palette.m3primary,
                        0.82
                    )
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        navMouse.containsMouse ? 0.68 : 0.40
                    )

                font.pointSize:
                    Appearance.font.size.small

                Behavior on fill {
                    Anim {}
                }
            }

            StyledText {
                text: item.label

                font.capitalization:
                    Font.Capitalize

                color:
                    item.active
                    ? Colours.palette.m3onSurface
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        navMouse.containsMouse ? 0.68 : 0.42
                    )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight:
                    item.active ? 500 : 400
            }
        }

        Rectangle {
            anchors.horizontalCenter:
                parent.horizontalCenter

            anchors.bottom:
                parent.bottom

            width:
                item.active
                ? Math.max(
                    24,
                    itemContent.implicitWidth * 0.36
                )
                : 0

            height: 2
            radius: 1

            color:
                Colours.palette.m3primary

            Behavior on width {
                Anim {}
            }
        }

        MouseArea {
            id: navMouse

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (!root.initialOpeningComplete)
                    return;

                root.session.active =
                    item.label;
            }
        }
    }
}
