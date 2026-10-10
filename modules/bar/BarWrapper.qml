pragma ComponentBehavior: Bound

import qs.components
import qs.config
import "popouts" as BarPopouts
import Quickshell
import QtQuick

Item {
    id: root

    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property BarPopouts.Wrapper popouts
    required property bool disabled

    readonly property int padding: Math.max(Appearance.padding.smaller, Config.border.thickness)
    readonly property int contentWidth: Config.bar.sizes.innerWidth + padding * 2
    readonly property bool floating: Config.bar.mode === "floating"
    readonly property int floatingRounding: 6
    // Match the app frame: screen border plus Hyprland's 7px outer gap.
    // Hyprland supplies the gap on the app-facing side of the reserved area.
    readonly property int edgeGap: floating ? Config.border.thickness + 7 : 0
    readonly property int expandedWidth: contentWidth + edgeGap
    
    // Reserve physical screen space only when pinned
    readonly property int exclusiveZone: !disabled && visibilities.bar ? expandedWidth : Config.border.thickness
    
    // Render the bar if pinned or actively hovered
    readonly property bool shouldBeVisible: !disabled && (visibilities.bar || isHovered)
    
    property bool isHovered

    function closeTray(): void {
        content.item?.closeTray();
    }

    function checkPopout(y: real): void {
        content.item?.checkPopout(y - edgeGap);
    }

    function handleWheel(y: real, angleDelta: point): void {
        content.item?.handleWheel(y - edgeGap, angleDelta);
    }

    visible: width > Config.border.thickness
    implicitWidth: Config.border.thickness

    states: State {
        name: "visible"
        when: root.shouldBeVisible

        PropertyChanges {
            root.implicitWidth: root.expandedWidth
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                property: "implicitWidth"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                property: "implicitWidth"
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Loader {
        id: content

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: root.edgeGap
        anchors.bottomMargin: root.edgeGap

        active: root.shouldBeVisible || root.visible

        sourceComponent: Bar {
            width: root.contentWidth
            screen: root.screen
            visibilities: root.visibilities
            popouts: root.popouts
        }
    }
}
