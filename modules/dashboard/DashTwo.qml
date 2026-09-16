import "dash2"
import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.utils

Item {
    id: root
    required property PersistentProperties state
    readonly property bool hasTimeline: {
        const player = Players.active;
        return !!player && player.positionSupported && player.lengthSupported && Number.isFinite(player.position) && Number.isFinite(player.length) && player.length > 0;
    }
    implicitWidth: 840
    implicitHeight: 520
    Timer {
        interval: Config.dashboard.mediaUpdateInterval
        running: root.visible && (Players.active?.isPlaying ?? false) && (Players.active?.positionSupported ?? false)
        repeat: true
        triggeredOnStart: true
        onTriggered: Players.active?.positionChanged()
    }
    Celestial {
        anchors.fill: parent
        timeText: Qt.formatDateTime(Time.date, "HH:mm")
        dateText: Qt.formatDateTime(Time.date, "dddd, MMMM d")
        dayProgress: (Time.hours * 3600 + Time.minutes * 60 + Time.seconds) / 86400
        osText: SysInfo.osPrettyName || SysInfo.osName
        wmText: SysInfo.wm
        uptimeText: SysInfo.uptime
        hasPlayer: !!Players.active
        playing: Players.active?.isPlaying ?? false
        trackTitle: (Players.active?.trackTitle || qsTr("Nothing playing")).replace(/\s+/g, " ").trim()
        trackArtist: (Players.active?.trackArtist || "").replace(/\s+/g, " ").trim()
        hasTimeline: root.hasTimeline
        playerProgress: root.hasTimeline ? Math.max(0, Math.min(1, Players.active.position / Players.active.length)) : 0
        onMediaRequested: root.state.currentTab = 2
    }
}
