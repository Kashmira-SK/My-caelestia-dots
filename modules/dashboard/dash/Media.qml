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

    property real playerProgress: {
        const active = Players.active;
        return active?.length > 0 ? Math.max(0, Math.min(1, active.position / active.length)) : 0;
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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.normal
        spacing: Appearance.spacing.normal

        // ─────────────────────────────────────────────
        // Track information
        // ─────────────────────────────────────────────

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            spacing: Appearance.spacing.normal

            StyledClippingRect {
                id: cover

                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignVCenter

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainerHigh

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "music_note"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: 17
                }

                Image {
                    anchors.fill: parent
                    source: Players.active?.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 96
                    sourceSize.height: 96
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                StyledText {
                    Layout.fillWidth: true

                    text: Players.active?.trackTitle
                        || qsTr("Nothing playing")

                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.small
                    font.weight: 600

                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                StyledText {
                    Layout.fillWidth: true

                    text: Players.active?.trackArtist
                        || qsTr("No media")

                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.smaller

                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }
        }

        // ─────────────────────────────────────────────
        // Progress
        // ─────────────────────────────────────────────

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8

            StyledRect {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                implicitHeight: 3
                radius: Appearance.rounding.full

                color: Colours.layer(
                    Colours.palette.m3surfaceContainerHigh,
                    2
                )
            }

            StyledRect {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                implicitHeight: 3

                width: parent.width * root.playerProgress

                radius: Appearance.rounding.full
                color: Colours.palette.m3primary

                Behavior on width {
                    Anim {
                        duration: Appearance.anim.durations.large
                    }
                }
            }

            StyledRect {
                id: handle

                anchors.verticalCenter: parent.verticalCenter

                x: Math.max(
                    0,
                    Math.min(
                        parent.width - implicitWidth,
                        (parent.width - implicitWidth) * root.playerProgress
                    )
                )

                implicitWidth: 7
                implicitHeight: 7

                radius: width / 2
                color: Colours.palette.m3primary

                Behavior on x {
                    Anim {
                        duration: Appearance.anim.durations.large
                    }
                }
            }
        }

        // ─────────────────────────────────────────────
        // Controls
        // ─────────────────────────────────────────────

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: Appearance.spacing.small

            Control {
                icon: "skip_previous"
                canUse: Players.active?.canGoPrevious ?? false

                function onClicked(): void {
                    Players.active?.previous();
                }
            }

            PlayControl {
                icon: Players.active?.isPlaying
                    ? "pause"
                    : "play_arrow"

                canUse: Players.active?.canTogglePlaying ?? false

                function onClicked(): void {
                    Players.active?.togglePlaying();
                }
            }

            Control {
                icon: "skip_next"
                canUse: Players.active?.canGoNext ?? false

                function onClicked(): void {
                    Players.active?.next();
                }
            }
        }
    }

    // ─────────────────────────────────────────────────
    // Small secondary controls
    // ─────────────────────────────────────────────────

    component Control: Item {
        id: control

        required property string icon
        required property bool canUse

        function onClicked(): void {}

        implicitWidth: 34
        implicitHeight: 34

        StateLayer {
            anchors.fill: parent

            disabled: !control.canUse
            radius: Appearance.rounding.full

            function onClicked(): void {
                control.onClicked();
            }
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: control.icon
            animate: true

            color: control.canUse
                ? Colours.palette.m3onSurface
                : Colours.palette.m3outline

            font.pointSize: Appearance.font.size.normal
        }
    }

    // ─────────────────────────────────────────────────
    // Compact play button
    // ─────────────────────────────────────────────────

    component PlayControl: Item {
        id: playControl

        required property string icon
        required property bool canUse

        function onClicked(): void {}

        implicitWidth: 36
        implicitHeight: 36

        StyledRect {
            anchors.fill: parent

            radius: Appearance.rounding.full

            color: playControl.canUse
                ? Colours.palette.m3primary
                : Colours.palette.m3surfaceContainerHigh
        }

        StateLayer {
            anchors.fill: parent

            disabled: !playControl.canUse
            radius: Appearance.rounding.full

            function onClicked(): void {
                playControl.onClicked();
            }
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: playControl.icon
            animate: true
            fill: 1

            color: playControl.canUse
                ? Colours.palette.m3onPrimary
                : Colours.palette.m3outline

            font.pointSize: Appearance.font.size.normal
        }
    }
}
