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
    Column {
        anchors.centerIn: parent

        width: parent.width - 24
        spacing: 8

        StyledClippingRect {
            id: cover

            anchors.horizontalCenter: parent.horizontalCenter

            width: 88
            height: 88

            radius: 20

            color: Colours.palette.m3surfaceContainerHigh

            MaterialIcon {
                anchors.centerIn: parent

                text: "library_music"
                font.pointSize: 28

                color: Colours.palette.m3outline
            }

            Image {
                anchors.fill: parent

                source: Players.active?.trackArtUrl ?? ""

                asynchronous: true
                fillMode: Image.PreserveAspectCrop

                sourceSize.width: 176
                sourceSize.height: 176
            }
        }

        StyledText {
            width: parent.width

            text: Players.active?.trackTitle
                || qsTr("Nothing playing")

            horizontalAlignment: Text.AlignHCenter

            color: Colours.palette.m3onSurface

            font.pointSize: Appearance.font.size.normal
            font.weight: 650

            maximumLineCount: 1
            elide: Text.ElideRight
        }

        StyledText {
            width: parent.width - 16

            anchors.horizontalCenter: parent.horizontalCenter

            text: Players.active?.trackArtist
                || qsTr("No media")

            horizontalAlignment: Text.AlignHCenter

            color: Colours.palette.m3secondary

            font.pointSize: Appearance.font.size.smaller

            maximumLineCount: 2
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }

        Item {
            width: parent.width
            height: 8

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
            width: parent.width
            height: 38

            StyledRect {
                anchors.centerIn: parent

                width: 138
                height: 38

                radius: 19

                color: Colours.palette.m3surfaceContainerHigh
            }

            Row {
                anchors.centerIn: parent

                spacing: 4

                MediaTextButton {
                    text: "PREV"
                    canUse: Players.active?.canGoPrevious ?? false

                    function onClicked(): void {
                        Players.active?.previous();
                    }
                }

                MediaTextButton {
                    text: Players.active?.isPlaying ? "PAUSE" : "PLAY"
                    accent: true
                    canUse: Players.active?.canTogglePlaying ?? false

                    function onClicked(): void {
                        Players.active?.togglePlaying();
                    }
                }

                MediaTextButton {
                    text: "NEXT"
                    canUse: Players.active?.canGoNext ?? false

                    function onClicked(): void {
                        Players.active?.next();
                    }
                }
            }
        }
    }

    component MediaTextButton: Item {
        id: button

        required property string text
        required property bool canUse
        property bool accent: false

        width: accent ? 48 : 38
        height: 28

        StyledText {
            anchors.centerIn: parent

            text: button.text

            color: !button.canUse
                ? Colours.palette.m3outline
                : button.accent
                    ? Colours.palette.m3primary
                    : Colours.palette.m3onSurfaceVariant

            font.pointSize: Appearance.font.size.smaller
            font.weight: accent ? 700 : 600

            opacity: button.canUse ? 1 : 0.45
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
