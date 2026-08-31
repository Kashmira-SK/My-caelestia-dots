import qs.components.controls
import QtQuick
import QtQuick.Layouts

CollapsibleSection {
    id: root

    required property var rootPane

    title: qsTr("Dashboard")
    description: qsTr("Dashboard visibility")

    SwitchRow {
        label: qsTr("Enabled")
        checked: root.rootPane.dashboardEnabled

        onToggled: checked => {
            root.rootPane.dashboardEnabled = checked;
            root.rootPane.saveConfig();
        }
    }

    SwitchRow {
        label: qsTr("Show on hover")
        checked: root.rootPane.dashboardShowOnHover

        onToggled: checked => {
            root.rootPane.dashboardShowOnHover = checked;
            root.rootPane.saveConfig();
        }
    }
}
