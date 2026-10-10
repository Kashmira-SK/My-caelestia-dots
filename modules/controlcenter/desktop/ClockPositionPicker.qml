pragma ComponentBehavior: Bound

import "../components"
import qs.components
import qs.components.images
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property string position
    signal selected(string position)
    readonly property var rows: ["top", "middle", "bottom"]
    readonly property var columns: ["left", "center", "right"]
    readonly property var labels: [qsTr("Top left"), qsTr("Top center"), qsTr("Top right"),
                                  qsTr("Middle left"), qsTr("Center"), qsTr("Middle right"),
                                  qsTr("Bottom left"), qsTr("Bottom center"), qsTr("Bottom right")]

    implicitHeight: 170
    color: Colours.palette.m3surfaceContainer
    radius: Appearance.rounding.small
    clip: true
    border.width: 1
    border.color: Colours.palette.m3outlineVariant

    CachingImage {
        anchors.fill: parent
        path: Config.background.wallpaperEnabled ? Wallpapers.previewPath(Wallpapers.actualCurrent) : ""
        sourceSize: Qt.size(root.width, root.height)
        fillMode: Image.PreserveAspectCrop
        opacity: 0.25
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 8
        columns: 3
        rowSpacing: 5
        columnSpacing: 5

        Repeater {
            model: 9
            Controls.AbstractButton {
                id: cell
                required property int index
                readonly property string positionKey: root.rows[Math.floor(index / 3)] + "-" + root.columns[index % 3]
                readonly property bool selected: root.position === positionKey
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                Layout.preferredHeight: 1
                Accessible.name: root.labels[index]
                Accessible.role: Accessible.RadioButton
                Accessible.checked: selected
                onClicked: root.selected(positionKey)
                background: Rectangle {
                    radius: Appearance.rounding.small / 2
                    color: Qt.alpha(Colours.palette.m3primary, cell.selected ? 0.2 : cell.hovered ? 0.1 : 0)
                    border.width: cell.selected || cell.activeFocus ? 1 : 0
                    border.color: Colours.palette.m3primary
                }
                contentItem: StyledText {
                    text: cell.selected ? Time.hourStr + ":" + Time.minuteStr : "+"
                    color: cell.selected ? Colours.palette.m3onSurface : Colours.palette.m3onSurfaceVariant
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.small
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                SettingsToolTip { visible: cell.hovered; text: cell.Accessible.name }
            }
        }
    }
}
