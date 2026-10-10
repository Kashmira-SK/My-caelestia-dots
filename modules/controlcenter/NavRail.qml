pragma ComponentBehavior: Bound
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property ShellScreen screen
    required property Session session
    required property bool initialOpeningComplete
    implicitWidth: 210
    color: Qt.alpha(Colours.palette.m3surfaceContainer, Colours.transparency.enabled ? 0.35 : 1)
    StyledFlickable {
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds;
        id: scroll
        anchors.fill: parent
        anchors.margins: 12
        contentHeight: navigation.implicitHeight + 8
        clip: true
        StyledScrollBar.vertical: StyledScrollBar { animatePosition: false; flickable: scroll }
        ColumnLayout {
            id: navigation
            width: scroll.width
            spacing: 3
            Repeater {
                model: PaneRegistry.count
                ColumnLayout {
                    id: entry
                    required property int index
                    readonly property var pane: PaneRegistry.getByIndex(index)
                    readonly property bool startsGroup: index === 0 || pane.group !== PaneRegistry.getByIndex(index - 1).group
                    Layout.fillWidth: true
                    spacing: 3
                    StyledText {
                        visible: entry.startsGroup && entry.pane.group !== ""
                        Layout.leftMargin: 12
                        Layout.topMargin: entry.index === 0 ? 7 : 18
                        Layout.bottomMargin: 7
                        text: entry.pane.group.toLocaleUpperCase()
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: 8.25 * Appearance.font.size.scale
                        font.weight: 600
                    }
                    Rectangle {
                        visible: entry.startsGroup && entry.pane.group === ""
                        Layout.fillWidth: true
                        Layout.topMargin: 12
                        Layout.bottomMargin: 8
                        implicitHeight: 1
                        color: Qt.alpha(Colours.palette.m3outlineVariant, 0.5)
                    }
                    Controls.AbstractButton {
                        id: button
                        Layout.fillWidth: true
                        implicitHeight: Math.max(32, label.implicitHeight + 10)
                        readonly property bool selected: root.session.active === entry.pane.id
                        Accessible.name: entry.pane.label
                        onClicked: if (root.initialOpeningComplete) root.session.active = entry.pane.id
                        background: Rectangle {
                            radius: 6
                            color: Qt.alpha(Colours.palette.m3primary, button.selected && PaneRegistry.sectionsFor(entry.pane.id).length === 0 ? 0.14 : button.hovered ? 0.06 : 0)
                            border.width: button.activeFocus ? 1 : 0
                            border.color: Colours.palette.m3primary
                        }
                        contentItem: RowLayout {
                            spacing: 10
                            MaterialIcon { text: entry.pane.icon; font.pointSize: 12.0; color: button.selected ? Colours.palette.m3onSurface : Colours.palette.m3onSurfaceVariant }
                            StyledText {
                                id: label
                                Layout.fillWidth: true
                                text: entry.pane.label
                                color: button.selected ? Colours.palette.m3onSurface : Colours.palette.m3onSurfaceVariant
                                font.pointSize: 9.75 * Appearance.font.size.scale
                                font.weight: button.selected ? 600 : 400
                                elide: Text.ElideRight
                            }
                        }
                        leftPadding: 12
                        rightPadding: 8
                    }
                    ColumnLayout {
                        visible: root.session.active === entry.pane.id && PaneRegistry.sectionsFor(entry.pane.id).length > 0
                        Layout.fillWidth: true
                        Layout.leftMargin: 28
                        Layout.topMargin: 2
                        Layout.bottomMargin: 6
                        spacing: 3
                        Repeater {
                            model: PaneRegistry.sectionsFor(entry.pane.id)
                            Controls.AbstractButton {
                                id: subsection
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: Math.max(32, subLabel.implicitHeight + 10)
                                readonly property bool selected: root.session.sectionFor(entry.pane.id) === modelData.id
                                Accessible.name: modelData.label
                                onClicked: root.session.setSection(entry.pane.id, modelData.id)
                                background: Rectangle {
                                    radius: 6
                                    color: Qt.alpha(Colours.palette.m3primary, subsection.selected ? 0.14 : subsection.hovered ? 0.06 : 0)
                                    border.width: subsection.activeFocus ? 1 : 0
                                    border.color: Colours.palette.m3primary
                                }
                                contentItem: StyledText {
                                    id: subLabel
                                    text: subsection.modelData.label
                                    font.pointSize: 9.75 * Appearance.font.size.scale
                                    font.weight: subsection.selected ? 600 : 400
                                    color: subsection.selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                                    verticalAlignment: Text.AlignVCenter
                                }
                                leftPadding: 12
                            }
                        }
                    }
                }
            }
        }
    }
}
