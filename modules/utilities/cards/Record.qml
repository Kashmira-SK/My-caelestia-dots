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

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                Controls.AbstractButton {
                    id: captureArea

                    Layout.fillWidth: true
                    implicitHeight: 34
                    hoverEnabled: true
                    Accessible.name: root.captureRegion ? qsTr("Region capture. Switch to full screen") : qsTr("Full screen capture. Switch to region")
                    onClicked: root.selectMode(!root.captureRegion, root.captureAudio)

                    contentItem: RowLayout {
                        spacing: Appearance.spacing.small

                        StyledText {
                            Layout.fillWidth: true
                            text: root.captureRegion ? qsTr("Region") : qsTr("Full screen")
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                            elide: Text.ElideRight
                        }

                        ColouredIcon {
                            implicitSize: 16
                            source: Qt.resolvedUrl("../../../assets/icons/lucide/rotate-cw.svg")
                            colour: Colours.palette.m3onSurfaceVariant
                        }
                    }

                    background: StyledRect {
                        radius: Appearance.rounding.small
                        color: Qt.alpha(Colours.palette.m3surfaceContainerHighest, 0)
                        border.width: captureArea.visualFocus || captureArea.hovered ? 1 : 0
                        border.color: Colours.palette.m3outlineVariant
                    }
                }

                Controls.AbstractButton {
                    id: audioSetting

                    Layout.fillWidth: true
                    implicitHeight: 26
                    hoverEnabled: true
                    Accessible.name: root.captureAudio ? qsTr("System audio enabled. Click to mute") : qsTr("Silent capture. Click to include system audio")
                    onClicked: root.selectMode(root.captureRegion, !root.captureAudio)

                    contentItem: RowLayout {
                        spacing: Appearance.spacing.small

                        ColouredIcon {
                            implicitSize: 14
                            source: Qt.resolvedUrl("../../../assets/icons/lucide/" + (root.captureAudio ? "volume-2" : "volume-x") + ".svg")
                            colour: Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: root.captureAudio ? qsTr("System audio") : qsTr("Silent capture")
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    background: StyledRect {
                        radius: Appearance.rounding.small
                        color: Qt.alpha(Colours.palette.m3surfaceContainerHighest, 0)
                        border.width: audioSetting.visualFocus || audioSetting.hovered ? 1 : 0
                        border.color: Colours.palette.m3outlineVariant
                    }
                }
            }

            Controls.AbstractButton {
                id: startButton

                Layout.preferredWidth: 82
                Layout.preferredHeight: 70
                hoverEnabled: true
                Accessible.name: qsTr("Start recording")
                onClicked: {
                    if (!Recorder.running)
                        Recorder.start(root.recordingModes[root.modeIndex].flags);
                }

                contentItem: ColumnLayout {
                    spacing: Appearance.spacing.small

                    Item {
                        Layout.fillHeight: true
                    }

                    ColouredIcon {
                        Layout.alignment: Qt.AlignHCenter
                        implicitSize: 22
                        source: Qt.resolvedUrl("../../../assets/icons/lucide/video.svg")
                        colour: Colours.palette.m3onPrimary
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("REC")
                        color: Colours.palette.m3onPrimary
                        font.family: Appearance.font.family.mono
                        font.pointSize: Appearance.font.size.small
                        font.letterSpacing: 2
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }

                background: StyledRect {
                    radius: Appearance.rounding.small
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
