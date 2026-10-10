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

SettingsPage {
    id: root
    required property Session session
    readonly property string section: session.sectionFor("desktop")
    anchors.fill: parent
    title: PaneRegistry.sectionLabel("desktop", section)
    description: section === "wallpaper" ? qsTr("Choose a background and its transition.") : section === "clock" ? qsTr("Position and style the desktop clock.") : qsTr("Show audio activity on your desktop.")
    function setValue(settings: var, key: string, value: var): void { session.changeVisual(settings, key, value); }
    SettingsGroup {
        title: qsTr("Desktop")
        Toggle { label: qsTr("Desktop background"); description: qsTr("Wallpaper, clock, and visualiser"); settings: Config.background; setting: "enabled" }
    }
    SettingsGroup {
        visible: root.section === "wallpaper"
        enabled: Config.background.enabled
        title: qsTr("Background")
        Toggle { label: qsTr("Wallpaper"); description: Wallpapers.actualCurrent.split("/").pop() || qsTr("Choose an image or video"); settings: Config.background; setting: "wallpaperEnabled" }
    }
    SettingsGroup {
        visible: root.section === "wallpaper" && Config.background.enabled && Config.background.wallpaperEnabled
        title: qsTr("Transition")
        contentPadding: 12
GridLayout {
                        Layout.fillWidth: true
                        columns: width < 560 ? 3 : 6
                        columnSpacing: Appearance.spacing.small
                        rowSpacing: Appearance.spacing.small
                        Repeater {
                            model: [
                                { key: "radial", label: qsTr("Radial") },
                                { key: "ripple", label: qsTr("Ripple") },
                                { key: "diagonal", label: qsTr("Diagonal") },
                                { key: "corner", label: qsTr("Corner") },
                                { key: "cross", label: qsTr("Cross") },
                                { key: "random", label: qsTr("Random") }
                            ]
                            Controls.AbstractButton {
                                id: effect
                                required property var modelData
                                readonly property bool selected: Config.background.wallpaperTransition === modelData.key
                                Layout.fillWidth: true
                                implicitHeight: Math.max(38, effectLabel.implicitHeight + 16)
                                Accessible.name: modelData.label
                                Accessible.role: Accessible.RadioButton
                                Accessible.checked: selected
                                onClicked: root.setValue(Config.background, "wallpaperTransition", modelData.key)
                                background: Rectangle {
                                    radius: Appearance.rounding.small
                                    color: Qt.alpha(Colours.palette.m3primary, effect.selected ? 0.14 : effect.hovered ? 0.06 : 0)
                                    border.width: 1
                                    border.color: effect.selected || effect.activeFocus ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outlineVariant, 0.4)
                                }
                                contentItem: StyledText {
                                    id: effectLabel
                                    text: effect.modelData.label
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pointSize: Appearance.font.size.small
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
    }
    StyledTextField {
        id: wallpaperSearch
        visible: root.section === "wallpaper" && Config.background.enabled && Config.background.wallpaperEnabled
        Layout.fillWidth: true
        implicitHeight: 36
        placeholderText: qsTr("Search wallpapers")
        leftPadding: 12
        background: Rectangle { radius: 7; color: Colours.palette.m3surfaceContainerHigh; border.width: 1; border.color: wallpaperSearch.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant }
    }
    Loader {
        Layout.fillWidth: true
        Layout.preferredHeight: 300
        active: root.section === "wallpaper" && Config.background.enabled && Config.background.wallpaperEnabled && root.session.active === "desktop"
        visible: active
        sourceComponent: WallpaperGrid { session: root.session; query: wallpaperSearch.text }
    }
    SettingsGroup {
        visible: root.section === "clock"
        enabled: Config.background.enabled
        title: qsTr("Clock")
        Toggle { label: qsTr("Show clock"); settings: Config.background.desktopClock; setting: "enabled" }
        Adjustment { label: qsTr("Clock size"); settings: Config.background.desktopClock; setting: "scale"; multiplier: 100; from: 50; to: 200; stepSize: 5; decimals: 0; suffix: "%"; enabled: Config.background.desktopClock.enabled }
        Toggle { label: qsTr("Invert clock colors"); settings: Config.background.desktopClock; setting: "invertColors"; enabled: Config.background.desktopClock.enabled }
    }
    SettingsGroup {
        visible: root.section === "clock" && Config.background.enabled && Config.background.desktopClock.enabled
        title: qsTr("Position")
        contentPadding: 12
        ClockPositionPicker { Layout.fillWidth: true; position: Config.background.desktopClock.position; onSelected: position => root.setValue(Config.background.desktopClock, "position", position) }
    }
    SettingsGroup {
        visible: root.section === "clock" && Config.background.enabled && Config.background.desktopClock.enabled
        title: qsTr("Shadow")
        Toggle { label: qsTr("Clock shadow"); settings: Config.background.desktopClock.shadow; setting: "enabled" }
        Adjustment { label: qsTr("Opacity"); settings: Config.background.desktopClock.shadow; setting: "opacity"; multiplier: 100; from: 0; to: 100; decimals: 0; suffix: "%"; enabled: Config.background.desktopClock.shadow.enabled }
        Adjustment { label: qsTr("Softness"); settings: Config.background.desktopClock.shadow; setting: "blur"; multiplier: 100; from: 0; to: 100; decimals: 0; suffix: "%"; enabled: Config.background.desktopClock.shadow.enabled }
    }
    SettingsGroup {
        visible: root.section === "clock" && Config.background.enabled && Config.background.desktopClock.enabled
        title: qsTr("Clock background")
        Toggle { label: qsTr("Background behind clock"); settings: Config.background.desktopClock.background; setting: "enabled" }
        Toggle { label: qsTr("Blur behind clock"); settings: Config.background.desktopClock.background; setting: "blur"; enabled: Config.background.desktopClock.background.enabled }
        Adjustment { label: qsTr("Opacity"); settings: Config.background.desktopClock.background; setting: "opacity"; multiplier: 100; from: 0; to: 100; decimals: 0; suffix: "%"; enabled: Config.background.desktopClock.background.enabled }
    }
    SettingsGroup {
        visible: root.section === "visualiser"
        enabled: Config.background.enabled
        title: qsTr("Audio visualiser")
        Toggle { label: qsTr("Show visualiser"); settings: Config.background.visualiser; setting: "enabled" }
        Toggle { label: qsTr("Hide behind tiled windows"); description: qsTr("Keep it visible on empty workspaces and behind floating windows."); settings: Config.background.visualiser; setting: "autoHide"; enabled: Config.background.visualiser.enabled }
        Adjustment { label: qsTr("Bar roundness"); settings: Config.background.visualiser; setting: "rounding"; from: 0; to: 10; decimals: 0; suffix: "×"; enabled: Config.background.visualiser.enabled }
        Adjustment { label: qsTr("Space between bars"); settings: Config.background.visualiser; setting: "spacing"; from: 0; to: 2; stepSize: 0.1; suffix: "×"; enabled: Config.background.visualiser.enabled }
    }
    component Toggle: SettingsToggle { edit: root.setValue }
    component Adjustment: SettingsAdjustment { edit: root.setValue }
}
