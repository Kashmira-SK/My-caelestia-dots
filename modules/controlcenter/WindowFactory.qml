pragma Singleton

import qs.components
import qs.services
import Quickshell
import QtQuick

Singleton {
    id: root

    function create(parent: Item, props: var): void {
        controlCenter.createObject(parent ?? dummy, props);
    }

    QtObject {
        id: dummy
    }

    Component {
        id: controlCenter

        FloatingWindow {
            id: win

            property alias active: cc.active
            property alias navExpanded: cc.navExpanded

            color: "transparent"

            onVisibleChanged: {
                if (!visible)
                    destroy();
            }

            implicitWidth: cc.implicitWidth
            implicitHeight: cc.implicitHeight

            minimumSize.width: Math.min(800, cc.screen.width - 40)
            minimumSize.height: Math.min(540, cc.screen.height - 40)
            maximumSize.width: cc.screen.width - 40
            maximumSize.height: cc.screen.height - 40

            title: qsTr("Caelestia Settings - %1").arg(PaneRegistry.getById(cc.active)?.label ?? cc.active)

            ControlCenter {
                id: cc

                anchors.fill: parent
                screen: win.screen
                floating: true

                function close(): void {
                    win.destroy();
                }
            }

            Behavior on color {
                CAnim {}
            }
        }
    }
}
