pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.utils
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property var bar
    required property Brightness.Monitor monitor
    property color colour: Colours.palette.m3primary
    readonly property string appClass: Hypr.activeToplevel?.lastIpcObject.class ?? ""
    readonly property string appName: {
        if (!Hypr.activeToplevel)
            return qsTr("Desktop");
        const entry = DesktopEntries.heuristicLookup(appClass);
        return entry?.name || appClass.split(".").pop() || qsTr("Window");
    }

    readonly property int maxHeight: {
        const otherModules = bar.children.filter(c => c.id && c.item !== this && c.id !== "spacer");
        const otherHeight = otherModules.reduce((acc, curr) => acc + (curr.item.nonAnimHeight ?? curr.height), 0);
        // Length - 2 cause repeater counts as a child
        return bar.height - otherHeight - bar.spacing * (bar.children.length - 1) - bar.vPadding * 2;
    }
    property Title current: text1

    clip: true
    implicitWidth: Config.bar.sizes.innerWidth
    implicitHeight: icon.implicitHeight + current.implicitWidth + current.anchors.topMargin

    MaterialIcon {
        id: icon

        anchors.horizontalCenter: parent.horizontalCenter

        animate: true
        text: Icons.getAppCategoryIcon(Hypr.activeToplevel?.lastIpcObject.class, "desktop_windows")
        color: root.colour
    }

    Title {
        id: text1
    }

    Title {
        id: text2
    }

    TextMetrics {
        id: metrics

        text: root.appName.toUpperCase()
        font.pointSize: Appearance.font.size.small
        font.family: Appearance.font.family.mono
        font.weight: 600
        font.letterSpacing: 1
        elide: Qt.ElideRight
        elideWidth: Math.max(0, Math.min(root.maxHeight - icon.height - Appearance.spacing.small, 160))

        onTextChanged: {
            const next = root.current === text1 ? text2 : text1;
            next.text = elidedText;
            root.current = next;
        }
        onElideWidthChanged: root.current.text = elidedText
    }

    Behavior on implicitHeight {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    component Title: StyledText {
        id: text

        anchors.horizontalCenter: icon.horizontalCenter
        anchors.top: icon.bottom
        anchors.topMargin: Appearance.spacing.small

        font.pointSize: metrics.font.pointSize
        font.family: metrics.font.family
        font.weight: metrics.font.weight
        font.letterSpacing: metrics.font.letterSpacing
        color: root.colour
        opacity: root.current === this ? 1 : 0

        transform: [
            Translate {
                x: Config.bar.activeWindow.inverted ? -implicitWidth + text.implicitHeight : 0
            },
            Rotation {
                angle: Config.bar.activeWindow.inverted ? 270 : 90
                origin.x: text.implicitHeight / 2
                origin.y: text.implicitHeight / 2
            }
        ]

        width: implicitHeight
        height: implicitWidth

        Behavior on opacity {
            Anim {}
        }
    } 
    
    StateLayer {
        anchors.fill: parent
        radius: Appearance.rounding.panel
        function onClicked(): void {
            bar.triggerActiveWindowPopout();
        }
    }

}
