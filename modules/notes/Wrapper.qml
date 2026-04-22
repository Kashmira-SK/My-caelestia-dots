pragma ComponentBehavior: Bound
import qs.components
import qs.config
import Quickshell
import QtQuick

Item {
    id: root
    required property PersistentProperties visibilities

    visible: height > 0
    implicitHeight: 0
    implicitWidth: root.visibilities.notes ? 380 : 0

    states: State {
        name: "visible"
        when: root.visibilities.notes
        PropertyChanges {
            root.implicitHeight: 440
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"
            Anim {
                target: root
                property: "implicitHeight"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""
            Anim {
                target: root
                property: "implicitHeight"
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Loader {
        id: content
        anchors.fill: parent
        active: true
        Component.onCompleted: active = Qt.binding(() => root.visibilities.notes || root.visible)
        sourceComponent: Content {
            visibilities: root.visibilities
        }
    }
}
