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

        // Track header
        Row {
            id: header

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            height: 78
            spacing: 12

            StyledClippingRect {
                id: cover

                width: 76
                height: 76

                anchors.verticalCenter: parent.verticalCenter

                radius: 16
                color: Colours.palette.m3surfaceContainerHigh

                Image {
                    anchors.fill: parent

                    source: Players.active?.trackArtUrl ?? ""

                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop

                    sourceSize.width: 152
                    sourceSize.height: 152
                }

                MaterialIcon {
                    anchors.centerIn: parent

                    visible: !Players.active?.trackArtUrl

                    text: "album"
                    font.pointSize: 22
                    color: Colours.palette.m3outline
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - cover.width - parent.spacing
                spacing: 3

                StyledText {
                    width: parent.width

                    text: Players.active?.trackTitle
                        || qsTr("Nothing playing")

                    color: Colours.palette.m3onSurface

                    font.pointSize: Appearance.font.size.normal + 1
                    font.weight: 600

                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                StyledText {
                    width: parent.width - 22

                    text: Players.active?.trackArtist
                        || qsTr("No media")

                    color: Colours.palette.m3secondary

                    font.pointSize: Appearance.font.size.small

                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }
            }

            // Tiny waveform accent
            WaveMark {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 5

                width: 24
                height: 24
            }
        }

        // Progress
        Item {
            id: progress

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom

            anchors.topMargin: 10

            height: 12

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

                Behavior on width {
                    Anim {
                        duration: Appearance.anim.durations.large
                    }
                }
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

                width: 8
                height: 8

                radius: width / 2

                color: Colours.palette.m3primary

                Behavior on x {
                    Anim {
                        duration: Appearance.anim.durations.large
                    }
                }
            }
        }

        // Controls
        Row {
            id: controls

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            anchors.bottomMargin: 8

            spacing: 22

            PreviousButton {
                canUse: Players.active?.canGoPrevious ?? false

                function onClicked(): void {
                    Players.active?.previous();
                }
            }

            PlayButton {
                canUse: Players.active?.canTogglePlaying ?? false
                playing: Players.active?.isPlaying ?? false

                function onClicked(): void {
                    Players.active?.togglePlaying();
                }
            }

            NextButton {
                canUse: Players.active?.canGoNext ?? false

                function onClicked(): void {
                    Players.active?.next();
                }
            }
        }
    }

    component WaveMark: Canvas {
        id: wave

        property color accent: Colours.palette.m3primary

        onPaint: {
            const ctx = getContext("2d");

            ctx.clearRect(0, 0, width, height);

            ctx.fillStyle = wave.accent;

            const bars = [
                0.30,
                0.55,
                0.85,
                1.0,
                0.65
            ];

            const barWidth = 3;
            const gap = 3;

            for (let i = 0; i < bars.length; i++) {
                const h = height * bars[i];
                const x = i * (barWidth + gap);
                const y = (height - h) / 2;

                ctx.beginPath();
                ctx.roundedRect(
                    x,
                    y,
                    barWidth,
                    h,
                    barWidth / 2,
                    barWidth / 2
                );
                ctx.fill();
            }
        }
    }

    component PreviousButton: Item {
        id: button

        required property bool canUse

        width: 34
        height: 34

        Canvas {
            anchors.fill: parent

            opacity: button.canUse ? 1.0 : 0.35

            onPaint: {
                const ctx = getContext("2d");

                ctx.clearRect(0, 0, width, height);

                const c = Colours.palette.m3onSurface;

                ctx.fillStyle = c;

                // vertical stop
                ctx.fillRect(9, 9, 2, 16);

                // first triangle
                ctx.beginPath();
                ctx.moveTo(14, 17);
                ctx.lineTo(20, 11);
                ctx.lineTo(20, 23);
                ctx.closePath();
                ctx.fill();

                // second triangle
                ctx.beginPath();
                ctx.moveTo(20, 17);
                ctx.lineTo(27, 11);
                ctx.lineTo(27, 23);
                ctx.closePath();
                ctx.fill();
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

    component NextButton: Item {
        id: button

        required property bool canUse

        width: 34
        height: 34

        Canvas {
            anchors.fill: parent

            opacity: button.canUse ? 1.0 : 0.35

            onPaint: {
                const ctx = getContext("2d");

                ctx.clearRect(0, 0, width, height);

                const c = Colours.palette.m3onSurface;

                ctx.fillStyle = c;

                // first triangle
                ctx.beginPath();
                ctx.moveTo(7, 11);
                ctx.lineTo(14, 17);
                ctx.lineTo(7, 23);
                ctx.closePath();
                ctx.fill();

                // second triangle
                ctx.beginPath();
                ctx.moveTo(14, 11);
                ctx.lineTo(21, 17);
                ctx.lineTo(14, 23);
                ctx.closePath();
                ctx.fill();

                // vertical stop
                ctx.fillRect(24, 9, 2, 16);
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

    component PlayButton: Item {
        id: button

        required property bool canUse
        required property bool playing

        width: 48
        height: 48

        Canvas {
            anchors.fill: parent

            opacity: button.canUse ? 1.0 : 0.35

            onPaint: {
                const ctx = getContext("2d");

                ctx.clearRect(0, 0, width, height);

                const accent = Colours.palette.m3primary;

                ctx.strokeStyle = accent;
                ctx.lineWidth = 2;

                ctx.beginPath();
                ctx.arc(
                    width / 2,
                    height / 2,
                    21,
                    0,
                    Math.PI * 2
                );
                ctx.stroke();

                ctx.fillStyle = accent;

                if (button.playing) {
                    ctx.beginPath();
                    ctx.roundedRect(
                        18,
                        14,
                        4,
                        20,
                        2,
                        2
                    );
                    ctx.fill();

                    ctx.beginPath();
                    ctx.roundedRect(
                        26,
                        14,
                        4,
                        20,
                        2,
                        2
                    );
                    ctx.fill();
                } else {
                    ctx.beginPath();
                    ctx.moveTo(20, 14);
                    ctx.lineTo(20, 34);
                    ctx.lineTo(34, 24);
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
