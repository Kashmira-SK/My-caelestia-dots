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

    readonly property alias current: title
    readonly property real titleLimit: {
        const otherModules = bar.children.filter(c => c.id && c.item !== root && c.id !== "spacer");
        const usedHeight = otherModules.reduce((total, c) => total + (c.item?.nonAnimHeight ?? c.height), 0);
        return Math.max(0, Math.min(160, bar.height - usedHeight - bar.spacing * (bar.children.length - 1) - bar.vPadding * 2 - icon.height - Appearance.spacing.small));
    }

    implicitWidth: Config.bar.sizes.innerWidth
    implicitHeight: titleSlot.y + titleSlot.implicitHeight

    MaterialIcon {
        id: icon
        anchors.horizontalCenter: parent.horizontalCenter
        text: Icons.getAppCategoryIcon(root.appClass, "desktop_windows")
        font.pointSize: Appearance.font.size.small
        color: root.colour
    }

    Item {
        id: titleSlot
        y: Math.ceil(icon.y + icon.height + Appearance.spacing.small)
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        implicitHeight: Math.min(Math.ceil(title.implicitWidth / 2) * 2, Math.floor(root.titleLimit / 2) * 2)

        StyledText {
            id: title
            anchors.centerIn: parent
            width: titleSlot.height
            height: Math.ceil(implicitHeight / 2) * 2
            rotation: Config.bar.activeWindow.inverted ? 270 : 90
            text: root.appName
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            renderType: Text.QtRendering
            font.family: Appearance.font.family.sans
            font.pointSize: Appearance.font.size.small
            font.weight: 400
            color: root.colour
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
