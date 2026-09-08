pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root
    required property var lock

    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: layout.implicitHeight + Appearance.padding.normal * 2
    color: Qt.alpha(Colours.palette.m3surfaceContainerHigh, 0.55)
    radius: Appearance.rounding.normal
    border.width: 1
    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.45)

    RowLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(implicitWidth, Math.max(0, parent.width - Appearance.padding.normal * 2))
        anchors.top: parent.top
        anchors.margins: Appearance.padding.normal
        spacing: Appearance.spacing.normal

        StyledClippingRect {
            Layout.preferredWidth: Appearance.font.size.normal * 6
            Layout.preferredHeight: Appearance.font.size.normal * 6
            radius: Appearance.rounding.small
            color: Colours.palette.m3surfaceContainer

            MaterialIcon {
                anchors.centerIn: parent
                text: "music_note"
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.extraLarge
                visible: artwork.status !== Image.Ready
            }

            Image {
                id: artwork
                anchors.fill: parent
                source: Players.active?.trackArtUrl ?? ""
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: width * 2
                sourceSize.height: height * 2
                visible: status === Image.Ready
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            StyledText {
                Layout.fillWidth: true
                text: Players.active?.trackTitle || qsTr("Unknown track")
                horizontalAlignment: Text.AlignHCenter
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.normal
                font.weight: 500
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: Players.active?.trackArtist || qsTr("Unknown artist")
                horizontalAlignment: Text.AlignHCenter
                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.75)
                font.pointSize: Appearance.font.size.small
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Appearance.spacing.small

                PlayerControl {
                    icon: "skip_previous"
                    enabled: Players.active?.canGoPrevious ?? false
                    function onClicked(): void { Players.active?.previous(); }
                }

                PlayerControl {
                    prominent: true
                    icon: Players.active?.isPlaying ? "pause" : "play_arrow"
                    enabled: Players.active?.canTogglePlaying ?? false
                    function onClicked(): void { Players.active?.togglePlaying(); }
                }

                PlayerControl {
                    icon: "skip_next"
                    enabled: Players.active?.canGoNext ?? false
                    function onClicked(): void { Players.active?.next(); }
                }
            }
        }
    }

    component PlayerControl: StyledRect {
        id: control
        property alias icon: controlIcon.text
        property bool prominent: false

        function onClicked(): void {}

        implicitWidth: Appearance.font.size.normal * 2.5
        implicitHeight: Appearance.font.size.normal * 2.5
        radius: Appearance.rounding.full
        color: Qt.alpha(Colours.palette.m3primary, prominent ? 0.16 : 0)
        opacity: enabled ? 1 : 0.35

        StateLayer {
            color: Colours.palette.m3onSurface
            function onClicked(): void { control.onClicked(); }
        }

        MaterialIcon {
            id: controlIcon
            anchors.centerIn: parent
            color: control.prominent ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.larger
        }
    }
}
