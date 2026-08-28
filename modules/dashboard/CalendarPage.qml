import qs.components
import qs.services
import qs.config
import "calendar"
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties state

    implicitWidth: 840
    implicitHeight: 520

    property int displayYear: state.currentDate.getFullYear()
    property int displayMonth: state.currentDate.getMonth()

    property int sideMode: 0
    property bool eventEditorOpen: false

    readonly property date selectedDate: state.currentDate

    StyledRect {
        anchors.fill: parent

        radius: Appearance.rounding.large
        color: Colours.layer(
            Colours.palette.m3surfaceContainer,
            2
        )

        border.color: Colours.palette.m3outlineVariant
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.padding.large

            MonthView {
                Layout.fillHeight: true
                Layout.preferredWidth: root.width * 0.55

                state: root.state

                displayYear: root.displayYear
                displayMonth: root.displayMonth

                onDisplayYearChanged:
                    root.displayYear = displayYear

                onDisplayMonthChanged:
                    root.displayMonth = displayMonth
            }

            Rectangle {
                Layout.fillHeight: true
                implicitWidth: 1
                color: Colours.palette.m3outlineVariant
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Loader {
                    anchors.fill: parent

                    sourceComponent: root.eventEditorOpen
                        ? eventEditorComponent
                        : agendaComponent
                }
            }
        }
    }

    Component {
        id: agendaComponent

        AgendaView {
            selectedDate: root.selectedDate
            mode: root.sideMode

            onModeChanged:
                root.sideMode = mode

            onAddEvent:
                root.eventEditorOpen = true
        }
    }

    Component {
        id: eventEditorComponent

        EventEditor {
            selectedDate: root.selectedDate

            onCancelled:
                root.eventEditorOpen = false

            onSaved:
                root.eventEditorOpen = false
        }
    }
}