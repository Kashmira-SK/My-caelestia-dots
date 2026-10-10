pragma ComponentBehavior: Bound
import ".."
import "../components"
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

StyledFlickable {
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds;
    id: root
    required property Session session
    anchors.fill: parent
    clip: true
    contentHeight: body.implicitHeight + 50
    flickableDirection: Flickable.VerticalFlick
    StyledScrollBar.vertical: StyledScrollBar { animatePosition: false; flickable: root }
    Connections {
        target: root.session
        function onBarSectionChanged(): void { root.contentY = 0; }
    }
    ColumnLayout {
        id: body
        x: 28
        y: 25
        width: Math.max(0, root.width - 56)
        spacing: 22
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 7
            StyledText {
                text: PaneRegistry.barSectionLabel(root.session.barSection)
                font.pointSize: 16.5 * Appearance.font.size.scale
                font.weight: 600
            }
            StyledText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: ({ general: qsTr("Control when the bar appears and how its tray looks."),
                         workspaces: qsTr("Choose what the workspace strip shows."),
                         indicators: qsTr("Choose which status icons appear in the bar."),
                         interaction: qsTr("Set what scrolling, hovering, and dragging do.") })[root.session.barSection]
                font.pointSize: 9.75 * Appearance.font.size.scale
                color: Colours.palette.m3onSurfaceVariant
            }
        }
        GridLayout {
            Layout.fillWidth: true
            visible: root.session.barSection === "general"
            columns: 1
            columnSpacing: 18
            rowSpacing: 22
            SettingsCard {
                title: qsTr("Sidebar appearance")
                contentPadding: 16
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Repeater {
                        model: [
                            { mode: "attached", label: qsTr("Attached") },
                            { mode: "floating", label: qsTr("Floating") }
                        ]
                        Controls.AbstractButton {
                            id: modeButton
                            required property var modelData
                            readonly property bool selected: Config.bar.mode === modelData.mode
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            implicitHeight: 38
                            Accessible.role: Accessible.RadioButton
                            Accessible.name: modelData.label
                            Accessible.checked: selected
                            onClicked: {
                                Config.bar.mode = modelData.mode;
                                Config.save();
                            }
                            contentItem: StyledText {
                                text: modeButton.modelData.label
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: 10 * Appearance.font.size.scale
                                color: modeButton.selected ? Colours.palette.m3primary : Colours.palette.m3onSurface
                            }
                            background: Rectangle {
                                radius: 6
                                color: modeButton.selected ? Qt.alpha(Colours.palette.m3primary, 0.12) : modeButton.hovered ? Qt.alpha(Colours.palette.m3onSurface, 0.06) : "transparent"
                                border.width: 1
                                border.color: modeButton.selected || modeButton.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
                            }
                        }
                    }
                }
            }
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("Visibility")
                SettingsFormRow { label: qsTr("Always show the bar"); settings: Config.bar; setting: "persistent" }
                SettingsFormRow { label: qsTr("Reveal on hover"); settings: Config.bar; setting: "showOnHover"; description: qsTr("Available when the bar is not always visible."); enabled: !Config.bar.persistent }
            }
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("System tray")
                SettingsFormRow { label: qsTr("Tray background"); settings: Config.bar.tray; setting: "background" }
                SettingsFormRow { label: qsTr("Compact tray icons"); settings: Config.bar.tray; setting: "compact" }
                SettingsFormRow { label: qsTr("Use theme colors for tray icons"); settings: Config.bar.tray; setting: "recolour" }
            }
        }
        GridLayout {
            Layout.fillWidth: true
            visible: root.session.barSection === "workspaces"
            columns: 1
            columnSpacing: 18
            rowSpacing: 22
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("Layout")
                SettingsFormRow { label: qsTr("Visible workspaces"); settings: Config.bar.workspaces; setting: "shown"; numeric: true; from: 1; to: 20 }
                SettingsFormRow { label: qsTr("Separate workspaces per monitor"); settings: Config.bar.workspaces; setting: "perMonitorWorkspaces"; description: qsTr("Show only the workspaces belonging to each display.") }
            }
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("Indicators")
                SettingsFormRow { label: qsTr("Highlight the active workspace"); settings: Config.bar.workspaces; setting: "activeIndicator" }
                SettingsFormRow { label: qsTr("Highlight occupied workspaces"); settings: Config.bar.workspaces; setting: "occupiedBg" }
                SettingsFormRow { label: qsTr("Show application icons"); settings: Config.bar.workspaces; setting: "showWindows" }
            }
        }
        GridLayout {
            Layout.fillWidth: true
            visible: root.session.barSection === "indicators"
            columns: root.width >= 650 ? 2 : 1
            columnSpacing: 18
            rowSpacing: 22
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("Sound & input")
                SettingsFormRow { label: qsTr("Speakers"); settings: Config.bar.status; setting: "showAudio" }
                SettingsFormRow { label: qsTr("Microphone"); settings: Config.bar.status; setting: "showMicrophone" }
                SettingsFormRow { label: qsTr("Keyboard layout"); settings: Config.bar.status; setting: "showKbLayout" }
                SettingsFormRow { label: qsTr("Caps Lock"); settings: Config.bar.status; setting: "showLockStatus" }
            }
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("Connections & power")
                SettingsFormRow { label: qsTr("Network"); settings: Config.bar.status; setting: "showNetwork" }
                SettingsFormRow { label: qsTr("Wi-Fi"); settings: Config.bar.status; setting: "showWifi" }
                SettingsFormRow { label: qsTr("Bluetooth"); settings: Config.bar.status; setting: "showBluetooth" }
                SettingsFormRow { label: qsTr("Battery"); settings: Config.bar.status; setting: "showBattery" }
            }
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("Clock")
                SettingsFormRow { label: qsTr("Clock icon"); settings: Config.bar.clock; setting: "showIcon" }
            }
        }
        GridLayout {
            Layout.fillWidth: true
            visible: root.session.barSection === "interaction"
            columns: root.width >= 650 ? 2 : 1
            columnSpacing: 18
            rowSpacing: 22
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("Scroll to adjust")
                SettingsFormRow { label: qsTr("Workspaces"); settings: Config.bar.scrollActions; setting: "workspaces" }
                SettingsFormRow { label: qsTr("Volume"); settings: Config.bar.scrollActions; setting: "volume" }
                SettingsFormRow { label: qsTr("Brightness"); settings: Config.bar.scrollActions; setting: "brightness" }
            }
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("Detail popups")
                SettingsFormRow { label: qsTr("Active application"); settings: Config.bar.popouts; setting: "activeWindow" }
                SettingsFormRow { label: qsTr("Tray"); settings: Config.bar.popouts; setting: "tray" }
                SettingsFormRow { label: qsTr("Status icons"); settings: Config.bar.popouts; setting: "statusIcons" }
            }
            SettingsCard {
                Layout.alignment: Qt.AlignTop
                title: qsTr("Drag gesture")
                SettingsFormRow { label: qsTr("Drag distance to open"); settings: Config.bar; setting: "dragThreshold"; description: qsTr("Distance in pixels before opening the panel."); numeric: true; from: 0; to: 100 }
            }
        }
    }
}
