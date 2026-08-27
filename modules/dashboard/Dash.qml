import qs.components
import qs.components.filedialog
import qs.services
import qs.config
import "dash"
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties visibilities
    required property PersistentProperties state
    required property FileDialog facePicker

    readonly property int leftGutter: 24
    readonly property int leftW: 215
    readonly property int rightW: 270
    readonly property int gap: Appearance.spacing.normal
    readonly property int centerW: implicitWidth - leftW - rightW - gap * 2

    implicitWidth: 840
    implicitHeight: 520
    width: implicitWidth
    height: implicitHeight

    ColumnLayout {
        id: leftCol
        x: 0
        y: 0
        width: root.leftW
        height: root.height
        spacing: root.gap

        Item {
            id: systemWrapper

            Layout.fillWidth: true
            Layout.preferredHeight:
                systemWidget.implicitHeight
                + Appearance.padding.large * 2

            Card {
                id: systemCard

                anchors.left: parent.left
                anchors.leftMargin: root.leftGutter
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                // We draw this card's border ourselves so that the
                // left edge can have a real gap behind SYSTEM.
                border.width: 0

                User {
                    id: systemWidget

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    visibilities: root.visibilities
                    state: root.state
                    facePicker: root.facePicker
                }

                Canvas {
                    id: systemBorder

                    anchors.fill: parent
                    z: 5

                    antialiasing: true

                    function redraw() {
                        requestPaint()
                    }

                    onPaint: {
                        const ctx = getContext("2d")

                        ctx.clearRect(0, 0, width, height)

                        const w = width
                        const h = height
                        const r = Math.min(
                            Appearance.rounding.large,
                            Math.min(w, h) / 2
                        )

                        /*
                         * SYSTEM is rotated -90 degrees, so its
                         * horizontal painted width becomes the
                         * vertical space it occupies on screen.
                         *
                         * Add a little breathing room on each side
                         * so the border doesn't visually touch it.
                         */
                        const gapHeight = sysLabel.paintedWidth + 10
                        const centerY = h / 2
                        const gapTop = centerY - gapHeight / 2
                        const gapBottom = centerY + gapHeight / 2

                        ctx.strokeStyle =
                            Colours.palette.m3outlineVariant

                        ctx.lineWidth = 1
                        ctx.lineJoin = "round"
                        ctx.lineCap = "butt"

                        ctx.beginPath()

                        // Top-left corner
                        ctx.moveTo(r, 0)

                        // Top edge
                        ctx.lineTo(w - r, 0)

                        // Top-right corner
                        ctx.quadraticCurveTo(w, 0, w, r)

                        // Right edge
                        ctx.lineTo(w, h - r)

                        // Bottom-right corner
                        ctx.quadraticCurveTo(w, h, w - r, h)

                        // Bottom edge
                        ctx.lineTo(r, h)

                        // Bottom-left corner
                        ctx.quadraticCurveTo(0, h, 0, h - r)

                        // Left edge — BELOW SYSTEM
                        ctx.lineTo(0, gapBottom)

                        // Leave a real gap behind SYSTEM.
                        ctx.moveTo(0, gapTop)

                        // Left edge — ABOVE SYSTEM
                        ctx.lineTo(0, r)

                        // Top-left corner
                        ctx.quadraticCurveTo(0, 0, r, 0)

                        ctx.stroke()
                    }

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                }

                Item {
                    id: sysLabelItem

                    anchors.verticalCenter: parent.verticalCenter
                    x: -width / 2

                    width: sysLabel.implicitHeight + 6
                    height: sysLabel.implicitWidth + 14

                    z: 10

                    StyledText {
                        id: sysLabel

                        anchors.centerIn: parent

                        text: qsTr("SYSTEM")

                        color: Colours.palette.m3outline

                        font.pointSize: Appearance.font.size.small
                        font.weight: 600
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 3

                        rotation: -90
                        transformOrigin: Item.Center

                        onImplicitWidthChanged: systemBorder.requestPaint()
                        onImplicitHeightChanged: systemBorder.requestPaint()
                        onPaintedWidthChanged: systemBorder.requestPaint()
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Card {
                anchors.left: parent.left
                anchors.leftMargin: root.leftGutter
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Quote {
                    anchors.fill: parent
                }
            }
        }
    }

    ColumnLayout {
        id: centerCol

        x: root.leftW + root.gap
        y: 0
        width: root.centerW
        height: root.height
        spacing: root.gap

        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 340

            DateTime {
                anchors.fill: parent
            }
        }

        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true

            DayProgress {
                anchors.fill: parent
            }
        }
    }

    ColumnLayout {
        id: rightCol

        x: root.leftW + root.gap + root.centerW + root.gap
        y: 0
        width: root.rightW
        height: root.height
        spacing: root.gap

        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Appearance.padding.large
                spacing: Appearance.spacing.normal

                Character {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 170
                    state: root.state
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Colours.palette.m3outlineVariant
                }

                Media {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    state: root.state
                }
            }
        }
    }

    component Card: StyledRect {
        radius: Appearance.rounding.large

        color: Colours.layer(
            Colours.palette.m3surfaceContainer,
            2
        )

        border.color: Colours.palette.m3outlineVariant
        border.width: 1
    }
}
