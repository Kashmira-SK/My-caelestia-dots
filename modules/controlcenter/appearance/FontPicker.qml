pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property string label
    required property string value
    signal selected(string family)
    property bool expanded: false
    readonly property var families: Qt.fontFamilies()

    Layout.fillWidth: true
    spacing: Appearance.spacing.small

    Controls.AbstractButton {
        id: opener
        Layout.fillWidth: true
        implicitHeight: Math.max(44, heading.implicitHeight + 16)
        Accessible.name: root.label + ": " + root.value
        onClicked: {
            root.expanded = !root.expanded;
            if (root.expanded)
                search.forceActiveFocus();
        }
        background: Rectangle {
            color: opener.hovered ? Qt.alpha(Colours.palette.m3primary, 0.06) : "transparent"
            radius: Appearance.rounding.small
            border.width: opener.activeFocus ? 1 : 0
            border.color: Colours.palette.m3primary
        }
        contentItem: RowLayout {
            id: heading
            spacing: Appearance.spacing.normal
            StyledText { text: root.label; font.pointSize: 10.5 * Appearance.font.size.scale }
            StyledText {
                Layout.fillWidth: true
                text: root.value
                font.pointSize: 10.5 * Appearance.font.size.scale
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                color: Colours.palette.m3onSurfaceVariant
            }
            MaterialIcon {
                text: root.expanded ? "expand_less" : "expand_more"
                color: Colours.palette.m3onSurfaceVariant
            }
        }
    }

    ColumnLayout {
        visible: root.expanded
        Layout.fillWidth: true
        StyledTextField {
            id: search
            Layout.fillWidth: true
            implicitHeight: 40
            placeholderText: qsTr("Search installed fonts")
            leftPadding: 10
            rightPadding: 10
            background: Rectangle {
                color: Colours.palette.m3surfaceContainer
                radius: Appearance.rounding.small
                border.width: search.activeFocus ? 1 : 0
                border.color: Colours.palette.m3primary
            }
            Keys.onEscapePressed: root.expanded = false
            Keys.onDownPressed: fonts.forceActiveFocus()
        }
        StyledListView {
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds;
            id: fonts
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 190)
            clip: true
            model: root.expanded ? root.families.filter(f => f.toLowerCase().includes(search.text.toLowerCase())) : []
            currentIndex: 0
            keyNavigationEnabled: true
            StyledScrollBar.vertical: StyledScrollBar { animatePosition: false; flickable: fonts }
            function choose(): void {
                if (currentIndex >= 0 && currentIndex < count) {
                    root.selected(model[currentIndex]);
                    root.expanded = false;
                    opener.forceActiveFocus();
                }
            }
            Keys.onReturnPressed: choose()
            Keys.onEnterPressed: choose()
            Keys.onEscapePressed: root.expanded = false
            delegate: Controls.AbstractButton {
                id: option
                required property string modelData
                required property int index
                width: fonts.width
                implicitHeight: 38
                Accessible.name: modelData
                onClicked: {
                    fonts.currentIndex = index;
                    fonts.choose();
                }
                background: Rectangle {
                    radius: Appearance.rounding.small
                    color: Qt.alpha(Colours.palette.m3primary, option.modelData === root.value ? 0.14 : option.hovered || (fonts.activeFocus && fonts.currentIndex === option.index) ? 0.07 : 0)
                }
                contentItem: StyledText {
                    text: option.modelData
                    leftPadding: 10
                    rightPadding: 10
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
        StyledText {
            visible: fonts.count === 0
            text: qsTr("No matching fonts")
            color: Colours.palette.m3onSurfaceVariant
        }
    }
}
