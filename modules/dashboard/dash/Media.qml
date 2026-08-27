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

    implicitHeight: content.implicitHeight + Appearance.padding.large * 2

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

    ColumnLayout {
        id: content

        anchors.centerIn: parent
        width: parent.width - Appearance.padding.large * 2
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            StyledClippingRect {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                radius: Appearance.rounding.normal
                color: Colours.palette.m3surfaceContainerHigh

                Image {
                    anchors.fill: parent
                    source: Players.active?.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 128
                    sourceSize.height: 128
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    visible: !Players.active?.trackArtUrl
                    text: "album"
                    font.pointSize: Appearance.font.size.large
                    color: Colours.palette.m3outline
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledText {
                        Layout.fillWidth: true
                        text: Players.active?.trackTitle || qsTr("Nothing playing")
                        color: Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 700
                        maximumLineCount: 1
                        elide: Text.ElideRight
                    }

                    StyledRect {
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

                StyledText {
                    Layout.fillWidth: true
                    text: Players.active?.trackArtist || qsTr("No media")
                    color: Colours.palette.m3secondary
                    font.pointSize: Appearance.font.size.small
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 10
            Layout.topMargin: 2

            StyledRect {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 4
                radius: Appearance.rounding.full
                color: Qt.alpha(Colours.palette.m3onSurface, 0.2)
            }

            StyledRect {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 4
                width: parent.width * root.playerProgress
                radius: Appearance.rounding.full
                color: Colours.palette.m3primary

                Behavior on width { Anim { duration: Appearance.anim.durations.large } }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.normal
            Layout.alignment: Qt.AlignHCenter
            spacing: Appearance.spacing.large

            TransportButton {
                icon: "skip_previous"
                size: 32
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
                size: 32
                canUse: Players.active?.canGoNext ?? false
                function onClicked(): void { Players.active?.next(); }
            }
        }
    }

    component TransportButton: Item {
        id: button

        required property string icon
        required property bool canUse
        property int size: 28
        function onClicked(): void {}

        implicitWidth: size
        implicitHeight: size

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
            font.pointSize: Appearance.font.size.large
        }
    }

    component PlayButton: Item {
        id: button

        required property bool canUse
        required property bool playing
        function onClicked(): void {}

        implicitWidth: 44
        implicitHeight: 44

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
            font.pointSize: Appearance.font.size.large
        }
    }
}
