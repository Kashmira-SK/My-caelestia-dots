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

    implicitWidth: Config.bar.sizes.innerWidth
    implicitHeight: icon.implicitHeight + Appearance.spacing.small + title.implicitHeight

    MaterialIcon {
        id: icon
        anchors.horizontalCenter: parent.horizontalCenter
        text: Icons.getAppCategoryIcon(root.appClass, "desktop_windows")
        font.pointSize: Appearance.font.size.small
        color: root.colour
    }

    StyledText {
        id: title
        anchors.top: icon.bottom
        anchors.topMargin: Appearance.spacing.small
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        text: root.appName
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        font.family: Appearance.font.family.sans
        font.pointSize: Appearance.font.size.small * 0.85
        font.weight: 400
        color: root.colour
    }

    StateLayer {
        anchors.fill: parent
        radius: Appearance.rounding.panel
        function onClicked(): void {
            bar.triggerActiveWindowPopout();
        }
    }
}
