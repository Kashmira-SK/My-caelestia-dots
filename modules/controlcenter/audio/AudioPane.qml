pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.large
        anchors.rightMargin: Appearance.padding.large
        anchors.topMargin: Appearance.padding.normal
        anchors.bottomMargin: Appearance.padding.large
        spacing: Appearance.spacing.large

        // devices
        StyledFlickable {
            id: devicesFlickable

            Layout.preferredWidth: Math.max(260, root.width * 0.34)
            Layout.minimumWidth: 240
            Layout.fillHeight: true

            flickableDirection: Flickable.VerticalFlick
            contentHeight: devicesColumn.implicitHeight
            clip: true

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: devicesFlickable
            }

            ColumnLayout {
                id: devicesColumn

                width: devicesFlickable.width
                spacing: Appearance.spacing.larger


                SectionLabel {
                    text: qsTr("OUTPUT")
                    detail: qsTr("%1").arg(Audio.sinks.length)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Repeater {
                        model: Audio.sinks

                        delegate: DeviceRow {
                            required property var modelData

                            Layout.fillWidth: true

                            device: modelData
                            selected: modelData
                                && Audio.sink
                                && Audio.sink.id === modelData.id
                            icon: selected ? "speaker" : "speaker_group"
                            fallbackName: qsTr("Unknown output")

                            onClicked: {
                                if (modelData)
                                    Audio.setAudioSink(modelData);
                            }
                        }
                    }

                    StyledText {
                        visible: Audio.sinks.length === 0
                        Layout.fillWidth: true
                        Layout.topMargin: Appearance.spacing.normal
                        Layout.bottomMargin: Appearance.spacing.normal
                        text: qsTr("No output devices")
                        color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.34)
                        font.pointSize: Appearance.font.size.smaller
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                SectionLabel {
                    Layout.topMargin: Appearance.spacing.normal
                    text: qsTr("INPUT")
                    detail: qsTr("%1").arg(Audio.sources.length)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Repeater {
                        model: Audio.sources

                        delegate: DeviceRow {
                            required property var modelData

                            Layout.fillWidth: true

                            device: modelData
                            selected: modelData
                                && Audio.source
                                && Audio.source.id === modelData.id
                            icon: "mic"
                            fallbackName: qsTr("Unknown input")

                            onClicked: {
                                if (modelData)
                                    Audio.setAudioSource(modelData);
                            }
                        }
                    }

                    StyledText {
                        visible: Audio.sources.length === 0
                        Layout.fillWidth: true
                        Layout.topMargin: Appearance.spacing.normal
                        Layout.bottomMargin: Appearance.spacing.normal
                        text: qsTr("No input devices")
                        color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.34)
                        font.pointSize: Appearance.font.size.smaller
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: Appearance.padding.normal
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 1
            color: Colours.palette.m3outlineVariant
            opacity: 0.18
        }

        // mixer
        StyledFlickable {
            id: mixerFlickable

            Layout.fillWidth: true
            Layout.fillHeight: true

            flickableDirection: Flickable.VerticalFlick
            contentHeight: mixerColumn.implicitHeight
            clip: true

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: mixerFlickable
            }

            ColumnLayout {
                id: mixerColumn

                width: mixerFlickable.width
                spacing: Appearance.spacing.larger


                SectionHeading {
                    title: qsTr("Output")
                    description: Audio.sink?.description
                        || qsTr("Default output device")
                }

                VolumeBox {
                    outputMode: true
                }

                SectionHeading {
                    title: qsTr("Input")
                    description: Audio.source?.description
                        || qsTr("Default input device")
                }

                VolumeBox {
                    outputMode: false
                }

                SectionHeading {
                    title: qsTr("Applications")
                    description: qsTr("Per-application playback volume")
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: streamsColumn.implicitHeight
                        + Appearance.padding.large * 2

                    radius: Appearance.rounding.small
                    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.58)
                    border.width: 1
                    border.color: Qt.alpha(
                        Colours.palette.m3outlineVariant,
                        0.16
                    )

                    ColumnLayout {
                        id: streamsColumn

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Appearance.padding.larger
                        spacing: Appearance.spacing.normal

                        Repeater {
                            model: Audio.streams

                            delegate: StreamRow {
                                required property var modelData

                                Layout.fillWidth: true
                                stream: modelData
                            }
                        }

                        StyledText {
                            visible: Audio.streams.length === 0
                            Layout.fillWidth: true
                            Layout.topMargin: Appearance.spacing.small
                            Layout.bottomMargin: Appearance.spacing.small
                            text: qsTr("No applications currently playing audio")
                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.34
                            )
                            font.pointSize: Appearance.font.size.smaller
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: Appearance.padding.normal
                }
            }
        }
    }

    component DeviceRow: Item {
        id: deviceRow

        required property var device
        required property bool selected
        required property string icon
        required property string fallbackName

        signal clicked

        implicitHeight: 48

        StyledRect {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Qt.alpha(
                Colours.palette.m3primary,
                deviceRow.selected
                    ? 0.055
                    : deviceMouse.containsMouse
                        ? 0.025
                        : 0
            )
        }

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: deviceRow.selected ? 22 : 0
            radius: 1
            color: Colours.palette.m3primary
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Appearance.padding.normal
            anchors.rightMargin: Appearance.padding.normal
            spacing: Appearance.spacing.small

            MaterialIcon {
                text: deviceRow.icon
                fill: deviceRow.selected ? 1 : 0
                color: deviceRow.selected
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.48
                    )
                font.pointSize: Appearance.font.size.normal
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: deviceRow.device?.description
                        || deviceRow.fallbackName
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.small
                    font.weight: deviceRow.selected ? 500 : 400
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                StyledText {
                    text: deviceRow.selected
                        ? qsTr("Selected")
                        : qsTr("Available")
                    color: deviceRow.selected
                        ? Colours.palette.m3primary
                        : Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.34
                        )
                    font.pointSize: Appearance.font.size.smaller
                }
            }

            MaterialIcon {
                visible: deviceRow.selected
                text: "check"
                color: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.small
            }
        }

        MouseArea {
            id: deviceMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: deviceRow.clicked()
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Qt.alpha(Colours.palette.m3outlineVariant, 0.14)
        }
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
                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.52
                )
                font.pointSize: Appearance.font.size.smaller
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
                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.30
                )
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.smaller
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
            font.pointSize: Appearance.font.size.larger
            font.weight: 500
        }

        StyledText {
            visible: heading.description !== ""
            Layout.fillWidth: true
            text: heading.description
            color: Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.44
            )
            font.pointSize: Appearance.font.size.small
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
        color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.58)
        border.width: 1
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
                        ? Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.42
                        )
                        : Colours.palette.m3primary
                    fill: volumeBox.currentMuted ? 0 : 1
                    font.pointSize: Appearance.font.size.normal
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
                    font.pointSize: Appearance.font.size.small
                    font.weight: 500
                }

                CompactButton {
                    icon: volumeBox.currentMuted
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
                opacity: enabled ? 1 : 0.38

                onMoved: {
                    if (volumeBox.outputMode)
                        Audio.setVolume(value);
                    else
                        Audio.setSourceVolume(value);
                }
            }
        }
    }

    component StreamRow: ColumnLayout {
        id: streamRow

        required property var stream

        readonly property bool streamMuted:
            stream ? Audio.getStreamMuted(stream) : false
        readonly property real streamVolume:
            stream ? Audio.getStreamVolume(stream) : 0

        Layout.fillWidth: true
        spacing: Appearance.spacing.smaller

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            MaterialIcon {
                text: "apps"
                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.48
                )
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                Layout.fillWidth: true
                text: streamRow.stream
                    ? Audio.getStreamName(streamRow.stream)
                    : qsTr("Unknown application")
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.small
                font.weight: 500
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            StyledText {
                text: qsTr("%1%").arg(
                    Math.round(streamRow.streamVolume * 100)
                )
                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.42
                )
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.smaller
            }

            CompactButton {
                icon: streamRow.streamMuted
                    ? "volume_up"
                    : "volume_off"
                active: streamRow.streamMuted

                onClicked: {
                    if (streamRow.stream) {
                        Audio.setStreamMuted(
                            streamRow.stream,
                            !streamRow.streamMuted
                        );
                    }
                }
            }
        }

        StyledSlider {
            Layout.fillWidth: true
            implicitHeight: Appearance.padding.normal * 2.6

            value: streamRow.streamVolume
            enabled: !streamRow.streamMuted
            opacity: enabled ? 1 : 0.38

            onMoved: {
                if (streamRow.stream)
                    Audio.setStreamVolume(streamRow.stream, value);
            }

            Connections {
                target: streamRow.stream?.audio ?? null

                function onVolumeChanged() {
                    if (streamRow.stream?.audio)
                        parent.value = streamRow.stream.audio.volume;
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.small
            implicitHeight: 1
            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.14
            )
        }
    }

    component CompactButton: Item {
        id: compactButton

        required property string icon
        property bool active: false

        signal clicked

        implicitWidth: 30
        implicitHeight: 30

        StyledRect {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Qt.alpha(
                Colours.palette.m3primary,
                compactMouse.containsMouse ? 0.07 : 0
            )
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: compactButton.icon
            color: compactButton.active
                ? Colours.palette.m3primary
                : Qt.alpha(
                    Colours.palette.m3onSurface,
                    compactMouse.containsMouse ? 1 : 0.62
                )
            font.pointSize: Appearance.font.size.small
        }

        MouseArea {
            id: compactMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: compactButton.clicked()
        }
    }
}
