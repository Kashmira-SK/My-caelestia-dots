pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Caelestia
import Caelestia.Models
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var props
    required property var visibilities

    spacing: 0

    WrapperMouseArea {
        Layout.fillWidth: true

        cursorShape: Qt.PointingHandCursor
        onClicked: root.props.recordingListExpanded = !root.props.recordingListExpanded

        RowLayout {
            spacing: Appearance.spacing.smaller

            ColouredIcon {
                Layout.alignment: Qt.AlignVCenter
                source: Qt.resolvedUrl("../../../assets/icons/lucide/list-video.svg")
                implicitSize: 16
                colour: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                text: qsTr("LIBRARY")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                font.family: Appearance.font.family.mono
                font.letterSpacing: 1
                font.weight: 500
            }

            UtilityIconButton {
                glyph: "chevron-down"
                icon: root.props.recordingListExpanded ? "unfold_less" : "unfold_more"
                rotation: root.props.recordingListExpanded ? 180 : 0
                type: IconButton.Text
                label.animate: true
                onClicked: root.props.recordingListExpanded = !root.props.recordingListExpanded
            }
        }
    }

    StyledListView {
        id: list

        model: FileSystemModel {
            path: Paths.recsdir
            nameFilters: ["recording_*.mp4"]
            sortReverse: true
        }

        Layout.fillWidth: true
        Layout.rightMargin: -Appearance.spacing.small
        implicitHeight: Math.max(1, Math.min(count, root.props.recordingListExpanded ? 10 : 2)) * 28
        clip: true

        StyledScrollBar.vertical: StyledScrollBar {
            flickable: list
        }

        delegate: RowLayout {
            id: recording

            required property FileSystemEntry modelData
            property string baseName
            readonly property var recordedAt: {
                const parts = baseName.match(/^recording_(\d{4})(\d{2})(\d{2})_(\d{2})-(\d{2})-(\d{2})/);
                return parts ? new Date(Number(parts[1]), Number(parts[2]) - 1, Number(parts[3]), Number(parts[4]), Number(parts[5]), Number(parts[6])) : null;
            }

            anchors.left: list.contentItem.left
            anchors.right: list.contentItem.right
            anchors.rightMargin: Appearance.spacing.small
            spacing: Appearance.spacing.small / 2
            height: 28

            Component.onCompleted: baseName = modelData.baseName

            StyledText {
                Layout.fillWidth: true
                Layout.rightMargin: Appearance.spacing.small / 2
                text: recording.recordedAt ? Qt.formatDateTime(recording.recordedAt, Config.services.useTwelveHourClock ? "d MMM yy · hh:mm ap" : "d MMM yy · HH:mm") : recording.baseName
                color: Colours.palette.m3outline
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.small
                elide: Text.ElideRight
            }

            UtilityIconButton {
                glyph: "play"
                icon: "play_arrow"
                type: IconButton.Text
                onClicked: {
                    root.visibilities.utilities = false;
                    root.visibilities.sidebar = false;
                    Quickshell.execDetached(["app2unit", "--", ...Config.general.apps.playback, recording.modelData.path]);
                }
            }

            UtilityIconButton {
                glyph: "folder"
                icon: "folder"
                type: IconButton.Text
                onClicked: {
                    root.visibilities.utilities = false;
                    root.visibilities.sidebar = false;
                    Quickshell.execDetached(["app2unit", "--", ...Config.general.apps.explorer, recording.modelData.path]);
                }
            }

            UtilityIconButton {
                glyph: "trash-2"
                icon: "delete_forever"
                type: IconButton.Text
                label.color: Colours.palette.m3error
                stateLayer.color: Colours.palette.m3error
                onClicked: root.props.recordingConfirmDelete = recording.modelData.path
            }
        }

        add: Transition {
            Anim {
                property: "opacity"
                from: 0
                to: 1
            }
            Anim {
                property: "scale"
                from: 0.5
                to: 1
            }
        }

        remove: Transition {
            Anim {
                property: "opacity"
                to: 0
            }
            Anim {
                property: "scale"
                to: 0.5
            }
        }

        displaced: Transition {
            Anim {
                properties: "opacity,scale"
                to: 1
            }
            Anim {
                property: "y"
            }
        }

        Loader {
            anchors.centerIn: parent

            opacity: list.count === 0 ? 1 : 0
            active: opacity > 0

            sourceComponent: StyledText {
                text: qsTr("No recordings yet")
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }

            Behavior on opacity {
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
}
