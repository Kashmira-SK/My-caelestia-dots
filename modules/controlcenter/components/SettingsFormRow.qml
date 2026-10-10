pragma ComponentBehavior: Bound
import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Item {
    id: root
    required property string label
    property string description: ""
    required property var settings
    required property string setting
    property bool numeric: false
    property real from: 0
    property real to: 100
    property real stepSize: 1
    property int decimals: 0
    property real multiplier: 1
    property string suffix: ""
    property var edit: null
    function write(value: var): void {
        if (edit) edit(settings, setting, value);
        else { settings[setting] = value; Config.save(); }
    }
    Layout.fillWidth: true
    implicitHeight: Math.max(description ? 72 : 56, labels.implicitHeight + 26)
    opacity: enabled ? 1 : 0.45
    Rectangle {
        visible: root.y > 1
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: Qt.alpha(Colours.palette.m3outlineVariant, 0.65)
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        spacing: 24
        ColumnLayout {
            id: labels
            Layout.fillWidth: true
            spacing: 5
            StyledText { text: root.label; Layout.fillWidth: true; wrapMode: Text.WordWrap; font.pointSize: 10.5 * Appearance.font.size.scale }
            StyledText {
                visible: root.description !== ""
                text: root.description
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pointSize: 9.0 * Appearance.font.size.scale
                color: Colours.palette.m3onSurfaceVariant
            }
        }
        SettingsSwitch {
            visible: !root.numeric
            Accessible.name: root.label
            checked: !!root.settings[root.setting]
            onToggled: root.write(checked)
        }
        Controls.SpinBox {
            id: number
            visible: root.numeric
            Accessible.name: root.label
            readonly property int factor: Math.pow(10, root.decimals)
            from: Math.round(root.from * factor)
            to: Math.round(root.to * factor)
            stepSize: Math.max(1, Math.round(root.stepSize * factor))
            value: root.numeric ? Math.round(root.settings[root.setting] * root.multiplier * factor) : 0
            textFromValue: (value, locale) => Number(value / factor).toLocaleString(locale, 'f', root.decimals)
            valueFromText: (text, locale) => Math.round(Number.fromLocaleString(locale, text) * factor)
            editable: true
            implicitWidth: root.decimals > 0 || root.to > 100 ? 120 : 96
            implicitHeight: 32
            leftPadding: 28
            rightPadding: 28
            onValueModified: root.write(value / factor / root.multiplier)
            contentItem: StyledTextField {
                text: number.textFromValue(number.value, number.locale)
                font.pointSize: 10.5 * Appearance.font.size.scale
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                validator: DoubleValidator { bottom: root.from; top: root.to; decimals: root.decimals }
                selectByMouse: true
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }
            background: Rectangle {
                radius: 6
                color: Colours.palette.m3surfaceContainerLow
                border.width: 1
                border.color: number.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
            }
            up.indicator: StyledText {
                x: number.width - width
                width: 28; height: number.height
                text: "+"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Colours.palette.m3onSurfaceVariant
            }
            down.indicator: StyledText {
                width: 28; height: number.height
                text: "−"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Colours.palette.m3onSurfaceVariant
            }
        }
        StyledText { visible: root.numeric && root.suffix !== ""; text: root.suffix; font.pointSize: 9 * Appearance.font.size.scale; color: Colours.palette.m3onSurfaceVariant }
    }
}
