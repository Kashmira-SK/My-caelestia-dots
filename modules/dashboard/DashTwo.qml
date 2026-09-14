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
    readonly property bool hasTimeline: {
        const active = Players.active;
        return !!active && active.positionSupported && active.lengthSupported && Number.isFinite(active.position) && Number.isFinite(active.length) && active.length > 0;
    }
    readonly property real playerProgress: {
        const active = Players.active;
        return root.hasTimeline ? Math.max(0, Math.min(1, active.position / active.length)) : 0;
    }
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

    function cleanMetadata(value, fallback: string): string {
        const text = (value ?? "").toString().replace(/\s+/g, " ").trim();
        return text || fallback;
    }

    implicitWidth: 840
    implicitHeight: 520

    Timer {
        running: root.visible && (Players.active?.positionSupported ?? false) && (Players.active?.isPlaying ?? false)
        interval: Config.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    NavigationArray {
        anchors.fill: parent
        dayProgress: root.dayProgress
        timeText: Qt.formatDateTime(Time.date, "HH:mm")
        dateText: Qt.formatDateTime(Time.date, "ddd  /  MMM d, yyyy")
        greeting: root.greeting
        osText: SysInfo.osPrettyName || SysInfo.osName
        wmText: SysInfo.wm
        uptimeText: SysInfo.uptime
        hasPlayer: !!Players.active
        playing: Players.active?.isPlaying ?? false
        trackTitle: root.cleanMetadata(Players.active?.trackTitle, qsTr("No signal acquired"))
        trackArtist: root.cleanMetadata(Players.active?.trackArtist, qsTr("Media channel idle"))
        playerProgress: root.playerProgress
        onMediaRequested: root.state.currentTab = 2
    }
}
