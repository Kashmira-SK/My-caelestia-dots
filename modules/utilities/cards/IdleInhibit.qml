pragma ComponentBehavior: Bound

import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    Layout.fillWidth: true
    implicitHeight: control.implicitHeight + Appearance.padding.large * 2 + frame.headingHeight / 2

    UtilityFrame {
        id: frame
        title: qsTr("KEEP AWAKE")
    }

    KeepAwakeControl {
        id: control

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Appearance.padding.large
        anchors.topMargin: Appearance.padding.large + frame.headingHeight / 2

        inhibited: IdleInhibitor.enabled
        sinceText: qsTr("Since %1").arg(Qt.formatTime(IdleInhibitor.enabledSince, Config.services.useTwelveHourClock ? "hh:mm a" : "hh:mm"))
        theme: Colours.palette
        appearance: Appearance
        onToggleRequested: IdleInhibitor.enabled = !IdleInhibitor.enabled
    }
}
