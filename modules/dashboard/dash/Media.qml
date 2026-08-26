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
        Anim { duration: Appearance.anim.durations.large }
    }

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: Config.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    // Flat, clean background matching the rest of the dashboard — the
    // blurred-art treatment didn't land, back to plain surface color.
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.small

        // Small square art thumbnail up top-left, kept modest since the
        // blurred version already fills the whole card behind everything
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            StyledClippingRect {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: Appearance.rounding.small
                color: Colours.palette.m3surfaceContainerHigh

                Image {
                    anchors.fill: parent
                    source: Players.active?.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 80
                    sourceSize.height: 80
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    visible: !Players.active?.trackArtUrl
                    text: "album"
                    font.pointSize: Appearance.font.size.normal
                    color: Colours.palette.m3outline
                }
            }

            StyledRect {
                Layout.alignment: Qt.AlignVCenter
                visible: Players.active?.isPlaying ?? false
                implicitWidth: 6
                implicitHeight: 6
                radius: 3
                color: Colours.palette.m3primary

                SequentialAnimation on opacity {
                    running: Players.active?.isPlaying ?? false
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 700; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutQuad }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Track info sits over the blurred art, bottom-anchored
        StyledText {
            Layout.fillWidth: true
            text: Players.active?.trackTitle || qsTr("Nothing playing")
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.normal
            font.weight: 650
            maximumLineCount: 1
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true
            text: Players.active?.trackArtist || qsTr("No media")
            color: Colours.palette.m3secondary
            font.pointSize: Appearance.font.size.smaller
            maximumLineCount: 1
            elide: Text.ElideRight
        }

        // Progress
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            Layout.topMargin: 2

            StyledRect {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 3
                radius: Appearance.rounding.full
                color: Qt.alpha(Colours.palette.m3onSurface, 0.2)
            }

            StyledRect {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 3
                width: parent.width * root.playerProgress
                radius: Appearance.rounding.full
                color: Colours.palette.m3primary

                Behavior on width { Anim { duration: Appearance.anim.durations.large } }
            }
        }

        // Compact floating control pill — one slim bar instead of a
        // whole dedicated section, so controls stop eating most of
        // the card's height.
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.small
            Layout.alignment: Qt.AlignHCenter
            spacing: Appearance.spacing.large

            TransportButton {
                icon: "skip_previous"
                canUse: Players.active?.canGoPrevious ?? false
                function onClicked(): void { Players.active?.previous(); }
            }

            PlayButton {
                canUse: Players.active?.canTogglePlaying ?? false
                playing: Players.active?.isPlaying ?? false
                function onClicked(): void { Players.active?.togglePlaying(); }
            }

            TransportButton {
                icon: "skip_next"
                canUse: Players.active?.canGoNext ?? false
                function onClicked(): void { Players.active?.next(); }
            }
        }
    }

    component TransportButton: Item {
        id: button

        required property string icon
        required property bool canUse
        function onClicked(): void {}

        implicitWidth: 28
        implicitHeight: 28

        StateLayer {
            disabled: !button.canUse
            radius: Appearance.rounding.full
            function onClicked(): void { button.onClicked(); }
        }

        MaterialIcon {
            anchors.centerIn: parent
            animate: true
            fill: 1
            text: button.icon
            color: button.canUse ? Colours.palette.m3onSurface : Colours.palette.m3outline
            font.pointSize: Appearance.font.size.normal
        }
    }

    component PlayButton: Item {
        id: button

        required property bool canUse
        required property bool playing
        function onClicked(): void {}

        implicitWidth: 34
        implicitHeight: 34

        StyledRect {
            anchors.fill: parent
            radius: width / 2
            color: Colours.palette.m3primary
        }

        StateLayer {
            disabled: !button.canUse
            radius: Appearance.rounding.full
            function onClicked(): void { button.onClicked(); }
        }

        MaterialIcon {
            anchors.centerIn: parent
            animate: true
            fill: 1
            text: button.playing ? "pause" : "play_arrow"
            color: Colours.palette.m3onPrimary
            font.pointSize: Appearance.font.size.normal
        }
    }
}
