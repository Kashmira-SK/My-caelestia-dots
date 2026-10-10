pragma ComponentBehavior: Bound
import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

StyledTextField {
    id: root
    required property Session session
    readonly property var results: PaneRegistry.search(text)
    property int selectedResult: 0
    implicitWidth: 225
    implicitHeight: 34
    font.pointSize: 9.0 * Appearance.font.size.scale
    leftPadding: 32
    rightPadding: 30
    placeholderText: qsTr("Search settings")
    Accessible.name: placeholderText
    onTextChanged: selectedResult = 0
    function choose(index: int): void {
        const result = results[index];
        if (!result) return;
        session.active = result.page;
        if (result.section) session.setSection(result.page, result.section);
        text = "";
    }
    onAccepted: choose(selectedResult)
    Keys.onEscapePressed: text = ""
    Keys.onDownPressed: selectedResult = Math.min(results.length - 1, selectedResult + 1)
    Keys.onUpPressed: selectedResult = Math.max(0, selectedResult - 1)
    background: Rectangle {
        radius: 7
        color: Colours.palette.m3surfaceContainerHigh
        border.width: 1
        border.color: root.activeFocus ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outlineVariant, 0.65)
    }
    MaterialIcon { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: "search"; font.pointSize: 12.0; color: Colours.palette.m3onSurfaceVariant }
    Controls.AbstractButton {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 30; height: 30
        visible: root.text.length > 0
        Accessible.name: qsTr("Clear search")
        onClicked: { root.text = ""; root.forceActiveFocus(); }
        contentItem: MaterialIcon { text: "close"; font.pointSize: 12.0; color: Colours.palette.m3onSurfaceVariant }
    }
    Controls.Popup {
        id: popup
        y: root.height + 6
        x: root.width - width
        width: 330
        padding: 6
        visible: root.activeFocus && root.text.trim().length > 0
        closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside
        background: Rectangle { color: Colours.palette.m3surfaceContainerHigh; radius: 8; border.width: 1; border.color: Colours.palette.m3outlineVariant }
        contentItem: ListView {
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds;
            id: resultList
            implicitHeight: Math.min(360, Math.max(48, count * 48))
            clip: true
            model: root.results
            currentIndex: root.selectedResult
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
            Controls.ScrollBar.vertical: Controls.ScrollBar { policy: Controls.ScrollBar.AlwaysOff }
            StyledText {
                visible: resultList.count === 0
                anchors.centerIn: parent
                text: qsTr("No matching settings")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: 9.75 * Appearance.font.size.scale
            }
            delegate: Controls.AbstractButton {
                id: resultButton
                required property var modelData
                required property int index
                width: resultList.width
                height: 48
                focusPolicy: Qt.NoFocus
                Accessible.name: modelData.detail + ": " + modelData.label
                onClicked: root.choose(index)
                background: Rectangle { radius: 5; color: Qt.alpha(Colours.palette.m3primary, root.selectedResult === resultButton.index || resultButton.hovered ? 0.12 : 0) }
                contentItem: ColumnLayout {
                    spacing: 2
                    StyledText { text: resultButton.modelData.label; font.pointSize: 9.75 * Appearance.font.size.scale }
                    StyledText { text: resultButton.modelData.detail; font.pointSize: 8.25 * Appearance.font.size.scale; color: Colours.palette.m3onSurfaceVariant }
                }
                leftPadding: 10
            }
        }
    }
}
