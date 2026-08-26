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
        anchors.margins: 14

        // Track
        Row {
            id: track

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            height: 92
            spacing: 11

            StyledClippingRect {
                id: cover

                width: 78
                height: 78

                anchors.verticalCenter: parent.verticalCenter

                radius: 16
                color: Colours.palette.m3surfaceContainerHigh

                Image {
                    anchors.fill: parent

                    source: Players.active?.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop

                    sourceSize.width: 156
                    sourceSize.height: 156
                }

                MaterialIcon {
                    anchors.centerIn: parent

                    visible: !Players.active?.trackArtUrl

                    text: "album"
                    font.pointSize: 19

                    color: Colours.palette.m3outline
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - cover.width - 11
                spacing: 3

                StyledText {
                    width: parent.width

                    text: Players.active?.trackTitle
                        || qsTr("Nothing playing")

                    color: Colours.palette.m3onSurface

                    font.pointSize: Appearance.font.size.small
                    font.weight: 600

                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
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
        }

        // Progress
        Item {
            id: progress

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: track.bottom

            height: 9

            StyledRect {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width
                height: 3

                radius: Appearance.rounding.full

                color: Colours.layer(
                    Colours.palette.m3surfaceContainerHigh,
                    2
                )
            }

            StyledRect {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width * root.playerProgress
                height: 3

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

                width: 6
                height: 6

                radius: width / 2
                color: Colours.palette.m3primary
            }
        }

        // Controls
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: progress.bottom

            anchors.topMargin: 8

            spacing: 20

            Transport {
                type: 0
                canUse: Players.active?.canGoPrevious ?? false

                function onClicked(): void {
                    Players.active?.previous();
                }
            }

            Play {
                canUse: Players.active?.canTogglePlaying ?? false
                playing: Players.active?.isPlaying ?? false

                function onClicked(): void {
                    Players.active?.togglePlaying();
                }
            }

            Transport {
                type: 1
                canUse: Players.active?.canGoNext ?? false

                function onClicked(): void {
                    Players.active?.next();
                }
            }
        }
    }

    component Transport: Item {
        id: button

        required property int type
        required property bool canUse

        width: 20
        height: 24

        Canvas {
            anchors.centerIn: parent

            width: 18
            height: 18

            opacity: button.canUse ? 1 : 0.3

            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                ctx.fillStyle = Colours.palette.m3onSurface;

                const points = button.type === 0
                    ? [
                        [13, 9],
                        [10, 6],
                        [10, 12],
                        [7, 4],
                        [7, 9],
                        [7, 14]
                    ]
                    : [
                        [5, 9],
                        [8, 6],
                        [8, 12],
                        [11, 4],
                        [11, 9],
                        [11, 14]
                    ];

                for (const p of points) {
                    ctx.beginPath();
                    ctx.arc(
                        p[0],
                        p[1],
                        1.35,
                        0,
                        Math.PI * 2
                    );
                    ctx.fill();
                }

                ctx.fillRect(
                    button.type === 0 ? 15 : 2,
                    5,
                    1.5,
                    8
                );
            }
        }

        MouseArea {
            anchors.fill: parent

            enabled: button.canUse
            cursorShape: Qt.PointingHandCursor

            onClicked: button.onClicked()
        }

        function onClicked(): void {}
    }

    component Play: Item {
        id: button

        required property bool canUse
        required property bool playing

        width: 34
        height: 34

        opacity: canUse ? 1 : 0.35

        Canvas {
            anchors.fill: parent

            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                const accent = Colours.palette.m3primary;

                ctx.strokeStyle = accent;
                ctx.lineWidth = 1.5;

                ctx.beginPath();
                ctx.arc(
                    width / 2,
                    height / 2,
                    15,
                    0,
                    Math.PI * 2
                );
                ctx.stroke();

                ctx.fillStyle = accent;

                if (button.playing) {
                    ctx.fillRect(12, 10, 3, 14);
                    ctx.fillRect(19, 10, 3, 14);
                } else {
                    ctx.beginPath();
                    ctx.moveTo(13, 9);
                    ctx.lineTo(13, 25);
                    ctx.lineTo(24, 17);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            enabled: button.canUse
            cursorShape: Qt.PointingHandCursor

            onClicked: button.onClicked()
        }

        function onClicked(): void {}
    }
}
