import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property string label
    required property string value
    property bool showTopMargin: false

    spacing: Appearance.spacing.small / 2

    StyledText {
        Layout.topMargin: root.showTopMargin ? Appearance.spacing.normal : 0
        text: root.label
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: valueText.contentHeight

        TextEdit {
            id: valueText

            width: parent.width
            height: contentHeight

            text: root.value
            color: Colours.palette.m3outline

            font.pointSize: Appearance.font.size.small

            readOnly: true
            selectByMouse: true
            activeFocusOnTab: false

            wrapMode: TextEdit.WrapAnywhere
            textFormat: TextEdit.PlainText
        }
    }
}
