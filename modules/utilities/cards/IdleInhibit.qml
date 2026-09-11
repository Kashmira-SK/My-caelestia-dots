import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + (IdleInhibitor.enabled ? activeChip.implicitHeight + activeChip.anchors.topMargin : 0) + Appearance.padding.large * 2 + frame.headingHeight / 2

    radius: Appearance.rounding.normal
    color: Colours.tPalette.m3surfaceContainer
    clip: true

    UtilityFrame {
        id: frame
        title: qsTr("KEEP AWAKE")
    }

    RowLayout {
        id: layout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Appearance.padding.large
        anchors.topMargin: Appearance.padding.large + frame.headingHeight / 2
        spacing: Appearance.spacing.normal

        StyledRect {
            implicitWidth: implicitHeight
            implicitHeight: 28

            radius: Appearance.rounding.small / 2
            color: IdleInhibitor.enabled ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

            ColouredIcon {
                id: icon

                anchors.centerIn: parent
                source: Qt.resolvedUrl("../../../assets/icons/lucide/coffee.svg")
                colour: IdleInhibitor.enabled ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                implicitSize: 16
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: IdleInhibitor.enabled ? qsTr("Preventing sleep mode") : qsTr("Normal power management")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                elide: Text.ElideRight
            }
        }

        StyledSwitch {
            checked: IdleInhibitor.enabled
            onToggled: IdleInhibitor.enabled = checked
        }
    }

    Loader {
        id: activeChip

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.topMargin: Appearance.spacing.larger
        anchors.bottomMargin: IdleInhibitor.enabled ? Appearance.padding.large : -implicitHeight
        anchors.leftMargin: Appearance.padding.large

        opacity: IdleInhibitor.enabled ? 1 : 0
        scale: IdleInhibitor.enabled ? 1 : 0.5

        Component.onCompleted: active = Qt.binding(() => opacity > 0)

        sourceComponent: StyledRect {
            implicitWidth: activeText.implicitWidth + Appearance.padding.normal * 2
            implicitHeight: activeText.implicitHeight + Appearance.padding.small * 2

            radius: Appearance.rounding.small / 2
            color: Colours.palette.m3primary

            StyledText {
                id: activeText

                anchors.centerIn: parent
                text: qsTr("Active since %1").arg(Qt.formatTime(IdleInhibitor.enabledSince, Config.services.useTwelveHourClock ? "hh:mm a" : "hh:mm"))
                color: Colours.palette.m3onPrimary
                font.pointSize: Math.round(Appearance.font.size.small * 0.9)
            }
        }

        Behavior on anchors.bottomMargin {
            Anim {
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        }

        Behavior on opacity {
            Anim {
                duration: Appearance.anim.durations.small
            }
        }

        Behavior on scale {
            Anim {}
        }
    }

    Behavior on implicitHeight {
        Anim {
            duration: Appearance.anim.durations.expressiveDefaultSpatial
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
        }
    }
}
