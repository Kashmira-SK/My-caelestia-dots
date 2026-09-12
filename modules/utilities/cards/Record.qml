pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Item {
    id: root

    required property var props
    required property var visibilities

    // Keep the existing persisted icon+label keys and recorder flags.
    readonly property var recordingModes: [
        {
            key: "fullscreen" + qsTr("Record fullscreen"),
            flags: []
        },
        {
            key: "screenshot_region" + qsTr("Record region"),
            flags: ["-r"]
        },
        {
            key: "select_to_speak" + qsTr("Record fullscreen with sound"),
            flags: ["-s"]
        },
        {
            key: "volume_up" + qsTr("Record region with sound"),
            flags: ["-sr"]
        }
    ]
    readonly property int modeIndex: Math.max(0, recordingModes.findIndex(mode => mode.key === root.props.recordingMode))
    readonly property bool captureRegion: modeIndex % 2 === 1
    readonly property bool captureAudio: modeIndex >= 2

    function selectMode(region: bool, audio: bool): void {
        root.props.recordingMode = recordingModes[(audio ? 2 : 0) + (region ? 1 : 0)].key;
    }

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2 + frame.headingHeight / 2

    UtilityFrame {
        id: frame
        title: qsTr("SCREEN RECORDER")
    }

    ColumnLayout {
        id: layout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Appearance.padding.large
        anchors.topMargin: Appearance.padding.large + frame.headingHeight / 2
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            visible: !Recorder.running
            spacing: Appearance.spacing.normal

            CaptureChoice {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: qsTr("Screen")
                selected: !root.captureRegion
                theme: Colours.palette
                appearance: Appearance
                onClicked: root.selectMode(false, root.captureAudio)
            }

            CaptureChoice {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: qsTr("Region")
                selected: root.captureRegion
                theme: Colours.palette
                appearance: Appearance
                onClicked: root.selectMode(true, root.captureAudio)
            }

            UtilityIconButton {
                implicitWidth: 32
                implicitHeight: 32
                radius: Appearance.rounding.small / 2
                glyph: root.captureAudio ? "volume-2" : "volume-x"
                description: root.captureAudio ? qsTr("System audio on — click to mute") : qsTr("System audio off — click to enable")
                toggle: true
                checked: root.captureAudio
                onClicked: root.selectMode(root.captureRegion, !root.captureAudio)
            }

            Controls.AbstractButton {
                id: startButton

                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                Layout.alignment: Qt.AlignTop
                padding: 7
                hoverEnabled: true
                Accessible.name: qsTr("Start recording")
                onClicked: {
                    if (!Recorder.running)
                        Recorder.start(root.recordingModes[root.modeIndex].flags);
                }

                contentItem: ColouredIcon {
                    implicitSize: 18
                    source: Qt.resolvedUrl("../../../assets/icons/lucide/video.svg")
                    colour: Colours.palette.m3onPrimary
                }

                background: StyledRect {
                    radius: Appearance.rounding.small / 2
                    color: Colours.palette.m3primary
                    border.width: startButton.hovered || startButton.visualFocus ? 1 : 0
                    border.color: Colours.palette.m3outline
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            active: Recorder.running
            visible: active
            sourceComponent: recordingControls
        }

        RecordingList {
            Layout.fillWidth: true
            props: root.props
            visibilities: root.visibilities
        }
    }

    Component {
        id: recordingControls

        RowLayout {
            spacing: Appearance.spacing.normal

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: {
                        const elapsed = Recorder.elapsed;

                        const hours = Math.floor(elapsed / 3600);
                        const mins = Math.floor((elapsed % 3600) / 60);
                        const secs = Math.floor(elapsed % 60).toString().padStart(2, "0");

                        let time;
                        if (hours > 0)
                            time = `${hours}:${mins.toString().padStart(2, "0")}:${secs}`;
                        else
                            time = `${mins}:${secs}`;

                        return time;
                    }
                    color: Colours.palette.m3onSurfaceVariant
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.large
                    elide: Text.ElideRight
                }

                StyledText {
                    text: Recorder.paused ? qsTr("Paused") : qsTr("Recording")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 82
                spacing: Appearance.spacing.smaller

                UtilityIconButton {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: Appearance.rounding.small
                    glyph: Recorder.paused ? "play" : "pause"
                    description: Recorder.paused ? qsTr("Resume recording") : qsTr("Pause recording")
                    toggle: true
                    checked: Recorder.paused
                    type: IconButton.Tonal
                    onClicked: {
                        Recorder.togglePause();
                        internalChecked = Recorder.paused;
                    }
                }

                UtilityIconButton {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: Appearance.rounding.small
                    glyph: "square"
                    description: qsTr("Stop recording")
                    inactiveColour: Colours.palette.m3error
                    inactiveOnColour: Colours.palette.m3onError
                    onClicked: Recorder.stop()
                }
            }
        }
    }
}
