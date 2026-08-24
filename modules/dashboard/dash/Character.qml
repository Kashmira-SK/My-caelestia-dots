import qs.components
import qs.services
import qs.config
import Caelestia.Services
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties state

    ServiceRef {
        service: Audio.beatTracker
    }

    AnimatedImage {
        id: gif

        anchors.fill: parent
        anchors.margins: Appearance.padding.normal

        playing: Players.active?.isPlaying ?? false
        speed: Audio.beatTracker.bpm / Appearance.anim.mediaGifSpeedAdjustment
        source: [
            "/home/kashmira/.config/quickshell/caelestia/assets/Citlali.gif",
            "/home/kashmira/.config/quickshell/caelestia/assets/EvernightGlass.gif",
            "/home/kashmira/.config/quickshell/caelestia/assets/rikka.gif",
            "/home/kashmira/.config/quickshell/caelestia/assets/yeee.gif",
            "/home/kashmira/.config/quickshell/caelestia/assets/Cartwheel.gif",
            "/home/kashmira/.config/quickshell/caelestia/assets/Miku.gif",
            "/home/kashmira/.config/quickshell/caelestia/assets/bongocat1.gif"
        ][root.state.gifIndex]
        asynchronous: true
        fillMode: AnimatedImage.PreserveAspectFit
    }

    StyledRect {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: Appearance.padding.normal

        implicitWidth: swapIcon.implicitWidth + Appearance.padding.small * 2
        implicitHeight: implicitWidth
        radius: Appearance.rounding.full
        color: Colours.tPalette.m3surfaceContainerHigh

        StateLayer {
            radius: Appearance.rounding.full
            function onClicked(): void {
                root.state.gifIndex = (root.state.gifIndex + 1) % 7;
            }
        }

        MaterialIcon {
            id: swapIcon
            anchors.centerIn: parent
            text: "swap_horiz"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
        }
    }
}
