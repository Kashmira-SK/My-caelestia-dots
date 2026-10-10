pragma ComponentBehavior: Bound
import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls

Controls.SpinBox {
    id: root
    property int decimals: 0
    readonly property int factor: Math.pow(10, decimals)
    editable: true
    implicitWidth: 120
    implicitHeight: 32
    leftPadding: 28
    rightPadding: 28
    textFromValue: (value, locale) => Number(value / factor).toLocaleString(locale, 'f', decimals)
    valueFromText: (text, locale) => Math.round(Number.fromLocaleString(locale, text) * factor)
    contentItem: StyledTextField {
        text: root.textFromValue(root.value, root.locale)
        font.pointSize: 10.5 * Appearance.font.size.scale
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        validator: DoubleValidator { bottom: root.from / root.factor; top: root.to / root.factor; decimals: root.decimals }
        selectByMouse: true
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }
    background: Rectangle {
        radius: 6
        color: Colours.palette.m3surfaceContainerLow
        border.width: 1
        border.color: root.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
    }
    up.indicator: StyledText {
        x: root.width - width
        width: 28; height: root.height
        text: "+"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Colours.palette.m3onSurfaceVariant
    }
    down.indicator: StyledText {
        width: 28; height: root.height
        text: "−"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Colours.palette.m3onSurfaceVariant
    }
}
