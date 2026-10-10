pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.effects
import qs.components.containers
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Component leftContent
    required property Component rightDetailsComponent
    required property Component rightSettingsComponent

    property var activeItem: null
    property bool singlePane: false
    property bool showRightPane: false
    property bool showBackButton: false
    signal backRequested
    property var paneIdGenerator: function (item) {
        return item ? String(item) : "";
    }

    property Component overlayComponent: null

    SplitPaneLayout {
        id: splitLayout
        singlePane: root.singlePane
        showRightPane: root.showRightPane
        showBackButton: root.showBackButton
        onBackRequested: root.backRequested()

        anchors.fill: parent

        leftContent: root.leftContent

        rightContent: Component {
            Item {
                id: rightPaneItem

                Loader {
                    anchors.fill: parent
                    clip: true
                    sourceComponent: root.activeItem ? root.rightDetailsComponent : root.rightSettingsComponent
                }

            }
        }
    }

    Loader {
        id: overlayLoader

        anchors.fill: parent
        z: 1000
        sourceComponent: root.overlayComponent
        active: root.overlayComponent !== null
    }
}
