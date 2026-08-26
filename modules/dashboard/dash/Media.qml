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
        Anim {
            duration: Appearance.anim.durations.large
        }
    }

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: Config.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    // Media
    Item {
        anchors.fill: parent
        anchors.margins: 12

        StyledClippingRect {
            id: cover

            anchors.left: parent.left
            anchors.top: parent.top

            width: 58
            height: 58

            radius: 14

            color: Colours.palette.m3surfaceContainerHigh

            MaterialIcon {
                anchors.centerIn: parent

                text: "music_note"
                font.pointSize: 18

                color: Colours.palette.m3outline
            }

            Image {
                anchors.fill: parent

                source: Players.active?.trackArtUrl ?? ""
                asynchronous: true

                fillMode: Image.PreserveAspectCrop

                sourceSize.width: 116
                sourceSize.height: 116
            }
        }

        Column {
            anchors.left: cover.right
            anchors.right: parent.right
            anchors.top: cover.top

            anchors.leftMargin: 10

            spacing: 2

            StyledText {
                width: parent.width

                text: Players.active?.trackTitle
                    || qsTr("Nothing playing")

                color: Colours.palette.m3onSurface

                font.pointSize: Appearance.font.size.small
                font.weight: 650

                maximumLineCount: 1
                elide: Text.ElideRight
            }

            StyledText {
                width: parent.width

                text: Players.active?.trackArtist
                    || qsTr("No media")

                color: Colours.palette.m3secondary

                font.pointSize: Appearance.font.size.smaller

                maximumLineCount: 2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }
        }

        // Progress
        Item {
            anchors.left: cover.right
            anchors.right: parent.right
            anchors.top: cover.bottom

            anchors.leftMargin: 10
            anchors.topMargin: 8

            height: 7

            StyledRect {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width
                height: 2

                radius: Appearance.rounding.full

                color: Colours.palette.m3surfaceContainerHighest
            }

            StyledRect {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width * root.playerProgress
                height: 2

                radius: Appearance.rounding.full

                color: Colours.palette.m3primary
            }

            StyledRect {
                anchors.verticalCenter: parent.verticalCenter

                x: Math.max(
                    0,
                    Math.min(
                        parent.width - width,
                        (parent.width - width) * root.playerProgress
                    )
                )

                width: 5
                height: 5

                radius: width / 2

                color: Colours.palette.m3primary
            }
        }

        // Controls
        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            spacing: 10

            TinyControl {
                icon: "arrow_back_ios"
                canUse: Players.active?.canGoPrevious ?? false

                function onClicked(): void {
                    Players.active?.previous();
                }
            }

            TinyPlay {
                icon: Players.active?.isPlaying
                    ? "pause"
                    : "play_arrow"

                canUse: Players.active?.canTogglePlaying ?? false

                function onClicked(): void {
                    Players.active?.togglePlaying();
                }
            }

            TinyControl {
                icon: "arrow_forward_ios"
                canUse: Players.active?.canGoNext ?? false

                function onClicked(): void {
                    Players.active?.next();
                }
            }
        }
    }

    component TinyControl: Item {
        id: control

        required property string icon
        required property bool canUse

        width: 24
        height: 24

        MaterialIcon {
            anchors.centerIn: parent

            text: control.icon
            fill: 0

            font.pointSize: 11

            color: control.canUse
                ? Colours.palette.m3onSurfaceVariant
                : Colours.palette.m3outline
        }

        MouseArea {
            anchors.fill: parent
            enabled: control.canUse

            onClicked: control.onClicked()
        }

        function onClicked(): void {}
    }

    component TinyPlay: Item {
        id: control

        required property string icon
        required property bool canUse

        width: 28
        height: 28

        StyledRect {
            anchors.fill: parent

            radius: width / 2

            color: control.canUse
                ? Colours.palette.m3primary
                : Colours.palette.m3surfaceContainerHigh
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: control.icon
            fill: 1

            font.pointSize: 13

            color: control.canUse
                ? Colours.palette.m3onPrimary
                : Colours.palette.m3outline
        }

        MouseArea {
            anchors.fill: parent
            enabled: control.canUse

            onClicked: control.onClicked()
        }

        function onClicked(): void {}
    }
}
