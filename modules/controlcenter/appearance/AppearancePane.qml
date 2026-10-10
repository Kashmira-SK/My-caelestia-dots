pragma ComponentBehavior: Bound

import ".."
import "../components"
import "../../launcher/services"
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

SettingsPage {
    id: root
    required property Session session
    readonly property string section: session.sectionFor("appearance")
    anchors.fill: parent
    title: PaneRegistry.sectionLabel("appearance", section)
    description: section === "colors" ? qsTr("Theme colors apply to the shell and connected apps.") : section === "text" ? qsTr("Choose the fonts and size used across the shell.") : section === "surfaces" ? qsTr("Adjust shell transparency and animation timing.") : qsTr("Adjust spacing, corners, and the screen border.")
    function setValue(settings: var, key: string, value: var): void { session.changeVisual(settings, key, value); }
    Timer { id: schemeReload; interval: 300; onTriggered: Schemes.reload() }
    Group {
        visible: root.section === "colors"
        title: qsTr("Color theme")
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            RowLayout {
                Layout.fillWidth: true
                StyledText { Layout.fillWidth: true; text: qsTr("Mode"); font.pointSize: 10.5 * Appearance.font.size.scale }
                RowLayout {
                    spacing: 6
                    Choice { Layout.preferredWidth: 110; text: qsTr("Light"); iconName: "light_mode"; selected: Colours.currentLight; onClicked: Colours.setMode("light") }
                    Choice { Layout.preferredWidth: 110; text: qsTr("Dark"); iconName: "dark_mode"; selected: !Colours.currentLight; onClicked: Colours.setMode("dark") }
                }
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: Qt.alpha(Colours.palette.m3outlineVariant, 0.4) }
            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    StyledText { text: qsTr("Color profile"); font.pointSize: 10.5 * Appearance.font.size.scale }
                    StyledText { text: qsTr("How strongly wallpaper colors are used"); font.pointSize: 9 * Appearance.font.size.scale; color: Colours.palette.m3onSurfaceVariant; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                }
                Selector {
                    model: Schemes.list
                    textRole: "flavour"
                    selectedKey: Schemes.currentScheme
                    keyFor: item => `${item.name} ${item.flavour}`
                    Accessible.name: qsTr("Color profile")
                    onActivated: index => {
                        const item = Schemes.list[index];
                        if (!item) return;
                        Schemes.currentScheme = `${item.name} ${item.flavour}`;
                        Colours.setScheme(item.name, item.flavour);
                        schemeReload.restart();
                    }
                }
            }
        }
    }
    Group {
        visible: root.section === "colors"
        title: qsTr("Palette")
        RowLayout {
            Layout.fillWidth: true
            spacing: 24
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                StyledText { text: qsTr("Palette style"); font.pointSize: 10.5 * Appearance.font.size.scale }
                StyledText {
                    Layout.fillWidth: true
                    text: M3Variants.list.find(item => item.variant === Schemes.currentVariant)?.description ?? qsTr("Choose how colors are distributed across the interface.")
                    wrapMode: Text.WordWrap
                    font.pointSize: 9 * Appearance.font.size.scale
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
            Selector {
                model: M3Variants.list
                textRole: "name"
                selectedKey: Schemes.currentVariant
                keyFor: item => item.variant
                Accessible.name: qsTr("Palette style")
                onActivated: index => {
                    const item = M3Variants.list[index];
                    if (!item) return;
                    Schemes.currentVariant = item.variant;
                    Colours.setVariant(item.variant);
                    schemeReload.restart();
                }
            }
        }
    }

    Group {
        visible: root.section === "text"
        title: qsTr("Text")
        FontPicker {
            label: qsTr("Interface font")
            value: Config.appearance.font.family.sans
            onSelected: family => root.setValue(Config.appearance.font.family, "sans", family)
        }
        Adjustment {
            label: qsTr("Text size")
            settings: Config.appearance.font.size
            setting: "scale"
            multiplier: 100
            from: 70; to: 150; stepSize: 1; decimals: 0; suffix: "%"
        }
    }
    Group {
        visible: root.section === "text"
        title: qsTr("Specialist fonts")
        FontPicker {
            label: qsTr("Monospace font")
            value: Config.appearance.font.family.mono
            onSelected: family => root.setValue(Config.appearance.font.family, "mono", family)
        }
        FontPicker {
            label: qsTr("Icon font")
            value: Config.appearance.font.family.material
            onSelected: family => root.setValue(Config.appearance.font.family, "material", family)
        }
        StyledText {
            Layout.fillWidth: true
            text: qsTr("The icon font must support Material Symbols for shell icons to display correctly.")
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: 9 * Appearance.font.size.scale
            wrapMode: Text.WordWrap
        }
    }
    Group {
        visible: root.section === "surfaces"
        title: qsTr("Transparency")
        SettingsToggle { label: qsTr("Translucent surfaces"); settings: Config.appearance.transparency; setting: "enabled"; edit: root.setValue }
        ColumnLayout {
            Layout.fillWidth: true
            visible: Config.appearance.transparency.enabled
            spacing: Appearance.spacing.normal
            Adjustment {
                label: qsTr("Panel opacity")
                settings: Config.appearance.transparency
                setting: "base"
                multiplier: 100
                from: 0; to: 100; stepSize: 1; decimals: 0; suffix: "%"
            }
            Adjustment {
                label: qsTr("Inner surface opacity")
                settings: Config.appearance.transparency
                setting: "layers"
                multiplier: 100
                from: 0; to: 100; stepSize: 1; decimals: 0; suffix: "%"
            }
        }
    }
    Group {
        visible: root.section === "surfaces"
        title: qsTr("Motion")
        Adjustment {
            label: qsTr("Animation duration")
            settings: Config.appearance.anim.durations
            setting: "scale"
            from: 0.1; to: 5; stepSize: 0.1; decimals: 1
        }
    }
    Group {
        visible: root.section === "layout"
        title: qsTr("Spacing & corners")
        Adjustment {
            label: qsTr("Space inside controls")
            settings: Config.appearance.padding; setting: "scale"
            from: 0.5; to: 2; stepSize: 0.1
        }
        Adjustment {
            label: qsTr("Space between controls")
            settings: Config.appearance.spacing; setting: "scale"
            from: 0.1; to: 2; stepSize: 0.1
        }
        Adjustment {
            label: qsTr("Corner roundness")
            settings: Config.appearance.rounding; setting: "scale"
            from: 0.1; to: 5; stepSize: 0.1
        }
    }
    Group {
        visible: root.section === "layout"
        title: qsTr("Screen border")
        Adjustment {
            label: qsTr("Corner radius")
            settings: Config.border; setting: "rounding"
            from: 0; to: 100; stepSize: 1; decimals: 0; suffix: "px"
        }
        Adjustment {
            label: qsTr("Thickness")
            settings: Config.border; setting: "thickness"
            from: 0; to: 100; stepSize: 1; decimals: 0; suffix: "px"
        }
    }
    component Selector: Controls.ComboBox {
        id: selector
        required property string selectedKey
        required property var keyFor
        Layout.preferredWidth: 220
        implicitHeight: 38
        enabled: count > 0
        currentIndex: Array.from(model ?? []).findIndex(item => keyFor(item) === selectedKey)
        displayText: count === 0 ? qsTr("Loading…") : currentIndex < 0 ? qsTr("Choose…") : currentText.charAt(0).toUpperCase() + currentText.slice(1)
        leftPadding: 12
        rightPadding: 32
        contentItem: StyledText { text: selector.displayText; font.pointSize: 10.5 * Appearance.font.size.scale; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
        background: Rectangle { radius: 6; color: Colours.palette.m3surfaceContainerLow; border.width: 1; border.color: selector.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant }
        indicator: MaterialIcon { x: selector.width - width - 10; anchors.verticalCenter: parent.verticalCenter; text: "expand_more"; font.pointSize: 12; color: Colours.palette.m3onSurfaceVariant }
        delegate: Controls.ItemDelegate {
            required property int index
            width: selector.width
            height: 40
            highlighted: selector.highlightedIndex === index
            contentItem: StyledText { text: selector.textAt(parent.index); font.pointSize: 10.5 * Appearance.font.size.scale; verticalAlignment: Text.AlignVCenter }
            background: Rectangle { color: Qt.alpha(Colours.palette.m3primary, parent.highlighted ? 0.14 : 0); radius: 4 }
        }
        popup: Controls.Popup {
            y: selector.height + 4
            width: selector.width
            padding: 4
            implicitHeight: Math.min(280, popupList.contentHeight + 8)
            background: Rectangle { color: Colours.palette.m3surfaceContainerHigh; radius: 7; border.width: 1; border.color: Colours.palette.m3outlineVariant }
            contentItem: ListView {
                id: popupList
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                boundsMovement: Flickable.StopAtBounds;
                model: selector.popup.visible ? selector.delegateModel : null
                currentIndex: selector.highlightedIndex
                Controls.ScrollBar.vertical: Controls.ScrollBar { policy: Controls.ScrollBar.AlwaysOff }
            }
        }
    }
    component Group: SettingsGroup { contentPadding: 12 }
    component Adjustment: SettingsAdjustment { edit: root.setValue }
    component Choice: Controls.AbstractButton {
        id: choice
        property string detail: ""
        property string iconName: ""
        property bool selected: false
        Layout.fillWidth: true
        implicitHeight: Math.max(44, choiceContent.implicitHeight + 20)
        Accessible.name: text + (detail ? ". " + detail : "")
        Accessible.role: Accessible.RadioButton
        Accessible.checked: selected
        background: Rectangle {
            radius: Appearance.rounding.small
            color: Qt.alpha(Colours.palette.m3primary, choice.selected ? 0.12 : choice.hovered ? 0.06 : 0)
            border.width: 1
            border.color: choice.selected || choice.activeFocus ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outlineVariant, 0.45)
        }
        contentItem: RowLayout {
            id: choiceContent
            spacing: Appearance.spacing.small
            MaterialIcon {
                visible: choice.iconName !== ""
                text: choice.iconName
                color: choice.selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                StyledText { Layout.fillWidth: true; text: choice.text; wrapMode: Text.WordWrap }
                StyledText {
                    visible: choice.detail !== ""
                    Layout.fillWidth: true
                    text: choice.detail
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: 9 * Appearance.font.size.scale
                    wrapMode: Text.WordWrap
                }
            }
            MaterialIcon {
                text: choice.selected ? "check_circle" : "radio_button_unchecked"
                color: choice.selected ? Colours.palette.m3primary : Colours.palette.m3outline
                font.pointSize: 10.5 * Appearance.font.size.scale
            }
        }
        leftPadding: 12
        rightPadding: 12
        topPadding: 10
        bottomPadding: 10
    }
}
