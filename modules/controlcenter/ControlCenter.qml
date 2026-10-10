pragma ComponentBehavior: Bound
import "components"
import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property ShellScreen screen
    readonly property int rounding: floating ? 0 : Appearance.rounding.normal
    property alias floating: session.floating
    property alias active: session.active
    property alias navExpanded: session.navExpanded
    readonly property Session session: Session { id: session; root: root }
    readonly property bool initialOpeningComplete: panes.initialOpeningComplete
    function close(): void {}

    // Use content-sized defaults; large monitors should not stretch the form.
    implicitWidth: Math.min(1000, screen.width - 40)
    implicitHeight: Math.min(660, screen.height - 40)
    color: Colours.palette.m3surfaceContainerLow
    radius: rounding

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            Layout.leftMargin: 24
            Layout.rightMargin: 16
            spacing: 12
            StyledText {
                Layout.maximumWidth: root.width * 0.27
                elide: Text.ElideRight
                text: PaneRegistry.getById(root.active)?.label ?? ""
                font.pointSize: 12.75 * Appearance.font.size.scale
                font.weight: 600
            }
            StyledText {
                visible: root.session.sectionFor(root.active) !== ""
                Layout.maximumWidth: root.width * 0.23
                elide: Text.ElideRight
                text: "/   " + PaneRegistry.sectionLabel(root.active, root.session.sectionFor(root.active))
                font.pointSize: 10.5 * Appearance.font.size.scale
                color: Colours.palette.m3onSurfaceVariant
            }
            Item { Layout.fillWidth: true }
            HeaderAction {
                visible: root.session.visualHistory.length > 0
                enabled: root.session.canUndoVisual
                iconName: "undo"
                label: enabled ? qsTr("Undo last visual change") : qsTr("This value changed elsewhere")
                onClicked: root.session.undoVisual()
            }
            SettingsSearch { session: root.session; Layout.preferredWidth: root.width < 900 ? 190 : 225 }
            HeaderAction {
                visible: !root.floating
                iconName: "select_window"
                label: qsTr("Open settings in a window")
                onClicked: {
                    root.close();
                    WindowFactory.create(null, { active: root.active, navExpanded: root.navExpanded });
                }
            }
            HeaderAction { iconName: "close"; label: qsTr("Close settings"); onClicked: root.close() }
        }
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Qt.alpha(Colours.palette.m3outlineVariant, 0.6) }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            NavRail {
                Layout.preferredWidth: 210
                Layout.fillHeight: true
                screen: root.screen
                session: root.session
                initialOpeningComplete: root.initialOpeningComplete
            }
            Rectangle { Layout.fillHeight: true; implicitWidth: 1; color: Qt.alpha(Colours.palette.m3outlineVariant, 0.6) }
            Panes {
                id: panes
                Layout.fillWidth: true
                Layout.fillHeight: true
                bottomRightRadius: root.rounding
                session: root.session
            }
        }
    }
    component HeaderAction: Controls.AbstractButton {
        id: action
        required property string iconName
        required property string label
        implicitWidth: 30
        implicitHeight: 32
        Accessible.name: label
        SettingsToolTip { visible: action.hovered; text: action.label }
        onEnabledChanged: opacity = enabled ? 1 : 0.45
        background: Rectangle {
            radius: 6
            color: Qt.alpha(Colours.palette.m3primary, action.hovered ? 0.1 : 0)
            border.width: action.activeFocus ? 1 : 0
            border.color: Colours.palette.m3primary
        }
        contentItem: MaterialIcon { text: action.iconName; color: Colours.palette.m3onSurfaceVariant; font.pointSize: 13.5 }
    }
}
