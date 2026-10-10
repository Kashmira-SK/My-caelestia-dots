pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

SettingsPage {
    id: root
    readonly property string section: session.sectionFor("dashboard")
    title: PaneRegistry.sectionLabel("dashboard", section)
    required property Session session
    anchors.fill: parent
    SettingsGroup {
        visible: root.section === "general"
        title: qsTr("Opening behavior")
        SettingsToggle { label: qsTr("Enable dashboard"); settings: Config.dashboard; setting: "enabled" }
        SettingsToggle { label: qsTr("Open on hover"); settings: Config.dashboard; setting: "showOnHover"; enabled: Config.dashboard.enabled }
    }

    SettingsGroup {
        visible: root.section === "general"
        title: qsTr("Drag gesture")
        SettingsAdjustment { label: qsTr("Drag distance to open"); settings: Config.dashboard; setting: "dragThreshold"; from: 0; to: 100; stepSize: 1; decimals: 0; suffix: "px" }
    }

    SettingsGroup {
        visible: root.section === "performance"
        title: qsTr("Performance information")
        description: qsTr("Choose which resources appear on the Performance page.")
        SettingsToggle { label: qsTr("CPU"); settings: Config.dashboard.performance; setting: "showCpu" }
        SettingsToggle { label: qsTr("GPU"); settings: Config.dashboard.performance; setting: "showGpu"; visible: SystemUsage.gpuType !== "NONE" }
        SettingsToggle { label: qsTr("Memory"); settings: Config.dashboard.performance; setting: "showMemory" }
        SettingsToggle { label: qsTr("Storage"); settings: Config.dashboard.performance; setting: "showStorage" }
        SettingsToggle { label: qsTr("Network"); settings: Config.dashboard.performance; setting: "showNetwork" }
        SettingsToggle { label: qsTr("Battery"); settings: Config.dashboard.performance; setting: "showBattery"; visible: UPower.displayDevice.isLaptopBattery }
    }

    SettingsGroup {
        visible: root.section === "timing"
        title: qsTr("Refresh timing & gestures")
        description: qsTr("Shorter intervals refresh more often; longer intervals reduce background work.")
        SettingsAdjustment { label: qsTr("Resource refresh interval"); settings: Config.dashboard; setting: "resourceUpdateInterval"; from: 100; to: 10000; stepSize: 100; decimals: 0; suffix: "ms" }
        SettingsAdjustment { label: qsTr("Media refresh interval"); settings: Config.dashboard; setting: "mediaUpdateInterval"; from: 100; to: 10000; stepSize: 100; decimals: 0; suffix: "ms" }
    }
}
