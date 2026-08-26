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

    Item {
        anchors.fill: parent
        anchors.margins: 14

        // Header
        Item {
            id: header

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            height: 82

            StyledClippingRect {
                id: cover

                anchors.left: parent.left
                anchors.top: parent.top

                width: 76
                height: 76

                radius: 15
                color: Colours.palette.m3surfaceContainerHigh

                MaterialIcon {
                    anchors.centerIn: parent

                    visible: !Players.active?.trackArtUrl

                    text: "album"
                    font.pointSize: 22
                    color: Colours.palette.m3outline
                }

                Image {
                    anchors.fill: parent

                    source: Players.active?.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop

                    sourceSize.width: 152
                    sourceSize.height: 152
                }
            }

            // Waveform accent
            WaveMark {
                id: wave

                anchors.right: parent.right
                anchors.top: parent.top

                width: 25
                height: 28
            }

            // Track information
            Column {
                id: info

                anchors.left: cover.right
                anchors.right: wave.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                anchors.leftMargin: 12
                anchors.rightMargin: 10

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
                    width: parent.width

                    text: Players.active?.trackArtist
                        || qsTr("No media")

                    color: Colours.palette.m3secondary

                    font.pointSize: Appearance.font.size.small

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
            anchors.top: header.bottom

            anchors.topMargin: 8

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
        Item {
            id: controls

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: progress.bottom
            anchors.bottom: parent.bottom

            Row {
                anchors.centerIn: parent

                spacing: 30

                PreviousButton {
                    anchors.verticalCenter: parent.verticalCenter

                    canUse: Players.active?.canGoPrevious ?? false

                    function onClicked(): void {
                        Players.active?.previous();
                    }
                }

                PlayButton {
                    anchors.verticalCenter: parent.verticalCenter

                    canUse: Players.active?.canTogglePlaying ?? false
                    playing: Players.active?.isPlaying ?? false

                    function onClicked(): void {
                        Players.active?.togglePlaying();
                    }
                }

                NextButton {
                    anchors.verticalCenter: parent.verticalCenter

                    canUse: Players.active?.canGoNext ?? false

                    function onClicked(): void {
                        Players.active?.next();
                    }
                }
            }
        }
    }

    component WaveMark: Canvas {
        id: wave

        onPaint: {
            const ctx = getContext("2d");

            ctx.clearRect(0, 0, width, height);

            const accent = Colours.palette.m3primary;

            ctx.fillStyle = accent;

            const heights = [0.35, 0.6, 0.82, 1.0, 0.62];

            const barWidth = 3;
            const gap = 2;
            const totalWidth =
                heights.length * barWidth +
                (heights.length - 1) * gap;

            const startX = (width - totalWidth) / 2;

            for (let i = 0; i < heights.length; ++i) {
                const barHeight = height * heights[i];
                const x = startX + i * (barWidth + gap);
                const y = (height - barHeight) / 2;

                ctx.beginPath();
                ctx.roundedRect(
                    x,
                    y,
                    barWidth,
                    barHeight,
                    1.5,
                    1.5
                );
                ctx.fill();
            }
        }
    }

    component PreviousButton: Item {
        id: button

        required property bool canUse

        width: 40
        height: 40

        opacity: canUse ? 1 : 0.35

        Canvas {
            anchors.fill: parent

            onPaint: {
                const ctx = getContext("2d");

                ctx.clearRect(0, 0, width, height);

                ctx.fillStyle = Colours.palette.m3onSurface;

                // Previous marker
                ctx.fillRect(8, 11, 2, 18);

                // Double triangle
                ctx.beginPath();
                ctx.moveTo(13, 20);
                ctx.lineTo(21, 13);
                ctx.lineTo(21, 27);
                ctx.closePath();
                ctx.fill();

                ctx.beginPath();
                ctx.moveTo(21, 20);
                ctx.lineTo(30, 13);
                ctx.lineTo(30, 27);
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

        width: 40
        height: 40

        opacity: canUse ? 1 : 0.35

        Canvas {
            anchors.fill: parent

            onPaint: {
                const ctx = getContext("2d");

                ctx.clearRect(0, 0, width, height);

                ctx.fillStyle = Colours.palette.m3onSurface;

                // Double triangle
                ctx.beginPath();
                ctx.moveTo(9, 13);
                ctx.lineTo(18, 20);
                ctx.lineTo(9, 27);
                ctx.closePath();
                ctx.fill();

                ctx.beginPath();
                ctx.moveTo(18, 13);
                ctx.lineTo(27, 20);
                ctx.lineTo(18, 27);
                ctx.closePath();
                ctx.fill();

                // Next marker
                ctx.fillRect(30, 11, 2, 18);
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

        width: 50
        height: 50

        opacity: canUse ? 1 : 0.35

        Canvas {
            anchors.fill: parent

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
                        15,
                        5,
                        20,
                        2,
                        2
                    );
                    ctx.fill();

                    ctx.beginPath();
                    ctx.roundedRect(
                        27,
                        15,
                        5,
                        20,
                        2,
                        2
                    );
                    ctx.fill();
                } else {
                    ctx.beginPath();
                    ctx.moveTo(20, 14);
                    ctx.lineTo(20, 36);
                    ctx.lineTo(35, 25);
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
