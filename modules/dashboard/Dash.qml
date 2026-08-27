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

    readonly property int leftGutter: 4
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

                    property color borderColour:
                        Colours.palette.m3outlineVariant

                    onBorderColourChanged: requestPaint()

                    onPaint: {
                        const ctx = getContext("2d")

                        ctx.clearRect(0, 0, width, height)

                        const w = width
                        const h = height

                        const r = Math.min(
                            Appearance.rounding.large,
                            Math.min(w, h) / 2
                        )

                        const gapHeight = sysLabel.paintedWidth + 10
                        const centerY = h / 2
                        const gapTop = centerY - gapHeight / 2
                        const gapBottom = centerY + gapHeight / 2

                        ctx.strokeStyle = borderColour
                        ctx.lineWidth = 1
                        ctx.lineJoin = "round"
                        ctx.lineCap = "butt"

                        ctx.beginPath()

                        ctx.moveTo(r, 0)
                        ctx.lineTo(w - r, 0)
                        ctx.quadraticCurveTo(w, 0, w, r)

                        ctx.lineTo(w, h - r)
                        ctx.quadraticCurveTo(w, h, w - r, h)

                        ctx.lineTo(r, h)
                        ctx.quadraticCurveTo(0, h, 0, h - r)

                        ctx.lineTo(0, gapBottom)

                        ctx.moveTo(0, gapTop)
                        ctx.lineTo(0, r)

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

                        onPaintedWidthChanged:
                            systemBorder.requestPaint()
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            EdgeLabelCard {
                labelText: qsTr("QUOTE")
                labelEdge: "top"
                labelAlignment: Qt.AlignLeft

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

        EdgeLabelCard {
            labelText: qsTr("TIME")
            labelEdge: "right"
            labelAlignment: Qt.AlignVCenter

            Layout.fillWidth: true
            Layout.preferredHeight: 340

            DateTime {
                anchors.fill: parent
            }
        }

        EdgeLabelCard {
            labelText: qsTr("DAY")
            labelEdge: "top"
            labelAlignment: Qt.AlignLeft

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

        EdgeLabelCard {
            labelText: qsTr("MEDIA")
            labelEdge: "bottom"
            labelAlignment: Qt.AlignRight

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: 8

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

    component EdgeLabelCard: StyledRect {
        id: edgeCard

        property string labelText: ""
        property string labelEdge: "top"
        property int labelAlignment: Qt.AlignLeft

        property real labelMargin:
            Appearance.rounding.large
            + Appearance.spacing.small

        property real labelGapPadding: 7
        property real labelOpticalOffset: 1

        default property alias contentData: contentHost.data

        radius: Appearance.rounding.large

        color: Colours.layer(
            Colours.palette.m3surfaceContainer,
            2
        )

        border.width: 0

        onLabelEdgeChanged: borderCanvas.requestPaint()
        onLabelAlignmentChanged: borderCanvas.requestPaint()
        onLabelMarginChanged: borderCanvas.requestPaint()
        onLabelGapPaddingChanged: borderCanvas.requestPaint()

        Item {
            id: contentHost
            anchors.fill: parent
        }

        Canvas {
            id: borderCanvas

            anchors.fill: parent
            z: 5
            antialiasing: true

            property color borderColour:
                Colours.palette.m3outlineVariant

            onBorderColourChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d")

                ctx.clearRect(0, 0, width, height)

                const w = width
                const h = height
                const inset = 0.5

                const left = inset
                const top = inset
                const right = w - inset
                const bottom = h - inset

                const r = Math.max(
                    0,
                    Math.min(
                        Appearance.rounding.large - inset,
                        Math.min(w, h) / 2 - inset
                    )
                )

                ctx.strokeStyle = borderColour
                ctx.lineWidth = 1
                ctx.lineJoin = "round"
                ctx.lineCap = "butt"

                ctx.beginPath()

                if (edgeCard.labelEdge === "right") {
                    const gapTop = Math.max(
                        top + r + 2,
                        edgeLabelItem.y
                            - edgeCard.labelGapPadding
                    )

                    const gapBottom = Math.min(
                        bottom - r - 2,
                        edgeLabelItem.y
                            + edgeLabelItem.height
                            + edgeCard.labelGapPadding
                    )

                    ctx.moveTo(left + r, top)
                    ctx.lineTo(right - r, top)

                    ctx.quadraticCurveTo(
                        right,
                        top,
                        right,
                        top + r
                    )

                    ctx.lineTo(right, gapTop)

                    ctx.moveTo(right, gapBottom)

                    ctx.lineTo(right, bottom - r)

                    ctx.quadraticCurveTo(
                        right,
                        bottom,
                        right - r,
                        bottom
                    )

                    ctx.lineTo(left + r, bottom)

                    ctx.quadraticCurveTo(
                        left,
                        bottom,
                        left,
                        bottom - r
                    )

                    ctx.lineTo(left, top + r)

                    ctx.quadraticCurveTo(
                        left,
                        top,
                        left + r,
                        top
                    )
                } else if (edgeCard.labelEdge === "bottom") {
                    const rawGapStart =
                        edgeLabelItem.x
                        - edgeCard.labelGapPadding

                    const rawGapEnd =
                        edgeLabelItem.x
                        + edgeLabelItem.width
                        + edgeCard.labelGapPadding

                    const gapStart = Math.max(
                        left + r + 2,
                        rawGapStart
                    )

                    const gapEnd = Math.min(
                        right - r - 2,
                        rawGapEnd
                    )

                    ctx.moveTo(left + r, top)
                    ctx.lineTo(right - r, top)

                    ctx.quadraticCurveTo(
                        right,
                        top,
                        right,
                        top + r
                    )

                    ctx.lineTo(right, bottom - r)

                    ctx.quadraticCurveTo(
                        right,
                        bottom,
                        right - r,
                        bottom
                    )

                    ctx.lineTo(gapEnd, bottom)

                    ctx.moveTo(gapStart, bottom)

                    ctx.lineTo(left + r, bottom)

                    ctx.quadraticCurveTo(
                        left,
                        bottom,
                        left,
                        bottom - r
                    )

                    ctx.lineTo(left, top + r)

                    ctx.quadraticCurveTo(
                        left,
                        top,
                        left + r,
                        top
                    )
                } else {
                    const rawGapStart =
                        edgeLabelItem.x
                        - edgeCard.labelGapPadding

                    const rawGapEnd =
                        edgeLabelItem.x
                        + edgeLabelItem.width
                        + edgeCard.labelGapPadding

                    const gapStart = Math.max(
                        left + r + 2,
                        rawGapStart
                    )

                    const gapEnd = Math.min(
                        right - r - 2,
                        rawGapEnd
                    )

                    ctx.moveTo(left + r, top)
                    ctx.lineTo(gapStart, top)

                    ctx.moveTo(gapEnd, top)

                    ctx.lineTo(right - r, top)

                    ctx.quadraticCurveTo(
                        right,
                        top,
                        right,
                        top + r
                    )

                    ctx.lineTo(right, bottom - r)

                    ctx.quadraticCurveTo(
                        right,
                        bottom,
                        right - r,
                        bottom
                    )

                    ctx.lineTo(left + r, bottom)

                    ctx.quadraticCurveTo(
                        left,
                        bottom,
                        left,
                        bottom - r
                    )

                    ctx.lineTo(left, top + r)

                    ctx.quadraticCurveTo(
                        left,
                        top,
                        left + r,
                        top
                    )
                }

                ctx.stroke()
            }

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        Item {
            id: edgeLabelItem

            width: edgeCard.labelEdge === "right"
                ? edgeLabel.implicitHeight + 4
                : edgeLabel.implicitWidth

            height: edgeCard.labelEdge === "right"
                ? edgeLabel.implicitWidth + 8
                : edgeLabel.implicitHeight

            x: {
                if (edgeCard.labelEdge === "right") {
                    return edgeCard.width
                        - width / 2
                        - edgeCard.labelOpticalOffset
                }

                if (edgeCard.labelAlignment === Qt.AlignRight) {
                    return edgeCard.width
                        - edgeCard.labelMargin
                        - width
                }

                if (
                    edgeCard.labelAlignment
                    === Qt.AlignHCenter
                ) {
                    return (
                        edgeCard.width - width
                    ) / 2
                }

                return edgeCard.labelMargin
            }

            y: {
                if (edgeCard.labelEdge === "right") {
                    return (
                        edgeCard.height - height
                    ) / 2
                }

                if (edgeCard.labelEdge === "bottom") {
                    return edgeCard.height
                        - height / 2
                        - edgeCard.labelOpticalOffset
                }

                return -height / 2
                    + edgeCard.labelOpticalOffset
            }

            z: 10

            onXChanged: borderCanvas.requestPaint()
            onYChanged: borderCanvas.requestPaint()
            onWidthChanged: borderCanvas.requestPaint()
            onHeightChanged: borderCanvas.requestPaint()

            StyledText {
                id: edgeLabel

                anchors.centerIn: parent

                text: edgeCard.labelText
                color: Colours.palette.m3outline

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 600
                font.capitalization:
                    Font.AllUppercase

                font.letterSpacing: 2

                rotation:
                    edgeCard.labelEdge === "right"
                    ? 90
                    : 0

                transformOrigin: Item.Center
            }
        }
    }

    component Card: StyledRect {
        radius: Appearance.rounding.large

        color: Colours.layer(
            Colours.palette.m3surfaceContainer,
            2
        )

        border.color:
            Colours.palette.m3outlineVariant

        border.width: 1
    }
}