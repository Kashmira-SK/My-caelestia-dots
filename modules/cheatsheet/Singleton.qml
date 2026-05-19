pragma Singleton
pragma ComponentBehavior: Bound

import qs.components
import qs.services
import Quickshell
import QtQuick

Singleton {
    id: root

    function create(): void {
        cheatsheet.createObject(null)
    }

    Component {
        id: cheatsheet

        FloatingWindow {
            id: win

            color: Colours.tPalette.m3surface
            title: "Cheatsheet"

            implicitWidth: 860
            implicitHeight: 600

            minimumSize.width: implicitWidth
            minimumSize.height: implicitHeight
            maximumSize.width: implicitWidth
            maximumSize.height: implicitHeight

            onVisibleChanged: {
                if (!visible)
                    destroy()
            }

            Content {
                anchors.fill: parent
            }

            Behavior on color {
                CAnim {}
            }
        }
    }
}
