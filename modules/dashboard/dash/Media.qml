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

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        // Media card
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Track header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 72
                spacing: 12

                StyledClippingRect {
                    id: cover

                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 72
                    Layout.alignment: Qt.AlignVCenter

                    radius: 16
                    color: Colours.palette.m3surfaceContainerHigh

                    MaterialIcon {
                        anchors.centerIn: parent

                        text: "album"
                        font.pointSize: 22

                        color: Colours.palette.m3outline
                    }

                    Image {
                        anchors.fill: parent

                        source: Players.active?.trackArtUrl ?? ""

                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop

                        sourceSize.width: 144
                        sourceSize.height: 144
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    spacing: 3

                    StyledText {
                        Layout.fillWidth: true

                        text: Players.active?.trackTitle
                            || qsTr("Nothing playing")

                        color: Colours.palette.m3onSurface

                        font.pointSize: Appearance.font.size.normal + 1
                        font.weight: 650

                        maximumLineCount: 2
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true

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
                Layout.fillWidth: true
                Layout.preferredHeight: 12

                StyledRect {
                    anchors.verticalCenter: parent.verticalCenter

                    width: parent.width
                    height: 4

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
                    height: 4

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

            // Transport
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Row {
                    anchors.centerIn: parent

                    spacing: 20

                    TransportButton {
                        icon: "replay_10"
                        canUse: Players.active?.canGoPrevious ?? false
                        iconSize: 17

                        function onClicked(): void {
                            Players.active?.previous();
                        }
                    }

                    PlayButton {
                        icon: Players.active?.isPlaying
                            ? "pause"
                            : "play_arrow"

                        canUse: Players.active?.canTogglePlaying ?? false
                    }

                    TransportButton {
                        icon: "forward_10"
                        canUse: Players.active?.canGoNext ?? false
                        iconSize: 17

                        function onClicked(): void {
                            Players.active?.next();
                        }
                    }
                }
            }
        }
    }

    component TransportButton: Item {
        id: button

        required property string icon
        required property bool canUse
        required property real iconSize

        width: 34
        height: 34

        StyledRect {
            anchors.fill: parent

            radius: width / 2

            color: "transparent"

            border.width: 1

            border.color: button.canUse
                ? Colours.palette.m3outlineVariant
                : Colours.palette.m3surfaceContainerHigh
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

        width: 46
        height: 46

        StyledRect {
            anchors.fill: parent

            radius: width / 2

            color: "transparent"

            border.width: 2

            border.color: button.canUse
                ? Colours.palette.m3primary
                : Colours.palette.m3outline
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: button.icon
            fill: 1

            font.pointSize: 19

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

        function onClicked(): void {
            Players.active?.togglePlaying();
        }
    }
}
