pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root
    required property var entry
    required property string helper
    required property bool selected
    required property bool busy
    property string previewText: entry.text
    property string imagePath: ""
    signal chosen
    signal remove

    implicitHeight: entry.binary ? 112 : 88
    radius: Appearance.rounding.normal
    color: selected || mouse.containsMouse ? Colours.palette.m3surfaceContainerHighest : Colours.palette.m3surfaceContainerHigh
    border.width: selected ? 1 : 0
    border.color: Colours.palette.m3primary

    Process {
        command: ["python3", root.helper, "preview", root.entry.id]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (!result.error) {
                        root.previewText = result.text;
                        root.imagePath = result.image;
                    }
                } catch (_) {}
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.busy
        onClicked: root.chosen()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.normal
        spacing: Appearance.spacing.normal
        Image {
            visible: !!root.imagePath
            source: root.imagePath
            asynchronous: true
            cache: false
            sourceSize.width: 240
            sourceSize.height: 144
            Layout.preferredWidth: 140
            Layout.fillHeight: true
            fillMode: Image.PreserveAspectFit
        }
        MaterialIcon {
            visible: !root.imagePath
            text: root.entry.binary ? "image" : /^https?:\/\//.test(root.previewText) ? "link" : "notes"
            color: Colours.palette.m3primary
        }
        StyledText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.previewText
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAnywhere
            maximumLineCount: 3
            elide: Text.ElideRight
            font.family: root.previewText.includes("\n") ? Appearance.font.family.mono : Appearance.font.family.sans
        }
        IconButton {
            icon: "delete"
            type: IconButton.Text
            disabled: root.busy
            Accessible.name: qsTr("Delete clipboard entry")
            onClicked: root.remove()
        }
    }
}
