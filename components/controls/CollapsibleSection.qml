import ".."
import qs.components
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property string title
    property string description: ""
    property bool expanded: false
    property bool showBackground: false
    property bool nested: false

    // Optional compact/open treatment for settings panes.
    // Defaults off so existing uses elsewhere stay unchanged.
    property bool flatStyle: false

    signal toggleRequested

    spacing: root.flatStyle
        ? Appearance.spacing.smaller
        : Appearance.spacing.small

    Layout.fillWidth: true

    Item {
        id: sectionHeaderItem

        Layout.fillWidth: true
        Layout.preferredHeight: root.flatStyle
            ? 38
            : Math.max(
                titleRow.implicitHeight
                + Appearance.padding.normal * 2,
                48
            )

        RowLayout {
            id: titleRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: root.flatStyle
                ? Appearance.padding.small
                : Appearance.padding.normal

            anchors.rightMargin: root.flatStyle
                ? Appearance.padding.small
                : Appearance.padding.normal

            spacing: Appearance.spacing.normal

            StyledText {
                text: root.title

                font.pointSize: root.flatStyle
                    ? Appearance.font.size.normal
                    : Appearance.font.size.larger

                font.weight: 500
            }

            Item {
                Layout.fillWidth: true
            }

            MaterialIcon {
                text: "expand_more"
                rotation: root.expanded ? 180 : 0

                color: root.flatStyle
                    ? Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.62
                    )
                    : Colours.palette.m3onSurfaceVariant

                font.pointSize: Appearance.font.size.normal

                Behavior on rotation {
                    Anim {
                        duration: Appearance.anim.durations.small
                        easing.bezierCurve: Appearance.anim.curves.standard
                    }
                }
            }
        }

        Rectangle {
            visible: root.flatStyle

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                root.expanded ? 0.34 : 0.20
            )

            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim.durations.small
                }
            }
        }

        StateLayer {
            anchors.fill: parent

            color: Colours.palette.m3onSurface
            radius: root.flatStyle
                ? Appearance.rounding.small
                : Appearance.rounding.normal

            showHoverBackground: false

            function onClicked(): void {
                root.toggleRequested();
                root.expanded = !root.expanded;
            }
        }
    }

    default property alias content: contentColumn.data

    Item {
        id: contentWrapper

        Layout.fillWidth: true

        Layout.preferredHeight: root.expanded
            ? (
                contentColumn.implicitHeight
                + (
                    root.flatStyle
                    ? Appearance.spacing.small
                    : Appearance.spacing.small * 2
                )
            )
            : 0

        clip: true

        Behavior on Layout.preferredHeight {
            Anim {
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }

        StyledRect {
            id: backgroundRect

            anchors.fill: parent

            radius: Appearance.rounding.normal

            color: Colours.transparency.enabled
                ? Colours.layer(
                    Colours.palette.m3surfaceContainer,
                    root.nested ? 3 : 2
                )
                : (
                    root.nested
                    ? Colours.palette.m3surfaceContainerHigh
                    : Colours.palette.m3surfaceContainer
                )

            opacity:
                root.showBackground
                && root.expanded
                && !root.flatStyle
                ? 1.0
                : 0.0

            visible:
                root.showBackground
                && !root.flatStyle

            Behavior on opacity {
                Anim {
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }
        }

        ColumnLayout {
            id: contentColumn

            anchors.left: parent.left
            anchors.right: parent.right

            y: root.flatStyle
                ? Appearance.spacing.smaller
                : Appearance.spacing.small

            anchors.leftMargin: root.flatStyle
                ? Appearance.padding.small
                : Appearance.padding.normal

            anchors.rightMargin: root.flatStyle
                ? Appearance.padding.small
                : Appearance.padding.normal

            anchors.bottomMargin: Appearance.spacing.small

            spacing: Appearance.spacing.small

            opacity: root.expanded ? 1.0 : 0.0

            Behavior on opacity {
                Anim {
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }

            StyledText {
                id: descriptionText

                Layout.fillWidth: true

                Layout.topMargin:
                    root.description !== ""
                    ? Appearance.spacing.smaller
                    : 0

                Layout.bottomMargin:
                    root.description !== ""
                    ? Appearance.spacing.small
                    : 0

                visible: root.description !== ""

                text: root.description

                color: root.flatStyle
                    ? Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.58
                    )
                    : Colours.palette.m3onSurfaceVariant

                font.pointSize: Appearance.font.size.small
                wrapMode: Text.Wrap
            }
        }
    }
}
