pragma ComponentBehavior: Bound
import qs.components
import qs.config
import qs.services
import Quickshell.Io
import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    required property var visibilities
    property bool isVisible: false
    readonly property string notesPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/caelestia/notes.txt"
    readonly property int padding: Appearance.padding.large
    implicitWidth: isVisible ? 380 + padding * 2 : 0
    implicitHeight: isVisible ? 440 + padding * 2 : 0

    FileView {
        id: fileView
        path: root.notesPath
        onTextChanged: {
            if (textArea.text === "" && fileView.text !== "")
                textArea.text = fileView.text
        }
    }

    Process {
        id: saveProcess
        command: ["bash", "-c", "mkdir -p '" + StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/caelestia' && printf '%s' \"$NOTES\" > '" + root.notesPath + "'"]
        environment: ({ "NOTES": textArea.text })
    }

    Connections {
        target: root.visibilities
        function onNotesChanged() {
            if (root.visibilities.notes) {
                fileView.reload()
            } else {
                saveProcess.running = true
            }
        }
    }

    Timer {
        interval: 10000
        running: root.visibilities.notes
        repeat: true
        onTriggered: saveProcess.running = true
    }
    

    StyledRect {
        anchors.fill: parent
        anchors.margins: root.padding
        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    text: "edit_note"
                    font.family: Appearance.font.family.material
                    font.pixelSize: Appearance.font.size.normal
                    color: Colours.palette.m3primary
                }

                StyledText {
                    text: "Notes"
                    font.pixelSize: Appearance.font.size.normal
                    font.weight: Font.Medium
                    color: Colours.palette.m3onSurface
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: "delete_sweep"
                    font.family: Appearance.font.family.material
                    font.pixelSize: Appearance.font.size.normal
                    color: Colours.palette.m3onSurfaceVariant

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: textArea.text = ""
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Colours.tPalette.m3outlineVariant
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                TextArea {
                    id: textArea
                    width: parent.width
                    wrapMode: TextEdit.Wrap
                    background: null
                    color: Colours.palette.m3onSurface
                    placeholderText: "Write something..."
                    placeholderTextColor: Colours.palette.m3onSurfaceVariant
                    font.family: Appearance.font.family.sans
                    font.pixelSize: 14
                    selectionColor: Qt.alpha(Colours.palette.m3primary, 0.3)
                    selectedTextColor: Colours.palette.m3onSurface
                }
            }
        }
    }
}
