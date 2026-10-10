pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    readonly property string section: session.sectionFor("launcher")
    required property Session session
    spacing: Appearance.spacing.large * 1.5
    SettingsGroup {
        visible: root.section === "general"
        title: qsTr("Opening & navigation")
        SettingsToggle { label: qsTr("Enable launcher"); settings: Config.launcher; setting: "enabled" }
        SettingsToggle { label: qsTr("Vim-style keyboard navigation"); settings: Config.launcher; setting: "vimKeybinds" }
    }

    SettingsGroup {
        visible: root.section === "search"
        title: qsTr("Search matching")
        description: qsTr("Allow approximate matches when your search is not an exact name.")
        SettingsToggle { label: qsTr("Applications"); settings: Config.launcher.useFuzzy; setting: "apps" }
        SettingsToggle { label: qsTr("Actions"); settings: Config.launcher.useFuzzy; setting: "actions" }
        SettingsToggle { label: qsTr("Color profiles"); settings: Config.launcher.useFuzzy; setting: "schemes" }
        SettingsToggle { label: qsTr("Palette styles"); settings: Config.launcher.useFuzzy; setting: "variants" }
        SettingsToggle { label: qsTr("Wallpapers"); settings: Config.launcher.useFuzzy; setting: "wallpapers" }
    }

    SettingsGroup {
        visible: root.section === "general"
        title: qsTr("Command actions")
        SettingsToggle { label: qsTr("Allow dangerous command actions"); settings: Config.launcher; setting: "enableDangerousActions" }
    }
    SettingsGroup {
        visible: root.section === "layout"
        title: qsTr("Current layout")
        SettingsValue { label: qsTr("Maximum results"); value: String(Config.launcher.maxShown) }
        SettingsValue { label: qsTr("Maximum wallpapers"); value: String(Config.launcher.maxWallpapers) }
        SettingsValue { label: qsTr("Result width"); value: String(Config.launcher.sizes.itemWidth) + " px" }
        SettingsValue { label: qsTr("Result height"); value: String(Config.launcher.sizes.itemHeight) + " px" }
        SettingsValue { label: qsTr("Wallpaper preview width"); value: String(Config.launcher.sizes.wallpaperWidth) + " px" }
        SettingsValue { label: qsTr("Wallpaper preview height"); value: String(Config.launcher.sizes.wallpaperHeight) + " px" }
    }
    SettingsGroup {
        visible: root.section === "search"
        title: qsTr("Search prefixes")
        SettingsValue { label: qsTr("Special search"); value: Config.launcher.specialPrefix || qsTr("None") }
        SettingsValue { label: qsTr("Actions"); value: Config.launcher.actionPrefix || qsTr("None") }
    }
}
