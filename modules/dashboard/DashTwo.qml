import "dash2"
import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.utils

Item {
    id: root

    required property PersistentProperties state

    readonly property real dayProgress: (Time.hours * 3600 + Time.minutes * 60 + Time.seconds) / 86400
    readonly property string greeting: {
        if (Time.hours < 5)
            return qsTr("Still up");
        if (Time.hours < 12)
            return qsTr("Good morning");
        if (Time.hours < 17)
            return qsTr("Good afternoon");
        if (Time.hours < 21)
            return qsTr("Good evening");
        return qsTr("Good night");
    }

    implicitWidth: 840
    implicitHeight: 520

    NavigationArray {
        anchors.fill: parent
        dayProgress: root.dayProgress
        timeText: Qt.formatDateTime(Time.date, "HH:mm")
        dateText: Qt.formatDateTime(Time.date, "ddd  /  MMM d, yyyy")
        greeting: root.greeting
        osText: SysInfo.osPrettyName || SysInfo.osName
        wmText: SysInfo.wm
        uptimeText: SysInfo.uptime
    }
}
