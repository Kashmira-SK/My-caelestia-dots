pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.modules.utilities.cards
import qs.services
import qs.config
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "." as PopoutParts

Item {
    id: root

    required property var wrapper

    implicitWidth: Config.bar.sizes.networkWidth
    width: implicitWidth
    implicitHeight: layout.implicitHeight + Appearance.padding.normal * 2 + frame.headingHeight

    UtilityFrame {
        id: frame
        title: qsTr("AUDIO")
    }

    ButtonGroup {
        id: sinks
    }

    ButtonGroup {
        id: sources
    }

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Appearance.padding.normal
        anchors.rightMargin: Appearance.padding.normal
        anchors.topMargin: frame.headingHeight + Appearance.padding.normal
        spacing: Appearance.spacing.small

        ConnectionPopoutHeader {
            title: qsTr("Output volume")
            detail: Audio.muted && !volumeSync.waiting ? qsTr("Muted") : `${Math.round((volumeSlider.pressed || volumeSync.waiting ? volumeSlider.value : Audio.volume) * 100)}%`

            ConnectionAction {
                glyph: "settings"
                text: qsTr("Open audio settings")
                onClicked: root.wrapper.detach("audio")
            }
        }

        CustomMouseArea {
            Layout.fillWidth: true
            implicitHeight: Appearance.padding.normal * 3

            onWheel: event => {
                if (event.angleDelta.y > 0)
                    Audio.incrementVolume();
                else if (event.angleDelta.y < 0)
                    Audio.decrementVolume();
            }

            PopoutParts.PopupVolumeSlider {
                id: volumeSlider
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: parent.implicitHeight

                PopoutParts.VolumeSliderSync {
                    id: volumeSync
                    slider: volumeSlider
                    backendValue: Audio.volume
                    backendPending: Audio.volumePending
                    deviceId: Audio.sink?.id ?? -1
                    onRequested: value => Audio.setVolume(value)
                }
            }
        }

        StyledText {
            Layout.topMargin: Appearance.spacing.small
            text: qsTr("OUTPUT")
            color: Colours.palette.m3outline
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.small
            font.letterSpacing: 1
        }

        Repeater {
            model: Audio.sinks

            PopoutParts.AudioDeviceChoice {
                id: control

                required property PwNode modelData
                glyph: "volume-2"

                ButtonGroup.group: sinks
                checked: Audio.sink?.id === modelData.id
                onClicked: Audio.setAudioSink(modelData)
                text: modelData.description
            }
        }

        StyledText {
            Layout.topMargin: Appearance.spacing.smaller
            text: qsTr("INPUT")
            color: Colours.palette.m3outline
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.small
            font.letterSpacing: 1
        }

        Repeater {
            model: Audio.sources

            PopoutParts.AudioDeviceChoice {
                required property PwNode modelData
                glyph: "mic"

                ButtonGroup.group: sources
                checked: Audio.source?.id === modelData.id
                onClicked: Audio.setAudioSource(modelData)
                text: modelData.description
            }
        }
    }
}
