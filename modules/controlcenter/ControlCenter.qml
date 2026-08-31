pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen

    readonly property int rounding:
        floating
        ? 0
        : Appearance.rounding.normal

    property alias floating:
        session.floating

    property alias active:
        session.active

    property alias navExpanded:
        session.navExpanded

    readonly property Session session: Session {
        id: session
        root: root
    }

    function close(): void {
    }

    implicitWidth:
        implicitHeight
        * Config.controlCenter.sizes.ratio

    implicitHeight:
        screen.height
        * Config.controlCenter.sizes.heightMult

    ColumnLayout {
        anchors.fill: parent

        spacing: 0

        Loader {
            Layout.fillWidth: true

            active:
                root.floating

            visible:
                active

            sourceComponent: WindowTitle {
                screen: root.screen
                session: root.session
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: navRail.implicitHeight

            color:
                Colours.tPalette.m3surface

            NavRail {
                id: navRail

                anchors.fill: parent

                screen:
                    root.screen

                session:
                    root.session

                initialOpeningComplete:
                    root.initialOpeningComplete
            }

            CustomMouseArea {
                anchors.fill: parent
                z: -1

                function onWheel(
                    event: WheelEvent
                ): void {
                    if (
                        !panes.initialOpeningComplete
                    )
                        return;

                    if (
                        event.angleDelta.y < 0
                    )
                        root.session.activeIndex =
                            Math.min(
                                root.session.activeIndex + 1,
                                root.session.panes.length - 1
                            );

                    else if (
                        event.angleDelta.y > 0
                    )
                        root.session.activeIndex =
                            Math.max(
                                root.session.activeIndex - 1,
                                0
                            );
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            bottomLeftRadius:
                root.rounding

            bottomRightRadius:
                root.rounding

            color:
                Colours.tPalette.m3surface

            Panes {
                id: panes

                anchors.fill: parent

                bottomLeftRadius:
                    root.rounding

                bottomRightRadius:
                    root.rounding

                session:
                    root.session
            }
        }
    }

    readonly property bool initialOpeningComplete:
        panes.initialOpeningComplete
}
