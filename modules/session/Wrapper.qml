pragma ComponentBehavior: Bound

import qs.components
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    required property var panels
    readonly property real nonAnimWidth: content.implicitWidth

    visible: width > 0
    implicitWidth: 0
    // The shared silhouette must enclose the OSD's rounded joins. A shorter
    // session rail exposes the concave ends against the wallpaper.
    implicitHeight: Math.max(content.implicitHeight, root.panels.osd.implicitHeight + Math.max(Config.border.rounding * 2, Config.session.sizes.button * 1.5))

    states: State {
        name: "visible"
        when: root.visibilities.session && Config.session.enabled

        PropertyChanges {
            root.implicitWidth: root.nonAnimWidth
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                property: "implicitWidth"
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                property: "implicitWidth"
                easing.bezierCurve: root.panels.osd.width > 0 ? Appearance.anim.curves.expressiveDefaultSpatial : Appearance.anim.curves.emphasized
            }
        }
    ]

    Loader {
        id: content

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        Component.onCompleted: active = Qt.binding(() => (root.visibilities.session && Config.session.enabled) || root.visible)

        sourceComponent: Content {
            visibilities: root.visibilities
        }
    }
}
