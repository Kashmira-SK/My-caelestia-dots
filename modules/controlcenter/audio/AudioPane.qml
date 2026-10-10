pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    anchors.fill: parent

    SettingsPage {
        title: root.session.sectionFor("audio") === "output" ? qsTr("Speakers & headphones") : root.session.sectionFor("audio") === "input" ? qsTr("Microphone") : qsTr("Application volumes")
        anchors.fill: parent
        SettingsGroup {
            visible: root.session.sectionFor("audio") === "output"
            title: qsTr("Volume")
            VolumeBox {
                outputMode: true
                enabled: !!Audio.sink
                opacity: enabled ? 1 : 0.45
            }
        }
        SettingsGroup {
            visible: root.session.sectionFor("audio") === "output"
            contentPadding: 12
            title: qsTr("Output device")
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                // Available devices stay visible beside their active selection.
                property string title: qsTr("Choose device")
                property string description: qsTr("%1 available").arg(Audio.sinks.length)
                Repeater {
                    // Keep the current device first while retaining every available device.
                    model: [...Audio.sinks].sort((a, b) => Number(b.id === Audio.sink?.id) - Number(a.id === Audio.sink?.id))
                    DeviceRow {
                        required property var modelData
                        Layout.fillWidth: true
                        device: modelData
                        selected: !!Audio.sink && Audio.sink.id === modelData.id
                        iconName: "speaker"
                        fallbackName: qsTr("Unknown device")
                        onClicked: Audio.setAudioSink(modelData)
                    }
                }
                StyledText {
                    visible: Audio.sinks.length === 0
                    Layout.fillWidth: true
                    text: qsTr("Connect a device to select it here.")
                    color: Colours.palette.m3onSurfaceVariant
                    wrapMode: Text.WordWrap
                }
            }

        }
        SettingsGroup {
            visible: root.session.sectionFor("audio") === "input"
            title: qsTr("Volume")
            VolumeBox {
                outputMode: false
                enabled: !!Audio.source
                opacity: enabled ? 1 : 0.45
            }
        }
        SettingsGroup {
            visible: root.session.sectionFor("audio") === "input"
            contentPadding: 12
            title: qsTr("Input device")
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                // Available devices stay visible beside their active selection.
                property string title: qsTr("Choose device")
                property string description: qsTr("%1 available").arg(Audio.sources.length)
                Repeater {
                    // Keep the current device first while retaining every available device.
                    model: [...Audio.sources].sort((a, b) => Number(b.id === Audio.source?.id) - Number(a.id === Audio.source?.id))
                    DeviceRow {
                        required property var modelData
                        Layout.fillWidth: true
                        device: modelData
                        selected: !!Audio.source && Audio.source.id === modelData.id
                        iconName: "mic"
                        fallbackName: qsTr("Unknown device")
                        onClicked: Audio.setAudioSource(modelData)
                    }
                }
                StyledText {
                    visible: Audio.sources.length === 0
                    Layout.fillWidth: true
                    text: qsTr("Connect a device to select it here.")
                    color: Colours.palette.m3onSurfaceVariant
                    wrapMode: Text.WordWrap
                }
            }

        }
        SettingsGroup {
            visible: root.session.sectionFor("audio") === "applications"
            contentPadding: 16
            title: qsTr("Playing applications")
            Repeater {
                model: Audio.streams
                StreamRow {
                    required property var modelData
                    Layout.fillWidth: true
                    stream: modelData
                }
            }
            StyledText {
                visible: Audio.streams.length === 0
                Layout.fillWidth: true
                text: qsTr("Applications appear here when they play audio.")
                color: Colours.palette.m3onSurfaceVariant
                wrapMode: Text.WordWrap
            }
        }
    }

    component DeviceRow: Controls.AbstractButton {
        id: deviceRow
        required property var device
        required property bool selected
        required property string iconName
        required property string fallbackName
        implicitHeight: Math.max(56, deviceLabel.implicitHeight + 24)
        Accessible.name: deviceLabel.text
        Accessible.role: Accessible.RadioButton
        Accessible.checked: selected
        background: Rectangle {
            radius: 6
            color: Qt.alpha(Colours.palette.m3primary, deviceRow.selected ? 0.12 : deviceRow.hovered ? 0.06 : 0)
            border.width: deviceRow.activeFocus ? 1 : 0
            border.color: Colours.palette.m3primary
        }
        contentItem: RowLayout {
            spacing: 12
            MaterialIcon { text: deviceRow.iconName; color: Colours.palette.m3onSurfaceVariant; font.pointSize: 12 }
            StyledText {
                id: deviceLabel
                Layout.fillWidth: true
                text: deviceRow.device?.description || deviceRow.device?.name || deviceRow.fallbackName
                wrapMode: Text.WordWrap
                font.pointSize: 10.5 * Appearance.font.size.scale
            }
            MaterialIcon { text: deviceRow.selected ? "radio_button_checked" : "radio_button_unchecked"; color: deviceRow.selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant; font.pointSize: 12 }
        }
        leftPadding: 12
        rightPadding: 12
    }


    component SectionLabel: Item {
        id: section

        required property string text
        property string detail: ""

        Layout.fillWidth: true
        implicitHeight: 24

        RowLayout {
            anchors.fill: parent
            spacing: 8

            StyledText {
                text: section.text
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: 9 * Appearance.font.size.scale
                font.weight: 500
                font.letterSpacing: 0.7
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.24
                )
            }

            StyledText {
                visible: section.detail !== ""
                text: section.detail
                color: Colours.palette.m3onSurfaceVariant
                font.family: Appearance.font.family.mono
                font.pointSize: 9 * Appearance.font.size.scale
            }
        }
    }

    component SectionHeading: ColumnLayout {
        id: heading

        required property string title
        property string description: ""

        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.larger
        Layout.bottomMargin: Appearance.spacing.small
        spacing: 3

        StyledText {
            text: heading.title
            color: Colours.palette.m3onSurface
            font.pointSize: 12 * Appearance.font.size.scale
            font.weight: 500
        }

        StyledText {
            visible: heading.description !== ""
            Layout.fillWidth: true
            text: heading.description
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: 9.75 * Appearance.font.size.scale
            elide: Text.ElideRight
        }
    }

    component VolumeBox: StyledRect {
        id: volumeBox

        required property bool outputMode

        readonly property real currentVolume:
            outputMode ? Audio.volume : Audio.sourceVolume

        readonly property bool currentMuted:
            outputMode ? Audio.muted : Audio.sourceMuted

        Layout.fillWidth: true
        implicitHeight: volumeContent.implicitHeight
            + Appearance.padding.large * 2

        radius: Appearance.rounding.small
        color: "transparent"
        border.width: 0
        border.color: Qt.alpha(
            Colours.palette.m3outlineVariant,
            0.16
        )

        ColumnLayout {
            id: volumeContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.larger
            spacing: Appearance.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    text: volumeBox.outputMode
                        ? (volumeBox.currentMuted
                            ? "volume_off"
                            : "volume_up")
                        : (volumeBox.currentMuted
                            ? "mic_off"
                            : "mic")
                    color: volumeBox.currentMuted
                        ? Colours.palette.m3onSurfaceVariant
                        : Colours.palette.m3primary
                    fill: volumeBox.currentMuted ? 0 : 1
                    font.pointSize: 10.5 * Appearance.font.size.scale
                }

                StyledText {
                    Layout.fillWidth: true
                    text: volumeBox.currentMuted
                        ? qsTr("Muted")
                        : qsTr("%1%").arg(
                            Math.round(volumeBox.currentVolume * 100)
                        )
                    color: Colours.palette.m3onSurface
                    font.family: Appearance.font.family.mono
                    font.pointSize: 9.75 * Appearance.font.size.scale
                    font.weight: 500
                }

                CompactButton {
                    iconName: volumeBox.currentMuted
                        ? (volumeBox.outputMode
                            ? "volume_up"
                            : "mic")
                        : (volumeBox.outputMode
                            ? "volume_off"
                            : "mic_off")
                    active: volumeBox.currentMuted

                    onClicked: {
                        if (volumeBox.outputMode) {
                            if (Audio.sink?.audio)
                                Audio.sink.audio.muted =
                                    !Audio.sink.audio.muted;
                        } else {
                            if (Audio.source?.audio)
                                Audio.source.audio.muted =
                                    !Audio.source.audio.muted;
                        }
                    }
                }
            }

            StyledSlider {
                Layout.fillWidth: true
                implicitHeight: Appearance.padding.normal * 3

                value: volumeBox.currentVolume
                enabled: !volumeBox.currentMuted
                opacity: enabled ? 1 : 0.6

                onMoved: {
                    if (volumeBox.outputMode)
                        Audio.setVolume(value);
                    else
                        Audio.setSourceVolume(value);
                }
            }
        }
    }

    component StreamRow: Item {
        id: streamRow
        required property var stream
        readonly property bool streamMuted: stream ? Audio.getStreamMuted(stream) : false
        readonly property real streamVolume: stream ? Audio.getStreamVolume(stream) : 0
        Layout.fillWidth: true
        // Give every stream its own measured space, even with long app names.
        implicitHeight: streamHeader.implicitHeight + 62
        RowLayout {
            id: streamHeader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 12
            spacing: 12
            MaterialIcon { text: "apps"; font.pointSize: 12; color: Colours.palette.m3onSurfaceVariant }
            StyledText {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: 1
                text: streamRow.stream ? Audio.getStreamName(streamRow.stream) : qsTr("Unknown application")
                font.pointSize: 10.5 * Appearance.font.size.scale
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
                maximumLineCount: 1
            }
            StyledText {
                Layout.minimumWidth: 48
                text: qsTr("%1%").arg(Math.round(streamRow.streamVolume * 100))
                horizontalAlignment: Text.AlignRight
                font.pointSize: 9.75 * Appearance.font.size.scale
                font.family: Appearance.font.family.mono
                color: Colours.palette.m3onSurfaceVariant
            }
            CompactButton {
                iconName: streamRow.streamMuted ? "volume_up" : "volume_off"
                active: streamRow.streamMuted
                onClicked: if (streamRow.stream) Audio.setStreamMuted(streamRow.stream, !streamRow.streamMuted)
            }
        }
        StyledSlider {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: streamHeader.bottom
            anchors.topMargin: 8
            height: 26
            value: streamRow.streamVolume
            enabled: !streamRow.streamMuted
            opacity: enabled ? 1 : 0.6
            onMoved: if (streamRow.stream) Audio.setStreamVolume(streamRow.stream, value)
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Qt.alpha(Colours.palette.m3outlineVariant, 0.35)
        }
    }

    component CompactButton: Controls.AbstractButton {
        id: button
        required property string iconName
        property bool active: false
        implicitWidth: 36
        implicitHeight: 32
        Accessible.name: active ? qsTr("Unmute") : qsTr("Mute")
        SettingsToolTip { visible: button.hovered; text: button.Accessible.name }
        background: Rectangle { radius: 6; color: Qt.alpha(Colours.palette.m3primary, button.active ? 0.14 : button.hovered ? 0.1 : 0.04); border.width: button.activeFocus ? 1 : 0; border.color: Colours.palette.m3primary }
        contentItem: MaterialIcon { text: button.iconName; color: button.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant; font.pointSize: 13.5 }
    }
}
