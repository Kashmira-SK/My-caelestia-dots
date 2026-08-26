import qs.components
import qs.services
import qs.config
import qs.utils
import Caelestia.Services
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties state

    anchors.fill: parent

    property real playerProgress: {
        const active = Players.active;
        return active?.length > 0
            ? Math.max(0, Math.min(1, active.position / active.length))
            : 0;
    }

    Behavior on playerProgress {
        Anim { duration: Appearance.anim.durations.large }
    }

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: Config.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    Item {
        anchors.fill: parent
        anchors.margins: 14

        // Header
        Item {
            id: header

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 76

            StyledClippingRect {
                id: cover

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 68
                height: 68
                radius: Appearance.rounding.normal
                color: Colours.palette.m3surfaceContainerHigh

                Image {
                    anchors.fill: parent
                    source: Players.active?.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 136
                    sourceSize.height: 136
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    visible: !Players.active?.trackArtUrl
                    text: "album"
                    font.pointSize: Appearance.font.size.large
                    color: Colours.palette.m3outline
                }
            }

            // Track information — no more visualizer column eating width,
            // just a small pulsing dot in front of the title. That alone
            // reclaims ~26px, which is why titles were eliding after only
            // a few characters before.
            Column {
                id: info

                anchors.left: cover.right
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Appearance.spacing.small
                spacing: 3

                Row {
                    width: parent.width
                    spacing: 5

                    StyledRect {
                        id: playingDot
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Players.active?.isPlaying ?? false
                        implicitWidth: 6
                        implicitHeight: 6
                        radius: 3
                        color: Colours.palette.m3primary

                        SequentialAnimation on opacity {
                            running: playingDot.visible
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.3; duration: 700; easing.type: Easing.InOutQuad }
                            NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutQuad }
                        }
                    }

                    StyledText {
                        width: parent.width - (playingDot.visible ? 11 : 0)
                        text: Players.active?.trackTitle || qsTr("Nothing playing")
                        color: Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 650
                        maximumLineCount: 1
                        elide: Text.ElideRight
                    }
                }

                StyledText {
                    width: parent.width
                    text: Players.active?.trackArtist || qsTr("No media")
                    color: Colours.palette.m3secondary
                    font.pointSize: Appearance.font.size.smaller
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    lineHeight: 1.0
                }
            }
        }

        // Progress
        Item {
            id: progress

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.topMargin: 5
            height: 10

            StyledRect {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 3
                radius: Appearance.rounding.full
                color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
            }

            StyledRect {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * root.playerProgress
                height: 3
                radius: Appearance.rounding.full
                color: Colours.palette.m3primary

                Behavior on width {
                    Anim { duration: Appearance.anim.durations.large }
                }
            }

            StyledRect {
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * root.playerProgress))
                width: 7
                height: 7
                radius: width / 2
                color: Colours.palette.m3primary

                Behavior on x {
                    Anim { duration: Appearance.anim.durations.large }
                }
            }
        }

        // Controls — clean MaterialIcon-based, matching the rest of the
        // dashboard (weather icon, tab icons, calendar arrows) instead
        // of the hand-drawn dot-matrix icons.
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: progress.bottom
            anchors.bottom: parent.bottom

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.spacing.larger

                TransportButton {
                    icon: "skip_previous"
                    canUse: Players.active?.canGoPrevious ?? false
                    function onClicked(): void { Players.active?.previous(); }
                }

                PlayButton {
                    canUse: Players.active?.canTogglePlaying ?? false
                    playing: Players.active?.isPlaying ?? false
                    function onClicked(): void { Players.active?.togglePlaying(); }
                }

                TransportButton {
                    icon: "skip_next"
                    canUse: Players.active?.canGoNext ?? false
                    function onClicked(): void { Players.active?.next(); }
                }
            }
        }
    }

    component TransportButton: Item {
        id: button

        required property string icon
        required property bool canUse
        function onClicked(): void {}

        implicitWidth: 34
        implicitHeight: 34

        StateLayer {
            disabled: !button.canUse
            radius: Appearance.rounding.full
            function onClicked(): void { button.onClicked(); }
        }

        MaterialIcon {
            anchors.centerIn: parent
            animate: true
            fill: 1
            text: button.icon
            color: button.canUse ? Colours.palette.m3onSurface : Colours.palette.m3outline
            font.pointSize: Appearance.font.size.large
        }
    }

    component PlayButton: Item {
        id: button

        required property bool canUse
        required property bool playing
        function onClicked(): void {}

        implicitWidth: 48
        implicitHeight: 48

        StyledRect {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: button.canUse ? Colours.palette.m3primary : Colours.palette.m3outline
            border.width: 2
        }

        StateLayer {
            disabled: !button.canUse
            radius: Appearance.rounding.full
            function onClicked(): void { button.onClicked(); }
        }

        MaterialIcon {
            anchors.centerIn: parent
            animate: true
            fill: 1
            text: button.playing ? "pause" : "play_arrow"
            color: button.canUse ? Colours.palette.m3primary : Colours.palette.m3outline
            font.pointSize: Appearance.font.size.large
        }
    }
}
