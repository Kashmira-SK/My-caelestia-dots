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

    // Border progress
    Canvas {
        id: progressBorder

        anchors.fill: parent

        anchors.margins: 4

        onPaint: {
            const ctx = getContext("2d");

            const w = width;
            const h = height;
            const r = 18;

            ctx.clearRect(0, 0, w, h);

            // Base line
            ctx.beginPath();
            ctx.moveTo(r, 0);
            ctx.lineTo(w - r, 0);
            ctx.quadraticCurveTo(w, 0, w, r);
            ctx.lineTo(w, h - r);
            ctx.quadraticCurveTo(w, h, w - r, h);
            ctx.lineTo(r, h);
            ctx.quadraticCurveTo(0, h, 0, h - r);
            ctx.lineTo(0, r);
            ctx.quadraticCurveTo(0, 0, r, 0);

            ctx.strokeStyle = Colours.layer(
                Colours.palette.m3surfaceContainerHigh,
                2
            );
            ctx.lineWidth = 2;
            ctx.stroke();

            // Progress
            const perimeter =
                2 * (w + h - 2 * r) + Math.PI * r * 2;

            let remaining = perimeter * root.playerProgress;

            ctx.beginPath();
            ctx.moveTo(r, 0);

            if (remaining > 0) {
                const top = Math.min(
                    remaining,
                    w - 2 * r
                );

                ctx.lineTo(r + top, 0);
                remaining -= top;
            }

            if (remaining > 0) {
                const arc = Math.min(
                    remaining,
                    Math.PI * r / 2
                );

                ctx.arc(
                    w - r,
                    r,
                    r,
                    -Math.PI / 2,
                    -Math.PI / 2 + arc / r,
                    false
                );

                remaining -= arc;
            }

            if (remaining > 0) {
                const right = Math.min(
                    remaining,
                    h - 2 * r
                );

                ctx.lineTo(
                    w,
                    r + right
                );

                remaining -= right;
            }

            if (remaining > 0) {
                const arc = Math.min(
                    remaining,
                    Math.PI * r / 2
                );

                ctx.arc(
                    w - r,
                    h - r,
                    r,
                    0,
                    arc / r,
                    false
                );

                remaining -= arc;
            }

            if (remaining > 0) {
                const bottom = Math.min(
                    remaining,
                    w - 2 * r
                );

                ctx.lineTo(
                    w - r - bottom,
                    h
                );

                remaining -= bottom;
            }

            if (remaining > 0) {
                const arc = Math.min(
                    remaining,
                    Math.PI * r / 2
                );

                ctx.arc(
                    r,
                    h - r,
                    r,
                    Math.PI / 2,
                    Math.PI / 2 + arc / r,
                    false
                );

                remaining -= arc;
            }

            if (remaining > 0) {
                const left = Math.min(
                    remaining,
                    h - 2 * r
                );

                ctx.lineTo(
                    0,
                    h - r - left
                );

                remaining -= left;
            }

            if (remaining > 0) {
                const arc = Math.min(
                    remaining,
                    Math.PI * r / 2
                );

                ctx.arc(
                    r,
                    r,
                    r,
                    Math.PI,
                    Math.PI + arc / r,
                    false
                );
            }

            ctx.strokeStyle = Colours.palette.m3primary;
            ctx.lineWidth = 3;
            ctx.lineCap = "round";
            ctx.stroke();
        }

        Connections {
            target: root

            function onPlayerProgressChanged() {
                progressBorder.requestPaint();
            }
        }
    }

    // Main media content
    Column {
        anchors.fill: parent
        anchors.margins: 16

        spacing: 0

        // Upper area
        Row {
            width: parent.width
            height: 86

            spacing: 13

            StyledClippingRect {
                id: cover

                width: 78
                height: 78

                anchors.verticalCenter: parent.verticalCenter

                radius: 17

                color: Colours.palette.m3surfaceContainerHigh

                MaterialIcon {
                    anchors.centerIn: parent

                    text: "album"
                    font.pointSize: 21

                    color: Colours.palette.m3outline
                }

                Image {
                    anchors.fill: parent

                    source: Players.active?.trackArtUrl ?? ""

                    asynchronous: true

                    fillMode: Image.PreserveAspectCrop

                    sourceSize.width: 156
                    sourceSize.height: 156
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - cover.width - 13

                spacing: 5

                StyledText {
                    width: parent.width

                    text: Players.active?.trackTitle
                        || qsTr("Nothing playing")

                    color: Colours.palette.m3onSurface

                    font.pointSize: Appearance.font.size.normal + 1
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

                    font.pointSize: Appearance.font.size.small

                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }
            }
        }

        // Controls
        Item {
            width: parent.width
            height: parent.height - 86

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                anchors.bottomMargin: 8

                spacing: 28

                MediaButton {
                    icon: "keyboard_double_arrow_left"
                    size: 34
                    iconSize: 17

                    canUse: Players.active?.canGoPrevious ?? false

                    function onClicked(): void {
                        Players.active?.previous();
                    }
                }

                PlayButton {
                    icon: Players.active?.isPlaying
                        ? "pause"
                        : "play_arrow"

                    canUse: Players.active?.canTogglePlaying ?? false

                    function onClicked(): void {
                        Players.active?.togglePlaying();
                    }
                }

                MediaButton {
                    icon: "keyboard_double_arrow_right"
                    size: 34
                    iconSize: 17

                    canUse: Players.active?.canGoNext ?? false

                    function onClicked(): void {
                        Players.active?.next();
                    }
                }
            }
        }
    }

    component MediaButton: Item {
        id: button

        required property string icon
        required property bool canUse
        required property real size
        required property real iconSize

        width: size
        height: size

        StyledRect {
            anchors.fill: parent

            radius: width / 2

            color: button.canUse
                ? "transparent"
                : Colours.layer(
                    Colours.palette.m3surfaceContainerHigh,
                    1
                )

            border.width: 1

            border.color: button.canUse
                ? Colours.palette.m3outline
                : Colours.palette.m3outlineVariant
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: button.icon
            fill: 0

            font.pointSize: button.iconSize

            color: button.canUse
                ? Colours.palette.m3onSurface
                : Colours.palette.m3outline
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

        required property string icon
        required property bool canUse

        width: 48
        height: 48

        StyledRect {
            anchors.fill: parent

            radius: 16

            color: button.canUse
                ? Colours.palette.m3surfaceContainerHigh
                : Colours.palette.m3surfaceContainerLow

            border.width: 1

            border.color: button.canUse
                ? Colours.palette.m3primary
                : Colours.palette.m3outlineVariant
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: button.icon
            fill: 0

            font.pointSize: 21

            color: button.canUse
                ? Colours.palette.m3primary
                : Colours.palette.m3outline
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
