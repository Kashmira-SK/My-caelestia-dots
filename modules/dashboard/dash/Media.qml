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

    // Vertical "hero" layout instead of the old thumbnail+text row —
    // that row design was built for a ~110px hugging card and only ever
    // gave the title a narrow sliver next to the art, hence the eliding
    // even with a huge card around it. Flex spacers top/bottom keep this
    // centered in whatever height it's given instead of pinned to the
    // top with dead air below.
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        Item { Layout.fillHeight: true; Layout.minimumHeight: 0 }

        StyledClippingRect {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 110
            Layout.preferredHeight: 110
            radius: Appearance.rounding.normal
            color: Colours.palette.m3surfaceContainerHigh

            Image {
                anchors.fill: parent
                source: Players.active?.trackArtUrl ?? ""
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 220
                sourceSize.height: 220
            }

            MaterialIcon {
                anchors.centerIn: parent
                visible: !Players.active?.trackArtUrl
                text: "album"
                font.pointSize: Appearance.font.size.extraLarge
                color: Colours.palette.m3outline
            }

            // Playing indicator moved to a corner badge on the art
            // instead of squeezed inline next to the title — same
            // pattern as the SYSTEM avatar's status dot.
            StyledRect {
                visible: Players.active?.isPlaying ?? false
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 4
                implicitWidth: 14
                implicitHeight: 14
                radius: 7
                color: Colours.palette.m3primary

                SequentialAnimation on opacity {
                    running: Players.active?.isPlaying ?? false
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 700; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutQuad }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.small
            spacing: 4

            // Full column width now instead of squeezed beside the art —
            // wraps to 2 lines before it ever needs to elide.
            StyledText {
                Layout.fillWidth: true
                text: Players.active?.trackTitle || qsTr("Nothing playing")
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.normal
                font.weight: 700
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: Players.active?.trackArtist || qsTr("No media")
                color: Colours.palette.m3secondary
                font.pointSize: Appearance.font.size.small
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 1
                elide: Text.ElideRight
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 10
            Layout.topMargin: Appearance.spacing.small

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
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Appearance.spacing.normal
            spacing: Appearance.spacing.large

            TransportButton {
                icon: "skip_previous"
                size: 34
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
                size: 34
                canUse: Players.active?.canGoNext ?? false
                function onClicked(): void { Players.active?.next(); }
            }
        }

        Item { Layout.fillHeight: true; Layout.minimumHeight: 0 }
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

        implicitWidth: 48
        implicitHeight: 48

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
