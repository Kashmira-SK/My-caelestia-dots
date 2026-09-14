pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick

Column {
    id: root
    property color colour: Colours.palette.m3tertiary
    width: Config.bar.sizes.innerWidth
    spacing: 2

    Loader {
        anchors.horizontalCenter: parent.horizontalCenter
        active: Config.bar.clock.showIcon
        visible: active
        sourceComponent: MaterialIcon {
            text: "calendar_month"
            color: root.colour
            font.pointSize: Appearance.font.size.small
        }
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Time.format(Config.services.useTwelveHourClock ? "hh AP" : "HH").split(" ")[0]
        font.family: Appearance.font.family.sans
        font.pointSize: Appearance.font.size.smaller
        font.weight: 500
        font.features: ({ "tnum": 1 })
        color: root.colour
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Time.format("mm")
        font.family: Appearance.font.family.sans
        font.pointSize: Appearance.font.size.smaller
        font.weight: 500
        font.features: ({ "tnum": 1 })
        color: root.colour
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: Config.services.useTwelveHourClock
        text: Time.format("AP")
        font.family: Appearance.font.family.sans
        font.pointSize: Appearance.font.size.small * 0.8
        font.weight: 500
        font.letterSpacing: 1
        color: root.colour
    }
}
