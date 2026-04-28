pragma ComponentBehavior: Bound
import qs.components
import qs.config
import qs.services
import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io

Item {
    id: root

    required property var visibilities
    property bool isVisible: false
    readonly property string notesPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/caelestia/notes.json"
    readonly property int padding: Appearance.padding.large
    property var notes: []
    property bool showEditor: false
    property int collapseCounter: 0
    property bool isSaving: false

    implicitWidth: isVisible ? 380 + padding * 2 : 0
    implicitHeight: isVisible ? 520 + padding * 2 : 0

    function addNote(noteData) {
        var arr = root.notes.slice()
        arr.unshift(noteData)
        root.notes = arr
        saveNotes()
    }

    function updateNote(idx, noteData) {
        var arr = root.notes.slice()
        arr[idx] = noteData
        root.notes = arr
        saveNotes()
    }

    function deleteNote(idx) {
        var arr = root.notes.slice()
        arr[idx] = Object.assign({}, arr[idx], { archived: true })
        root.notes = arr
        saveNotes()
    }

    function saveNotes() {
        root.isSaving = true
        saveProcess.environment = { "NOTES": JSON.stringify(root.notes, null, 2) }
        saveProcess.running = true
    }

    FileView {
        id: fileView
        path: root.notesPath
        onTextChanged: {
            if (root.isSaving) return
            var t = fileView.text()
            if (t.trim() === "") {
                root.notes = []
                return
            }
            try {
                root.notes = JSON.parse(t)
            } catch (e) {
                root.notes = []
            }
        }
    }

    Process {
        id: saveProcess
        command: ["bash", "-c", "mkdir -p '" + StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/caelestia' && printf '%s' \"$NOTES\" > '" + root.notesPath + "'"]
        onExited: root.isSaving = false
    }

    Connections {
        target: root.visibilities
        function onNotesChanged() {
            if (root.visibilities.notes) {
                fileView.reload()
            } else {
                root.saveNotes()
            }
        }
    }

    Timer {
        interval: 10000
        running: root.visibilities.notes
        repeat: true
        onTriggered: root.saveNotes()
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
                    text: "unfold_less"
                    font.family: Appearance.font.family.material
                    font.pixelSize: Appearance.font.size.normal
                    color: Colours.palette.m3onSurfaceVariant
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.collapseCounter++
                    }
                }

                StyledText {
                    text: "add"
                    font.family: Appearance.font.family.material
                    font.pixelSize: Appearance.font.size.normal
                    color: Colours.palette.m3primary
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showEditor = !root.showEditor
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Colours.tPalette.m3outlineVariant
            }

            NoteEditor {
                Layout.fillWidth: true
                visible: root.showEditor
                height: root.showEditor ? implicitHeight : 0
                clip: true
                onNoteSaved: noteData => {
                    root.addNote(noteData)
                    root.showEditor = false
                }
                onEditorClosed: root.showEditor = false
                Behavior on height {
                    NumberAnimation {
                        duration: Appearance.anim.durations.expressiveDefaultSpatial
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Column {
                    width: parent.width
                    spacing: Appearance.spacing.small

                    Repeater {
                        model: root.notes

                        delegate: NoteCard {
                            required property var modelData
                            required property int index
                            width: parent.width
                            visible: !modelData.archived
                            height: visible ? implicitHeight : 0
                            noteData: modelData
                            noteIndex: index
                            collapseCounter: root.collapseCounter
                            onNoteChanged: (idx, data) => root.updateNote(idx, data)
                            onNoteDeleted: idx => root.deleteNote(idx)
                        }
                    }

                    Item {
                        width: parent.width
                        height: 80
                        visible: root.notes.every(n => n.archived) && !root.showEditor

                        StyledText {
                            anchors.centerIn: parent
                            text: "No notes yet. Press + to add one."
                            color: Colours.palette.m3onSurfaceVariant
                            font.pixelSize: Appearance.font.size.small
                        }
                    }
                }
            }
        }
    }
}
