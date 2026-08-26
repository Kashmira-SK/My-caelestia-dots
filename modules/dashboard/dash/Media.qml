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

                width: 72
                height: 72

                radius: 15
                color: Colours.palette.m3surfaceContainerHigh

                Image {
                    anchors.fill: parent

                    source: Players.active?.trackArtUrl ?? ""

                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop

                    sourceSize.width: 144
                    sourceSize.height: 144
                }

                MaterialIcon {
                    anchors.centerIn: parent

                    visible: !Players.active?.trackArtUrl

                    text: "album"
                    font.pointSize: 20
                    color: Colours.palette.m3outline
                }
            }

            // Waveform
            WaveMark {
                anchors.right: parent.right
                anchors.top: parent.top

                width: 22
                height: 25
            }

            // Track info
            Column {
                anchors.left: cover.right
                anchors.top: cover.top

                anchors.leftMargin: 11

                width: parent.width - cover.width - 11
                spacing: 2

                StyledText {
                    width: parent.width

                    text: Players.active?.trackTitle
                        || qsTr("Nothing playing")

                    color: Colours.palette.m3onSurface

                    font.pointSize: Appearance.font.size.normal
                    font.weight: 600

                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                StyledText {
                    width: parent.width - 4

                    text: Players.active?.trackArtist
                        || qsTr("No media")

                    color: Colours.palette.m3secondary

                    font.pointSize: Appearance.font.size.smaller

                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight

                    lineHeight: 1.05
                }
            }
        }

        // Progress
        Item {
            id: progress

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom

            anchors.topMargin: 4

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

                width: 7
                height: 7

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
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: progress.bottom
            anchors.bottom: parent.bottom

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                spacing: 26

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
        onPaint: {
            const ctx = getContext("2d");

            ctx.clearRect(0, 0, width, height);

            const accent = Colours.palette.m3primary;

            ctx.fillStyle = accent;

            const bars = [0.35, 0.62, 0.88, 1.0, 0.68];

            const barWidth = 2.5;
            const gap = 2.5;

            const totalWidth =
                bars.length * barWidth +
                (bars.length - 1) * gap;

            const startX = (width - totalWidth) / 2;

            for (let i = 0; i < bars.length; ++i) {
                const h = height * bars[i];
                const x = startX + i * (barWidth + gap);
                const y = (height - h) / 2;

                ctx.beginPath();
                ctx.roundedRect(
                    x,
                    y,
                    barWidth,
                    h,
                    1.25,
                    1.25
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

                const accent = Colours.palette.m3onSurface;

                ctx.fillStyle = accent;

                // Vertical stop
                ctx.fillRect(8, 10, 2, 20);

                // Dot triangle pointing left
                const dots = [
                    [15, 20],
                    [19, 16],
                    [19, 24],
                    [23, 12],
                    [23, 20],
                    [23, 28]
                ];

                for (const point of dots) {
                    ctx.beginPath();
                    ctx.arc(
                        point[0],
                        point[1],
                        2,
                        0,
                        Math.PI * 2
                    );
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

                const accent = Colours.palette.m3onSurface;

                ctx.fillStyle = accent;

                // Dot triangle pointing right
                const dots = [
                    [25, 20],
                    [21, 16],
                    [21, 24],
                    [17, 12],
                    [17, 20],
                    [17, 28]
                ];

                for (const point of dots) {
                    ctx.beginPath();
                    ctx.arc(
                        point[0],
                        point[1],
                        2,
                        0,
                        Math.PI * 2
                    );
                    ctx.fill();
                }

                // Vertical stop
                ctx.fillRect(30, 10, 2, 20);
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
