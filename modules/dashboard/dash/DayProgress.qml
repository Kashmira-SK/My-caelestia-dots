import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property int hours: Time.hours
    readonly property int minutes: Time.minutes
    readonly property int seconds: Time.seconds
    readonly property real dayProgress: (hours * 3600 + minutes * 60 + seconds) / 86400
    readonly property bool isDaytime: hours >= 6 && hours < 18

    readonly property string greeting: {
        if (hours < 5) return qsTr("Still up");
        if (hours < 12) return qsTr("Good morning");
        if (hours < 17) return qsTr("Good afternoon");
        if (hours < 21) return qsTr("Good evening");
        return qsTr("Good night");
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - Appearance.padding.large * 2
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Appearance.spacing.small

            MaterialIcon {
                text: root.isDaytime ? "clear_day" : "bedtime"
                fill: 1
                color: Colours.palette.m3tertiary
                font.pointSize: Appearance.font.size.large
            }

            StyledText {
                text: root.greeting
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.large
                font.weight: 600
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            Layout.topMargin: Appearance.spacing.small

            StyledRect {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 4
                radius: Appearance.rounding.full
                color: Qt.alpha(Colours.palette.m3onSurface, 0.15)
            }

            StyledRect {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 4
                width: parent.width * root.dayProgress
                radius: Appearance.rounding.full
                color: Colours.palette.m3primary

                Behavior on width { Anim { duration: Appearance.anim.durations.large } }
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("%1% of the day gone").arg(Math.round(root.dayProgress * 100))
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.smaller
        }
    }
}
