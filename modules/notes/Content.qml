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
    implicitWidth: 380
    implicitHeight: 440
    readonly property string notesDir: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/caelestia"
    readonly property string notesPath: root.notesDir + "/notes.txt"

    FileView {
        id: fileView
        path: root.notesPath
    }

    Process {
        id: saveProcess
        command: ["bash", "-c", "mkdir -p '" + root.notesDir + "' && cat > '" + root.notesPath + "'"]
        onStarted: {
            stdin.write(textArea.text)
            stdin.close()
        }
    }

    Connections {
        target: root.visibilities
        function onNotesChanged() {
            if (root.visibilities.notes) {
                fileView.reload()
                textArea.text = fileView.text
            } else {
                saveProcess.running = true
            }
        }
    }

    Component.onCompleted: textArea.text = fileView.text

    StyledRect {
        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainerLow

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
                    font.pixelSize: Appearance.font.size.small
                    selectionColor: Qt.alpha(Colours.palette.m3primary, 0.3)
                    selectedTextColor: Colours.palette.m3onSurface
                }
            }
        }
    }
}
