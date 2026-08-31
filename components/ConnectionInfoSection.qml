import qs.components
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var deviceDetails

    spacing: Appearance.spacing.small / 2

    StyledText {
        text: qsTr("IP Address")
    }

    SelectableValue {
        value: root.deviceDetails?.ipAddress || qsTr("Not available")
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.normal
        text: qsTr("Subnet Mask")
    }

    SelectableValue {
        value: root.deviceDetails?.subnet || qsTr("Not available")
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.normal
        text: qsTr("Gateway")
    }

    SelectableValue {
        value: root.deviceDetails?.gateway || qsTr("Not available")
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.normal
        text: qsTr("DNS Servers")
    }

    SelectableValue {
        value: (root.deviceDetails && root.deviceDetails.dns && root.deviceDetails.dns.length > 0)
            ? root.deviceDetails.dns.join(", ")
            : qsTr("Not available")
    }

    component SelectableValue: Item {
        id: selectable

        required property string value

        Layout.fillWidth: true
        implicitHeight: valueText.contentHeight

        TextEdit {
            id: valueText

            width: parent.width
            height: contentHeight

            text: selectable.value
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
