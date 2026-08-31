pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.config
import Caelestia.Services
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties visibilities
    required property PersistentProperties state

    property real playerProgress: {
        const active = Players.active;
        return active?.length
            ? Math.max(0, Math.min(1, active.position / active.length))
            : 0;
    }

    function lengthStr(length: int): string {
        if (length < 0)
            return "--:--";

        const hours = Math.floor(length / 3600);
        const mins = Math.floor((length % 3600) / 60);
        const secs = Math.floor(length % 60).toString().padStart(2, "0");

        if (hours > 0)
            return `${hours}:${mins.toString().padStart(2, "0")}:${secs}`;

        return `${mins}:${secs}`;
    }

    function playerLabel(player): string {
        const identity = Players.getIdentity(player) || "";
        const lower = identity.toLowerCase();

        if (lower.includes("kash"))
            return "Kash";

        if (lower.includes("firefox"))
            return "Firefox";

        return identity;
    }

    implicitWidth: 840
    implicitHeight: 255

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

    ServiceRef {
        service: Audio.cava
    }

    ServiceRef {
        service: Audio.beatTracker
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large

        spacing: Appearance.spacing.large

        // Art + waveform
        ColumnLayout {
            id: artColumn

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 172

            spacing: Appearance.spacing.small

            StyledClippingRect {
                id: cover

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 138
                Layout.preferredHeight: 138

                radius: 34

                color:
                    Colours.tPalette.m3surfaceContainerHigh

                border.width: 1
                border.color:
                    Qt.alpha(
                        Colours.palette.m3outlineVariant,
                        0.42
                    )

                MaterialIcon {
                    anchors.centerIn: parent

                    visible:
                        !(Players.active?.trackArtUrl ?? "")

                    text: "album"

                    color:
                        Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.42
                        )

                    font.pointSize:
                        Appearance.font.size.extraLarge
                }

                Image {
                    anchors.fill: parent

                    source:
                        Players.active?.trackArtUrl
                        ?? ""

                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop

                    sourceSize.width: width * 2
                    sourceSize.height: height * 2
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 34

                Row {
                    id: waveRow

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom

                    spacing: 4

                    Repeater {
                        model: 18

                        delegate: Rectangle {
                            required property int index

                            readonly property int cavaIndex:
                                Math.min(
                                    Config.services.visualiserBars - 1,
                                    Math.floor(
                                        index
                                        * Config.services.visualiserBars
                                        / 18
                                    )
                                )

                            readonly property real cavaValue:
                                Audio.cava.values[cavaIndex]
                                ?? 0

                            width: 4

                            height:
                                Players.active?.isPlaying
                                ? 5 + cavaValue * 24
                                : 5

                            anchors.bottom:
                                parent.bottom

                            radius: 2

                            color:
                                Qt.alpha(
                                    Colours.palette.m3primary,
                                    Players.active?.isPlaying
                                    ? 0.76
                                    : 0.26
                                )

                            Behavior on height {
                                NumberAnimation {
                                    duration: 90
                                }
                            }

                            Behavior on color {
                                CAnim {}
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.topMargin: Appearance.padding.small
            Layout.bottomMargin: Appearance.padding.small

            implicitWidth: 1

            color:
                Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.30
                )
        }

        // Player info
        ColumnLayout {
            id: details

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 310

            spacing: Appearance.spacing.small

            RowLayout {
                Layout.fillWidth: true

                spacing: Appearance.spacing.small

                StyledText {
                    text: qsTr("Now playing")

                    color:
                        Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.48
                        )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 500
                    font.letterSpacing: 0.7
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 12

                    implicitHeight: 1

                    color:
                        Qt.alpha(
                            Colours.palette.m3outlineVariant,
                            0.26
                        )
                }

                RowLayout {
                    spacing: 9

                    Repeater {
                        model: Players.list

                        delegate: SourceButton {
                            required property var modelData

                            player: modelData
                        }
                    }
                }
            }

            Item {
                Layout.preferredHeight:
                    Appearance.spacing.smaller
            }

            StyledText {
                Layout.fillWidth: true

                text:
                    (
                        Players.active?.trackTitle
                        ?? qsTr("No media")
                    )
                    || qsTr("Unknown title")

                color:
                    Players.active
                    ? Colours.palette.m3onSurface
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.70
                    )

                font.pointSize:
                    Appearance.font.size.large

                font.weight: 500

                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true

                text:
                    (
                        Players.active?.trackArtist
                        ?? qsTr("Play something to start.")
                    )
                    || qsTr("Unknown artist")

                color:
                    Players.active
                    ? Qt.alpha(
                        Colours.palette.m3secondary,
                        0.82
                    )
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.46
                    )

                font.pointSize:
                    Appearance.font.size.small

                font.weight: 400

                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight:
                    Appearance.spacing.smaller
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: Appearance.spacing.normal

                TransportButton {
                    icon: "skip_previous"

                    canUse:
                        Players.active?.canGoPrevious
                        ?? false

                    function onClicked(): void {
                        Players.active?.previous();
                    }
                }

                PlayButton {
                    canUse:
                        Players.active?.canTogglePlaying
                        ?? false

                    playing:
                        Players.active?.isPlaying
                        ?? false

                    function onClicked(): void {
                        Players.active?.togglePlaying();
                    }
                }

                TransportButton {
                    icon: "skip_next"

                    canUse:
                        Players.active?.canGoNext
                        ?? false

                    function onClicked(): void {
                        Players.active?.next();
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                UtilityButton {
                    icon: "move_up"

                    canUse:
                        Players.active?.canRaise
                        ?? false

                    function onClicked(): void {
                        Players.active?.raise();
                        root.visibilities.dashboard = false;
                    }
                }

                UtilityButton {
                    icon: "close"
                    destructive: true

                    canUse:
                        Players.active?.canQuit
                        ?? false

                    function onClicked(): void {
                        Players.active?.quit();
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 0

                StyledSlider {
                    id: slider

                    Layout.fillWidth: true

                    enabled: !!Players.active

                    implicitHeight:
                        Appearance.padding.normal * 2.1

                    onMoved: {
                        const active = Players.active;

                        if (
                            active?.canSeek
                            && active?.positionSupported
                        )
                            active.position =
                                value * active.length;
                    }

                    Binding {
                        target: slider
                        property: "value"
                        value: root.playerProgress
                        when: !slider.pressed
                    }

                    CustomMouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton

                        function onWheel(
                            event: WheelEvent
                        ) {
                            const active =
                                Players.active;

                            if (
                                !active?.canSeek
                                || !active?.positionSupported
                            )
                                return;

                            event.accepted = true;

                            const delta =
                                event.angleDelta.y > 0
                                ? 10
                                : -10;

                            Qt.callLater(() => {
                                active.position =
                                    Math.max(
                                        0,
                                        Math.min(
                                            active.length,
                                            active.position
                                            + delta
                                        )
                                    );
                            });
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text:
                            root.lengthStr(
                                Players.active?.position
                                ?? -1
                            )

                        color:
                            Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.46
                            )

                        font.family:
                            Appearance.font.family.mono

                        font.pointSize:
                            Appearance.font.size.smaller
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text:
                            root.lengthStr(
                                Players.active?.length
                                ?? -1
                            )

                        color:
                            Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.46
                            )

                        font.family:
                            Appearance.font.family.mono

                        font.pointSize:
                            Appearance.font.size.smaller
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.topMargin: Appearance.padding.small
            Layout.bottomMargin: Appearance.padding.small

            implicitWidth: 1

            color:
                Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.30
                )
        }

        // Character
        Item {
            id: characterZone

            Layout.fillHeight: true
            Layout.preferredWidth: 150

            property var gifList: [
                "/home/kashmira/.config/quickshell/caelestia/assets/Citlali.gif",
                "/home/kashmira/.config/quickshell/caelestia/assets/EvernightGlass.gif",
                "/home/kashmira/.config/quickshell/caelestia/assets/rikka.gif",
                "/home/kashmira/.config/quickshell/caelestia/assets/yeee.gif",
                "/home/kashmira/.config/quickshell/caelestia/assets/Cartwheel.gif",
                "/home/kashmira/.config/quickshell/caelestia/assets/Miku.gif",
                "/home/kashmira/.config/quickshell/caelestia/assets/bongocat1.gif"
            ]

            AnimatedImage {
                anchors.fill: parent
                anchors.margins: 2

                playing:
                    Players.active?.isPlaying
                    ?? false

                speed:
                    Audio.beatTracker.bpm
                    / Appearance.anim.mediaGifSpeedAdjustment

                source:
                    characterZone.gifList[
                        root.state.gifIndex
                    ]

                asynchronous: true

                fillMode:
                    AnimatedImage.PreserveAspectFit
            }

            Item {
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                width:
                    swapContent.implicitWidth + 10

                height: 22

                RowLayout {
                    id: swapContent

                    anchors.centerIn: parent

                    spacing: 4

                    MaterialIcon {
                        text: "swap_horiz"

                        color:
                            Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                swapArea.containsMouse
                                ? 0.82
                                : 0.46
                            )

                        font.pointSize:
                            Appearance.font.size.small
                    }

                    StyledText {
                        text: qsTr("gif")

                        color:
                            Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                swapArea.containsMouse
                                ? 0.72
                                : 0.38
                            )

                        font.pointSize:
                            Appearance.font.size.smaller
                    }
                }

                MouseArea {
                    id: swapArea

                    anchors.fill: parent
                    anchors.margins: -4

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.state.gifIndex =
                            (
                                root.state.gifIndex + 1
                            )
                            % characterZone.gifList.length;
                    }
                }
            }
        }
    }

    component SourceButton: Item {
        id: sourceButton

        required property var player

        readonly property bool active:
            sourceButton.player
            === Players.active

        implicitWidth:
            Math.min(
                84,
                sourceLabel.implicitWidth + 6
            )

        implicitHeight:
            sourceLabel.implicitHeight + 7

        StyledText {
            id: sourceLabel

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            text:
                root.playerLabel(
                    sourceButton.player
                )

            color:
                sourceButton.active
                ? Colours.palette.m3primary
                : Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    sourceMouse.containsMouse
                    ? 0.68
                    : 0.40
                )

            font.pointSize:
                Appearance.font.size.smaller

            font.weight:
                sourceButton.active ? 500 : 400

            horizontalAlignment:
                Text.AlignHCenter

            elide: Text.ElideRight
            maximumLineCount: 1
        }

        Rectangle {
            visible:
                sourceButton.active

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1

            color:
                Colours.palette.m3primary
        }

        MouseArea {
            id: sourceMouse

            anchors.fill: parent
            anchors.margins: -4

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
                Players.manualActive =
                    sourceButton.player
        }
    }

    component TransportButton: Item {
        id: button

        required property string icon
        required property bool canUse

        function onClicked(): void {}

        implicitWidth: 28
        implicitHeight: 28

        MaterialIcon {
            anchors.centerIn: parent

            text: button.icon

            color:
                button.canUse
                ? Qt.alpha(
                    Colours.palette.m3onSurface,
                    transportMouse.containsMouse
                    ? 0.94
                    : 0.68
                )
                : Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.22
                )

            font.pointSize:
                Appearance.font.size.normal
        }

        MouseArea {
            id: transportMouse

            anchors.fill: parent
            anchors.margins: -3

            enabled: button.canUse
            hoverEnabled: true

            cursorShape:
                button.canUse
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

            onClicked:
                button.onClicked()
        }
    }

    component PlayButton: Item {
        id: button

        required property bool canUse
        required property bool playing

        function onClicked(): void {}

        implicitWidth: 40
        implicitHeight: 40

        StyledRect {
            anchors.fill: parent

            radius: Infinity

            color:
                Qt.alpha(
                    Colours.palette.m3primary,
                    button.canUse
                    ? playMouse.containsMouse
                        ? 0.18
                        : 0.09
                    : 0.04
                )

            border.width: 1

            border.color:
                Qt.alpha(
                    Colours.palette.m3primary,
                    button.canUse ? 0.52 : 0.14
                )
        }

        MaterialIcon {
            anchors.centerIn: parent

            text:
                button.playing
                ? "pause"
                : "play_arrow"

            fill: 1

            color:
                button.canUse
                ? Colours.palette.m3primary
                : Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.22
                )

            font.pointSize:
                Appearance.font.size.large
        }

        MouseArea {
            id: playMouse

            anchors.fill: parent

            enabled: button.canUse
            hoverEnabled: true

            cursorShape:
                button.canUse
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

            onClicked:
                button.onClicked()
        }
    }

    component UtilityButton: Item {
        id: button

        required property string icon
        required property bool canUse

        property bool destructive: false

        function onClicked(): void {}

        implicitWidth: 26
        implicitHeight: 26

        MaterialIcon {
            anchors.centerIn: parent

            text: button.icon

            color:
                button.canUse
                ? Qt.alpha(
                    button.destructive
                    ? Colours.palette.m3error
                    : Colours.palette.m3onSurfaceVariant,
                    utilityMouse.containsMouse
                    ? 0.80
                    : 0.44
                )
                : Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.16
                )

            font.pointSize:
                Appearance.font.size.small
        }

        MouseArea {
            id: utilityMouse

            anchors.fill: parent
            anchors.margins: -3

            enabled: button.canUse
            hoverEnabled: true

            cursorShape:
                button.canUse
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

            onClicked:
                button.onClicked()
        }
    }
}
