pragma ComponentBehavior: Bound

import ".."
import "../components"
import "."
import qs.components
import qs.components.controls
import qs.components.containers
import qs.config
import Quickshell.Widgets
import Quickshell.Bluetooth
import QtQuick

SplitPaneWithDetails {
    id: root

    required property Session session

    anchors.fill: parent

    singlePane: true
    showRightPane: session.sectionFor("bluetooth") === "settings" || !!session.bt.active
    showBackButton: !!session.bt.active
    onBackRequested: session.bt.active = null
    activeItem: session.bt.active
    paneIdGenerator: function (item) {
        return item ? (item.address || "") : "";
    }

    leftContent: Component {
        StyledFlickable {
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds;
            id: leftFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: deviceList.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {

                animatePosition: false
                flickable: leftFlickable
            }

            DeviceList {
                id: deviceList

                width: leftFlickable.width
                session: root.session
            }
        }
    }

    rightDetailsComponent: Component {
        Details {
            session: root.session
        }
    }

    rightSettingsComponent: Component {
        StyledFlickable {
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds;
            id: settingsFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: settingsInner.height

            StyledScrollBar.vertical: StyledScrollBar {

                animatePosition: false
                flickable: settingsFlickable
            }

            Settings {
                id: settingsInner

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                session: root.session
            }
        }
    }
}
