pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    property bool clockShowIcon: Config.bar.clock.showIcon ?? true
    property bool persistent: Config.bar.persistent ?? true
    property bool showOnHover: Config.bar.showOnHover ?? true
    property int dragThreshold: Config.bar.dragThreshold ?? 20
    property bool showAudio: Config.bar.status.showAudio ?? true
    property bool showMicrophone: Config.bar.status.showMicrophone ?? true
    property bool showKbLayout: Config.bar.status.showKbLayout ?? false
    property bool showNetwork: Config.bar.status.showNetwork ?? true
    property bool showWifi: Config.bar.status.showWifi ?? true
    property bool showBluetooth: Config.bar.status.showBluetooth ?? true
    property bool showBattery: Config.bar.status.showBattery ?? true
    property bool showLockStatus: Config.bar.status.showLockStatus ?? true
    property bool trayBackground: Config.bar.tray.background ?? false
    property bool trayCompact: Config.bar.tray.compact ?? false
    property bool trayRecolour: Config.bar.tray.recolour ?? false
    property int workspacesShown: Config.bar.workspaces.shown ?? 5
    property bool workspacesActiveIndicator: Config.bar.workspaces.activeIndicator ?? true
    property bool workspacesOccupiedBg: Config.bar.workspaces.occupiedBg ?? false
    property bool workspacesShowWindows: Config.bar.workspaces.showWindows ?? false
    property bool workspacesPerMonitor: Config.bar.workspaces.perMonitorWorkspaces ?? true
    property bool scrollWorkspaces: Config.bar.scrollActions.workspaces ?? true
    property bool scrollVolume: Config.bar.scrollActions.volume ?? true
    property bool scrollBrightness: Config.bar.scrollActions.brightness ?? true
    property bool popoutActiveWindow: Config.bar.popouts.activeWindow ?? true
    property bool popoutTray: Config.bar.popouts.tray ?? true
    property bool popoutStatusIcons: Config.bar.popouts.statusIcons ?? true

    anchors.fill: parent

    Component.onCompleted: {
        if (Config.bar.entries) {
            entriesModel.clear();

            for (let i = 0; i < Config.bar.entries.length; i++) {
                const entry = Config.bar.entries[i];

                entriesModel.append({
                    id: entry.id,
                    enabled: entry.enabled !== false
                });
            }
        }
    }

    function saveConfig(entryIndex, entryEnabled) {
        Config.bar.clock.showIcon = root.clockShowIcon;
        Config.bar.persistent = root.persistent;
        Config.bar.showOnHover = root.showOnHover;
        Config.bar.dragThreshold = root.dragThreshold;
        Config.bar.status.showAudio = root.showAudio;
        Config.bar.status.showMicrophone = root.showMicrophone;
        Config.bar.status.showKbLayout = root.showKbLayout;
        Config.bar.status.showNetwork = root.showNetwork;
        Config.bar.status.showWifi = root.showWifi;
        Config.bar.status.showBluetooth = root.showBluetooth;
        Config.bar.status.showBattery = root.showBattery;
        Config.bar.status.showLockStatus = root.showLockStatus;
        Config.bar.tray.background = root.trayBackground;
        Config.bar.tray.compact = root.trayCompact;
        Config.bar.tray.recolour = root.trayRecolour;
        Config.bar.workspaces.shown = root.workspacesShown;
        Config.bar.workspaces.activeIndicator = root.workspacesActiveIndicator;
        Config.bar.workspaces.occupiedBg = root.workspacesOccupiedBg;
        Config.bar.workspaces.showWindows = root.workspacesShowWindows;
        Config.bar.workspaces.perMonitorWorkspaces = root.workspacesPerMonitor;
        Config.bar.scrollActions.workspaces = root.scrollWorkspaces;
        Config.bar.scrollActions.volume = root.scrollVolume;
        Config.bar.scrollActions.brightness = root.scrollBrightness;
        Config.bar.popouts.activeWindow = root.popoutActiveWindow;
        Config.bar.popouts.tray = root.popoutTray;
        Config.bar.popouts.statusIcons = root.popoutStatusIcons;

        const entries = [];

        for (let i = 0; i < entriesModel.count; i++) {
            const entry = entriesModel.get(i);
            let enabled = entry.enabled;

            if (entryIndex !== undefined && i === entryIndex)
                enabled = entryEnabled;

            entries.push({
                id: entry.id,
                enabled: enabled
            });
        }

        Config.bar.entries = entries;
        Config.save();
    }

    ListModel {
        id: entriesModel
    }

    StyledFlickable {
        id: taskbarFlickable

        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.large
        anchors.rightMargin: Appearance.padding.large
        anchors.topMargin: Appearance.padding.normal
        anchors.bottomMargin: Appearance.padding.large

        flickableDirection: Flickable.VerticalFlick
        contentHeight: contentLayout.height

        ColumnLayout {
            id: contentLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            spacing: Appearance.spacing.large * 1.7

            
            Section {
                title: qsTr("STATUS ICONS")

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: Appearance.spacing.normal
                    rowSpacing: Appearance.spacing.normal

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Speakers")
                        icon: "volume_up"
                        checked: root.showAudio
                        onToggled: checked => {
                            root.showAudio = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Microphone")
                        icon: "mic"
                        checked: root.showMicrophone
                        onToggled: checked => {
                            root.showMicrophone = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Keyboard")
                        icon: "keyboard"
                        checked: root.showKbLayout
                        onToggled: checked => {
                            root.showKbLayout = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Network")
                        icon: "lan"
                        checked: root.showNetwork
                        onToggled: checked => {
                            root.showNetwork = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Wi-Fi")
                        icon: "wifi"
                        checked: root.showWifi
                        onToggled: checked => {
                            root.showWifi = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Bluetooth")
                        icon: "bluetooth"
                        checked: root.showBluetooth
                        onToggled: checked => {
                            root.showBluetooth = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Battery")
                        icon: "battery_full"
                        checked: root.showBattery
                        onToggled: checked => {
                            root.showBattery = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Capslock")
                        icon: "keyboard_capslock"
                        checked: root.showLockStatus
                        onToggled: checked => {
                            root.showLockStatus = checked;
                            root.saveConfig();
                        }
                    }
                }
            }

            // Deliberate middle band: two similarly weighted sections.
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: Appearance.spacing.large * 2

                Section {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    title: qsTr("WORKSPACES")

                    SettingRow {
                        label: qsTr("Shown")

                        CustomSpinBox {
                            min: 1
                            max: 20
                            value: root.workspacesShown

                            onValueModified: value => {
                                root.workspacesShown = value;
                                root.saveConfig();
                            }
                        }
                    }

                    SettingRow {
                        label: qsTr("Active indicator")

                        StyledSwitch {
                            checked: root.workspacesActiveIndicator

                            onToggled: {
                                root.workspacesActiveIndicator = checked;
                                root.saveConfig();
                            }
                        }
                    }

                    SettingRow {
                        label: qsTr("Occupied background")

                        StyledSwitch {
                            checked: root.workspacesOccupiedBg

                            onToggled: {
                                root.workspacesOccupiedBg = checked;
                                root.saveConfig();
                            }
                        }
                    }

                    SettingRow {
                        label: qsTr("Show windows")

                        StyledSwitch {
                            checked: root.workspacesShowWindows

                            onToggled: {
                                root.workspacesShowWindows = checked;
                                root.saveConfig();
                            }
                        }
                    }

                    SettingRow {
                        label: qsTr("Per monitor workspaces")

                        StyledSwitch {
                            checked: root.workspacesPerMonitor

                            onToggled: {
                                root.workspacesPerMonitor = checked;
                                root.saveConfig();
                            }
                        }
                    }
                }

                Section {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    title: qsTr("BAR")

                    SettingRow {
                        label: qsTr("Show clock icon")

                        StyledSwitch {
                            checked: root.clockShowIcon

                            onToggled: {
                                root.clockShowIcon = checked;
                                root.saveConfig();
                            }
                        }
                    }

                    SettingRow {
                        label: qsTr("Persistent")

                        StyledSwitch {
                            checked: root.persistent

                            onToggled: {
                                root.persistent = checked;
                                root.saveConfig();
                            }
                        }
                    }

                    SettingRow {
                        label: qsTr("Show on hover")

                        StyledSwitch {
                            checked: root.showOnHover

                            onToggled: {
                                root.showOnHover = checked;
                                root.saveConfig();
                            }
                        }
                    }

                    SliderInput {
                        Layout.fillWidth: true
                        Layout.topMargin: Appearance.spacing.normal
                        Layout.bottomMargin: Appearance.spacing.small

                        label: qsTr("Drag threshold")
                        value: root.dragThreshold
                        from: 0
                        to: 100
                        suffix: "px"

                        validator: IntValidator {
                            bottom: 0
                            top: 100
                        }

                        formatValueFunction:
                            val => Math.round(val).toString()

                        parseValueFunction:
                            text => parseInt(text)

                        onValueModified: newValue => {
                            root.dragThreshold = Math.round(newValue);
                            root.saveConfig();
                        }
                    }
                }
            }

            // Deliberate bottom band: three equal modules on one baseline.
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: Appearance.spacing.large * 2

                Section {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    title: qsTr("SCROLL ACTIONS")

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Workspaces")
                        icon: "swap_vert"
                        checked: root.scrollWorkspaces

                        onToggled: checked => {
                            root.scrollWorkspaces = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Volume")
                        icon: "volume_up"
                        checked: root.scrollVolume

                        onToggled: checked => {
                            root.scrollVolume = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Brightness")
                        icon: "brightness_6"
                        checked: root.scrollBrightness

                        onToggled: checked => {
                            root.scrollBrightness = checked;
                            root.saveConfig();
                        }
                    }
                }

                Section {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    title: qsTr("POPOUTS")

                    SettingRow {
                        label: qsTr("Active window")

                        StyledSwitch {
                            checked: root.popoutActiveWindow

                            onToggled: {
                                root.popoutActiveWindow = checked;
                                root.saveConfig();
                            }
                        }
                    }

                    SettingRow {
                        label: qsTr("Tray")

                        StyledSwitch {
                            checked: root.popoutTray

                            onToggled: {
                                root.popoutTray = checked;
                                root.saveConfig();
                            }
                        }
                    }

                    SettingRow {
                        label: qsTr("Status icons")

                        StyledSwitch {
                            checked: root.popoutStatusIcons

                            onToggled: {
                                root.popoutStatusIcons = checked;
                                root.saveConfig();
                            }
                        }
                    }
                }

                Section {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    title: qsTr("TRAY")

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Background")
                        icon: "rectangle"
                        checked: root.trayBackground

                        onToggled: checked => {
                            root.trayBackground = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Compact")
                        icon: "compress"
                        checked: root.trayCompact

                        onToggled: checked => {
                            root.trayCompact = checked;
                            root.saveConfig();
                        }
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        label: qsTr("Recolour")
                        icon: "palette"
                        checked: root.trayRecolour

                        onToggled: checked => {
                            root.trayRecolour = checked;
                            root.saveConfig();
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: Appearance.padding.large
            }
        }
    }

    component Section: ColumnLayout {
        id: section

        required property string title

        default property alias content:
            body.data

        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: Appearance.spacing.small
            spacing: Appearance.spacing.small

            StyledText {
                text: section.title
                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.72
                )
                font.pointSize: Appearance.font.size.smaller
                font.weight: 500
                font.letterSpacing: 0.9
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.24
                )
            }
        }

        ColumnLayout {
            id: body

            Layout.fillWidth: true
            spacing: Appearance.spacing.smaller
        }
    }

    component SettingRow: Item {
        id: settingRow

        required property string label

        default property alias control:
            trailing.data

        Layout.fillWidth: true
        implicitHeight: 54

        StyledText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            text: settingRow.label
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.small
        }

        RowLayout {
            id: trailing

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            spacing: Appearance.spacing.small
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1
            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.15
            )
        }
    }

    component ToggleTile: Item {
        id: tile

        required property string label
        required property string icon
        property bool checked: false

        signal toggled(bool checked)

        implicitHeight: 46
        opacity: enabled ? 1 : 0.32

        Rectangle {
            anchors.fill: parent

            radius: Appearance.rounding.small
            color: tile.checked
                ? Qt.alpha(
                    Colours.palette.m3primary,
                    0.07
                )
                : "transparent"

            border.width: 1
            border.color: tile.checked
                ? Qt.alpha(
                    Colours.palette.m3primary,
                    0.48
                )
                : Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    tileMouse.containsMouse ? 0.46 : 0.24
                )
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: Appearance.spacing.smaller

            MaterialIcon {
                text: tile.icon
                fill: tile.checked ? 1 : 0
                color: tile.checked
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.62
                    )
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                text: tile.label
                color: tile.checked
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.72
                    )
                font.pointSize: Appearance.font.size.small
                font.weight: tile.checked ? 500 : 400
            }
        }

        MouseArea {
            id: tileMouse

            anchors.fill: parent
            enabled: tile.enabled
            hoverEnabled: true

            cursorShape: tile.enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

            onClicked:
                tile.toggled(!tile.checked)
        }
    }
}
