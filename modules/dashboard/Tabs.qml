pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property real nonAnimWidth
    required property PersistentProperties state

    readonly property alias count: bar.count

    implicitHeight:
        bar.implicitHeight
        + indicator.implicitHeight
        + indicator.anchors.topMargin
        + separator.anchors.topMargin
        + separator.implicitHeight

    TabBar {
        id: bar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        currentIndex: root.state.currentTab
        background: null

        spacing: 0

        onCurrentIndexChanged:
            root.state.currentTab = currentIndex

        Tab {
            indexText: "01"
            text: qsTr("DASHBOARD")
        }

        Tab {
            indexText: "02"
            text: qsTr("MEDIA")
        }

        Tab {
            indexText: "03"
            text: qsTr("PERFORMANCE")
        }

        Tab {
            indexText: "04"
            text: qsTr("WEATHER")
        }
    }

    Item {
        id: indicator

        anchors.top: bar.bottom
        anchors.topMargin: 7

        implicitWidth: 24
        implicitHeight: 2

        x: {
            const tab = bar.currentItem

            if (!tab)
                return 0

            const tabWidth =
                (
                    root.nonAnimWidth
                    - bar.spacing * (bar.count - 1)
                ) / bar.count

            return tabWidth * tab.TabBar.index
                + (tabWidth - width) / 2
        }

        StyledRect {
            anchors.fill: parent

            radius: 0
            color: Colours.palette.m3primary
        }

        Behavior on x {
            Anim {}
        }
    }

    StyledRect {
        id: separator

        anchors.top: indicator.bottom
        anchors.topMargin: 7
        anchors.left: parent.left
        anchors.right: parent.right

        implicitHeight: 1

        color: Colours.palette.m3outlineVariant
    }

    component Tab: TabButton {
        id: tab

        required property string indexText
        readonly property bool current:
            TabBar.tabBar.currentItem === this

        background: null

        contentItem: CustomMouseArea {
            id: mouse

            implicitWidth: content.implicitWidth
            implicitHeight: content.implicitHeight + 4

            cursorShape: Qt.PointingHandCursor

            onPressed: event => {
                root.state.currentTab = tab.TabBar.index

                const stateY = stateWrapper.y

                rippleAnim.x = event.x
                rippleAnim.y = event.y - stateY

                const dist = (ox, oy) =>
                    ox * ox + oy * oy

                rippleAnim.radius = Math.sqrt(
                    Math.max(
                        dist(
                            event.x,
                            event.y + stateY
                        ),
                        dist(
                            event.x,
                            stateWrapper.height - event.y
                        ),
                        dist(
                            width - event.x,
                            event.y + stateY
                        ),
                        dist(
                            width - event.x,
                            stateWrapper.height - event.y
                        )
                    )
                )

                rippleAnim.restart()
            }

            function onWheel(event: WheelEvent): void {
                if (event.angleDelta.y < 0) {
                    root.state.currentTab =
                        Math.min(
                            root.state.currentTab + 1,
                            bar.count - 1
                        )
                } else if (event.angleDelta.y > 0) {
                    root.state.currentTab =
                        Math.max(
                            root.state.currentTab - 1,
                            0
                        )
                }
            }

            SequentialAnimation {
                id: rippleAnim

                property real x
                property real y
                property real radius

                PropertyAction {
                    target: ripple
                    property: "x"
                    value: rippleAnim.x
                }

                PropertyAction {
                    target: ripple
                    property: "y"
                    value: rippleAnim.y
                }

                PropertyAction {
                    target: ripple
                    property: "opacity"
                    value: 0.05
                }

                Anim {
                    target: ripple
                    properties:
                        "implicitWidth,implicitHeight"

                    from: 0
                    to: rippleAnim.radius * 2

                    duration:
                        Appearance.anim.durations.normal

                    easing.bezierCurve:
                        Appearance.anim.curves.standardDecel
                }

                Anim {
                    target: ripple
                    property: "opacity"
                    to: 0

                    duration:
                        Appearance.anim.durations.normal

                    easing.type:
                        Easing.BezierSpline

                    easing.bezierCurve:
                        Appearance.anim.curves.standard
                }
            }

            ClippingRectangle {
                id: stateWrapper

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                implicitHeight:
                    parent.height
                    + Config.dashboard.sizes.tabIndicatorSpacing * 2

                color: "transparent"
                radius: Appearance.rounding.small

                StyledRect {
                    anchors.fill: parent

                    color: tab.current
                        ? Colours.palette.m3primary
                        : Colours.palette.m3onSurface

                    opacity:
                        mouse.pressed
                        ? 0.06
                        : tab.hovered
                            ? 0.035
                            : 0

                    Behavior on opacity {
                        Anim {}
                    }
                }

                StyledRect {
                    id: ripple

                    radius: Appearance.rounding.full

                    color: tab.current
                        ? Colours.palette.m3primary
                        : Colours.palette.m3onSurface

                    opacity: 0

                    transform: Translate {
                        x: -ripple.width / 2
                        y: -ripple.height / 2
                    }
                }
            }

            RowLayout {
                id: content

                anchors.centerIn: parent

                spacing: 7

                StyledText {
                    text: tab.indexText

                    color: tab.current
                        ? Colours.palette.m3primary
                        : Colours.palette.m3outline

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 500
                    font.letterSpacing: 1

                    opacity: tab.current ? 1 : 0.65

                    Behavior on opacity {
                        Anim {}
                    }
                }

                StyledText {
                    text: tab.text

                    color: tab.current
                        ? Colours.palette.m3primary
                        : Colours.palette.m3onSurfaceVariant

                    font.pointSize:
                        Appearance.font.size.small

                    font.weight:
                        tab.current ? 600 : 400

                    font.letterSpacing: 1.8

                    Behavior on color {
                        CAnim {}
                    }
                }
            }
        }
    }
}