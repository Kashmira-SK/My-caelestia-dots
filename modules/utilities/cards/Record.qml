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
        { key: "fullscreen" + qsTr("Record fullscreen"), flags: [] },
        { key: "screenshot_region" + qsTr("Record region"), flags: ["-r"] },
        { key: "select_to_speak" + qsTr("Record fullscreen with sound"), flags: ["-s"] },
        { key: "volume_up" + qsTr("Record region with sound"), flags: ["-sr"] }
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

        StyledText {
            Layout.fillWidth: true
            visible: Recorder.running
            text: Recorder.paused ? qsTr("Recording paused") : Recorder.running ? qsTr("Recording running") : qsTr("Ready to capture")
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
        }

        RowLayout {
            Layout.fillWidth: true
            visible: !Recorder.running
            spacing: Appearance.spacing.small

            CaptureMode {
                text: qsTr("Full screen")
                selected: !root.captureRegion
                onClicked: root.selectMode(false, root.captureAudio)
            }

            CaptureMode {
                text: qsTr("Region")
                selected: root.captureRegion
                onClicked: root.selectMode(true, root.captureAudio)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: !Recorder.running
            spacing: Appearance.spacing.small

            UtilityIconButton {
                radius: 0
                glyph: root.captureAudio ? "volume-2" : "volume-x"
                description: root.captureAudio ? qsTr("Audio on — click to mute") : qsTr("Audio off — click to include sound")
                implicitWidth: 26
                implicitHeight: 26
                toggle: true
                checked: root.captureAudio
                onClicked: root.selectMode(root.captureRegion, !root.captureAudio)
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Include audio")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }

            Controls.AbstractButton {
                id: startButton

                text: qsTr("RECORD")
                implicitWidth: startLabel.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: 32
                hoverEnabled: true
                onClicked: {
                    if (!Recorder.running)
                        Recorder.start(root.recordingModes[root.modeIndex].flags);
                }

                contentItem: StyledText {
                    id: startLabel
                    text: startButton.text
                    color: Colours.palette.m3onPrimary
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.small
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: StyledRect {
                    radius: 0
                    color: Colours.palette.m3primary
                    border.width: startButton.hovered || startButton.visualFocus ? 1 : 0
                    border.color: Colours.palette.m3outline
                }
            }
        }

        Loader {
            id: listOrControls

            property bool running: Recorder.running

            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            sourceComponent: running ? recordingControls : recordingList

            Behavior on Layout.preferredHeight {
                id: locHeightAnim

                enabled: false

                Anim {}
            }

            Behavior on running {
                SequentialAnimation {
                    ParallelAnimation {
                        Anim {
                            target: listOrControls
                            property: "scale"
                            to: 0.7
                            duration: Appearance.anim.durations.small
                            easing.bezierCurve: Appearance.anim.curves.standardAccel
                        }
                        Anim {
                            target: listOrControls
                            property: "opacity"
                            to: 0
                            duration: Appearance.anim.durations.small
                            easing.bezierCurve: Appearance.anim.curves.standardAccel
                        }
                    }
                    PropertyAction {
                        target: locHeightAnim
                        property: "enabled"
                        value: true
                    }
                    PropertyAction {}
                    PropertyAction {
                        target: locHeightAnim
                        property: "enabled"
                        value: false
                    }
                    ParallelAnimation {
                        Anim {
                            target: listOrControls
                            property: "scale"
                            to: 1
                            duration: Appearance.anim.durations.small
                            easing.bezierCurve: Appearance.anim.curves.standardDecel
                        }
                        Anim {
                            target: listOrControls
                            property: "opacity"
                            to: 1
                            duration: Appearance.anim.durations.small
                            easing.bezierCurve: Appearance.anim.curves.standardDecel
                        }
                    }
                }
            }
        }
    }

    Component {
        id: recordingList

        RecordingList {
            props: root.props
            visibilities: root.visibilities
        }
    }

    Component {
        id: recordingControls

        RowLayout {
            spacing: Appearance.spacing.normal

            StyledRect {
                radius: 0
                color: Recorder.paused ? Colours.palette.m3tertiary : Colours.palette.m3error

                implicitWidth: recText.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: recText.implicitHeight + Appearance.padding.smaller * 2

                StyledText {
                    id: recText

                    anchors.centerIn: parent
                    animate: true
                    text: Recorder.paused ? "PAUSED" : "REC"
                    color: Recorder.paused ? Colours.palette.m3onTertiary : Colours.palette.m3onError
                    font.family: Appearance.font.family.mono
                }

                Behavior on implicitWidth {
                    Anim {}
                }

                SequentialAnimation on opacity {
                    running: !Recorder.paused
                    alwaysRunToEnd: true
                    loops: Animation.Infinite

                    Anim {
                        from: 1
                        to: 0
                        duration: Appearance.anim.durations.large
                        easing.bezierCurve: Appearance.anim.curves.emphasizedAccel
                    }
                    Anim {
                        from: 0
                        to: 1
                        duration: Appearance.anim.durations.extraLarge
                        easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
                    }
                }
            }

            StyledText {
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

                    return qsTr("Recording for %1").arg(time);
                }
                font.pointSize: Appearance.font.size.normal
            }

            Item {
                Layout.fillWidth: true
            }

            UtilityIconButton {
                radius: 0
                glyph: Recorder.paused ? "play" : "pause"
                label.animate: true
                icon: Recorder.paused ? "play_arrow" : "pause"
                toggle: true
                checked: Recorder.paused
                type: IconButton.Tonal
                font.pointSize: Appearance.font.size.large
                onClicked: {
                    Recorder.togglePause();
                    internalChecked = Recorder.paused;
                }
            }

            UtilityIconButton {
                radius: 0
                glyph: "square"
                icon: "stop"
                inactiveColour: Colours.palette.m3error
                inactiveOnColour: Colours.palette.m3onError
                font.pointSize: Appearance.font.size.large
                onClicked: Recorder.stop()
            }
        }
    }

    component CaptureMode: Controls.AbstractButton {
        id: mode

        required property bool selected

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: 32
        leftPadding: Appearance.padding.small
        rightPadding: Appearance.padding.small
        hoverEnabled: true

        contentItem: RowLayout {
            spacing: Appearance.spacing.small

            StyledRect {
                implicitWidth: 16
                implicitHeight: 16
                radius: 0
                color: mode.selected ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3primary, 0)
                border.width: mode.selected ? 0 : 1
                border.color: Colours.palette.m3outline

                ColouredIcon {
                    anchors.centerIn: parent
                    visible: mode.selected
                    implicitSize: 12
                    source: Qt.resolvedUrl("../../../assets/icons/lucide/check.svg")
                    colour: Colours.palette.m3onPrimary
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: mode.text
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                elide: Text.ElideRight
            }
        }

        background: StyledRect {
            radius: 0
            color: Qt.alpha(Colours.palette.m3surfaceContainerHighest, 0)
            border.width: mode.visualFocus || mode.hovered ? 1 : 0
            border.color: Colours.palette.m3outlineVariant
        }
    }
}
