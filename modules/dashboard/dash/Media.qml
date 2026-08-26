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
        return active?.length ? active.position / active.length : 0;
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
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        // Album art + info
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            StyledClippingRect {
                id: cover

                Layout.preferredWidth: 72
                Layout.preferredHeight: 72
                Layout.alignment: Qt.AlignTop

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainerHigh

                MaterialIcon {
                    anchors.centerIn: parent
                    grade: 200
                    text: "art_track"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: 24
                }

                Image {
                    anchors.fill: parent
                    source: Players.active?.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: width
                    sourceSize.height: height
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.smaller

                StyledText {
                    Layout.fillWidth: true
                    animate: true
                    text: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 500
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    animate: true
                    text: (Players.active?.trackAlbum ?? qsTr("Unknown album"))
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    animate: true
                    text: (Players.active?.trackArtist ?? qsTr("Unknown artist"))
                    color: Colours.palette.m3secondary
                    font.pointSize: Appearance.font.size.small
                    // Was single-line elide, which chopped longer artist
                    // credits (e.g. "Alan Walker Ft Ava Max"). Two lines
                    // gives it room to actually show instead of cutting off.
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }

        // Progress bar
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 4

            StyledRect {
                anchors.fill: parent
                radius: Appearance.rounding.full
                color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
            }

            StyledRect {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * root.playerProgress

                radius: Appearance.rounding.full
                color: Colours.palette.m3primary

                Behavior on width {
                    Anim {
                        duration: Appearance.anim.durations.large
                    }
                }
            }
        }

        // Controls
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: Appearance.spacing.normal

            Control {
                icon: "skip_previous"
                canUse: Players.active?.canGoPrevious ?? false
                function onClicked(): void { Players.active?.previous(); }
            }

            Control {
                icon: Players.active?.isPlaying ? "pause" : "play_arrow"
                canUse: Players.active?.canTogglePlaying ?? false
                function onClicked(): void { Players.active?.togglePlaying(); }
            }

            Control {
                icon: "skip_next"
                canUse: Players.active?.canGoNext ?? false
                function onClicked(): void { Players.active?.next(); }
            }
        }

        Item { Layout.fillHeight: true }
    }

    component Control: Item {
        id: control

        required property string icon
        required property bool canUse
        function onClicked(): void {}

        implicitWidth: controlIcon.implicitHeight + Appearance.padding.small * 2
        implicitHeight: implicitWidth

        StateLayer {
            disabled: !control.canUse
            radius: Appearance.rounding.full
            function onClicked(): void { control.onClicked(); }
        }

        MaterialIcon {
            id: controlIcon
            anchors.centerIn: parent
            animate: true
            text: control.icon
            color: control.canUse ? Colours.palette.m3onSurface : Colours.palette.m3outline
            font.pointSize: Appearance.font.size.large
        }
    }
}
