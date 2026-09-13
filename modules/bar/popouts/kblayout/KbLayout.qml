pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Templates as T
import qs.components
import qs.components.effects
import qs.services
import qs.config
import qs.modules.utilities.cards
import "."

Item {
    id: root
    required property Item wrapper

    implicitWidth: Config.bar.sizes.kbLayoutWidth
    width: implicitWidth
    implicitHeight: body.implicitHeight + Appearance.padding.normal * 2 + frame.headingHeight

    KbLayoutModel {
        id: kb
    }
    function refresh() {
        kb.refresh();
    }
    Component.onCompleted: kb.start()

    UtilityFrame {
        id: frame
        title: qsTr("KEYBOARD")
    }

    ColumnLayout {
        id: body
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Appearance.padding.normal
        anchors.rightMargin: Appearance.padding.normal
        anchors.topMargin: frame.headingHeight + Appearance.padding.normal
        spacing: Appearance.spacing.small

        LayoutChoice {
            Layout.fillWidth: true
            visible: kb.activeLabel.length > 0
            text: kb.activeLabel
            selected: true
            enabled: false
        }

        ListView {
            id: list
            Layout.fillWidth: true
            implicitHeight: Math.min(contentHeight, 320)
            visible: kb.visibleModel.count > 0
            model: kb.visibleModel
            clip: true
            interactive: true
            spacing: Appearance.spacing.small

            delegate: LayoutChoice {
                required property int layoutIndex
                required property string label
                width: list.width
                text: label
                enabled: layoutIndex <= 3
                onClicked: {
                    if (layoutIndex <= 3)
                        kb.switchTo(layoutIndex);
                }
            }
        }
    }

    component LayoutChoice: T.AbstractButton {
        id: choice
        property bool selected: false
        readonly property string keyCode: text.split(" - ")[0].slice(0, 5)
        readonly property string language: text.includes(" - ") ? text.slice(text.indexOf(" - ") + 3) : text

        implicitHeight: Math.max(36, languageText.implicitHeight + Appearance.padding.small * 2)
        padding: Appearance.padding.small
        hoverEnabled: true
        activeFocusOnTab: !selected
        Accessible.name: text
        opacity: enabled || selected ? 1 : 0.4

        contentItem: RowLayout {
            spacing: Appearance.spacing.normal

            StyledRect {
                implicitWidth: 42
                implicitHeight: 26
                radius: 4
                border.width: 1
                border.color: choice.selected ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

                StyledText {
                    anchors.centerIn: parent
                    text: choice.keyCode
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.small
                    color: choice.selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }
            }

            StyledText {
                id: languageText
                Layout.fillWidth: true
                text: choice.language
                wrapMode: Text.Wrap
                font.pointSize: Appearance.font.size.small
                font.weight: 500
                color: choice.selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            }

            ColouredIcon {
                implicitSize: 16
                source: Qt.resolvedUrl("../../../../assets/icons/lucide/" + (choice.selected ? "keyboard" : "chevron-down") + ".svg")
                rotation: choice.selected ? 0 : -90
                colour: choice.selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            }
        }

        background: StyledRect {
            radius: Appearance.rounding.panel
            color: Qt.alpha(Colours.palette.m3onSurface, choice.down ? 0.12 : choice.hovered ? 0.08 : 0)
            border.width: choice.visualFocus ? 1 : 0
            border.color: Colours.palette.m3outlineVariant
        }

        ToolTip {
            visible: !choice.enabled && !choice.selected && choice.hovered
            text: qsTr("XKB supports at most four layouts")
            contentItem: StyledText {
                text: qsTr("XKB supports at most four layouts")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }
            background: StyledRect {
                radius: Appearance.rounding.panel
                color: Colours.palette.m3surfaceContainerHighest
            }
        }
    }
}
