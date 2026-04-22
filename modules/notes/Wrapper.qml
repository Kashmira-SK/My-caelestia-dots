pragma ComponentBehavior: Bound
import qs.components
import qs.config
import Quickshell
import QtQuick

Item {
    id: root
    required property PersistentProperties visibilities

    clip: true
    width: 0
    height: 0

    states: State {
        name: "visible"
        when: root.visibilities.notes
        PropertyChanges {
            root.width: content.implicitWidth
            root.height: content.implicitHeight
        }
    }

    transitions: Transition {
        Anim {
            target: root
            properties: "width,height"
            duration: Appearance.anim.durations.expressiveDefaultSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
        }
    }

    Content {
        id: content
        visible: root.visibilities.notes
        visibilities: root.visibilities
        isVisible: root.visibilities.notes
    }
}
