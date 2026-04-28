pragma ComponentBehavior: Bound
import qs.components
import qs.config
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services

StyledRect {
    id: root

    signal noteSaved(var noteData)
    signal editorClosed()

    readonly property int pad: Appearance.padding.normal
    property string selectedType: "normal"

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.normal
    implicitWidth: parent?.width ?? 0
    implicitHeight: inner.implicitHeight + pad * 2

    function clear() {
        noteInput.text = ""
        selectedType = "normal"
    }

    function currentTimestamp() {
        const d = new Date()
        const day = d.getDate()
        const months = ["January","February","March","April","May","June",
                        "July","August","September","October","November","December"]
        const h = d.getHours()
        const m = d.getMinutes().toString().padStart(2, "0")
        const ampm = h >= 12 ? "pm" : "am"
        const h12 = (h % 12 || 12)
        return day + " " + months[d.getMonth()] + " at " + h12 + ":" + m + " " + ampm
    }

    ColumnLayout {
        id: inner
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: root.pad
        }
        spacing: Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            StyledText {
                text: "New Note"
                color: Colours.palette.m3primary
                font.pixelSize: Appearance.font.size.normal
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }

            StyledRect {
                radius: Appearance.rounding.full
                color: root.selectedType === "normal" ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3onSurface, 0.1)
                width: 28; height: 28
                StyledText {
                    anchors.centerIn: parent
                    text: "notes"
                    font.family: Appearance.font.family.material
                    font.pixelSize: Appearance.font.size.small
                    color: root.selectedType === "normal" ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedType = "normal" }
            }

            StyledRect {
                radius: Appearance.rounding.full
                color: root.selectedType === "important" ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3onSurface, 0.1)
                width: 28; height: 28
                StyledText {
                    anchors.centerIn: parent
                    text: "priority_high"
                    font.family: Appearance.font.family.material
                    font.pixelSize: Appearance.font.size.small
                    color: root.selectedType === "important" ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedType = "important" }
            }

            StyledRect {
                radius: Appearance.rounding.full
                color: root.selectedType === "todo" ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3onSurface, 0.1)
                width: 28; height: 28
                StyledText {
                    anchors.centerIn: parent
                    text: "check_box"
                    font.family: Appearance.font.family.material
                    font.pixelSize: Appearance.font.size.small
                    color: root.selectedType === "todo" ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedType = "todo" }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colours.tPalette.m3outlineVariant
        }

        TextArea {
            id: noteInput
            Layout.fillWidth: true
            height: Math.max(60, implicitHeight)
            wrapMode: TextEdit.Wrap
            background: null
            color: Colours.palette.m3onSurface
            placeholderText: root.selectedType === "todo" ? "One item per line..." : "Write something..."
            placeholderTextColor: Colours.palette.m3onSurfaceVariant
            font.family: Appearance.font.family.sans
            font.pixelSize: 14
            selectionColor: Qt.alpha(Colours.palette.m3primary, 0.3)
            selectedTextColor: Colours.palette.m3onSurface
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            StyledText {
                text: "close"
                font.family: Appearance.font.family.material
                font.pixelSize: Appearance.font.size.normal
                color: Colours.palette.m3onSurfaceVariant
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.clear(); root.editorClosed() }
                }
            }

            Item { Layout.fillWidth: true }

            StyledRect {
                radius: Appearance.rounding.full
                color: Colours.palette.m3primary
                implicitWidth: doneLbl.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: doneLbl.implicitHeight + Appearance.padding.small * 2

                StyledText {
                    id: doneLbl
                    anchors.centerIn: parent
                    text: "Done"
                    color: Colours.palette.m3onPrimary
                    font.pixelSize: Appearance.font.size.small
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (noteInput.text.trim() === "") {
                            root.editorClosed()
                            return
                        }
                        var content = noteInput.text.trim()
                        if (root.selectedType === "todo") {
                            content = content.split("\n")
                                .filter(l => l.trim().length > 0)
                                .map(l => "[ ] " + l.trim())
                                .join("\n")
                        }
                        root.noteSaved({
                            id: Date.now().toString(),
                            type: root.selectedType,
                            content: content,
                            created: root.currentTimestamp(),
                            tags: [],
                            archived: false
                        })
                        root.clear()
                        root.editorClosed()
                    }
                }
            }
        }
    }
}
