pragma ComponentBehavior: Bound
import qs.components
import qs.config
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services

StyledRect {
    id: root

    required property var noteData
    required property int noteIndex
    property int collapseCounter: 0

    signal noteChanged(int idx, var data)
    signal noteDeleted(int idx)

    property bool expanded: false
    readonly property int pad: Appearance.padding.normal

    onCollapseCounterChanged: expanded = false

    readonly property color cardColor: {
        switch (noteData.type) {
            case "important": return Colours.palette.m3tertiaryContainer
            case "todo":      return Colours.palette.m3secondaryContainer
            default:          return Colours.tPalette.m3surfaceContainer
        }
    }
    readonly property color onCard: {
        switch (noteData.type) {
            case "important": return Colours.palette.m3onTertiaryContainer
            case "todo":      return Colours.palette.m3onSecondaryContainer
            default:          return Colours.palette.m3onSurface
        }
    }
    readonly property color onCardVariant: {
        switch (noteData.type) {
            case "important": return Colours.palette.m3onTertiaryContainer
            case "todo":      return Colours.palette.m3onSecondaryContainer
            default:          return Colours.palette.m3onSurfaceVariant
        }
    }

    color: cardColor
    radius: Appearance.rounding.normal
    clip: true
    implicitWidth: parent?.width ?? 0
    implicitHeight: inner.implicitHeight + pad * 2

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.expressiveDefaultSpatial
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
        }
    }

    Behavior on color { CAnim {} }

    // tap to expand (compact only)
    MouseArea {
        anchors.fill: parent
        enabled: !root.expanded
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = true
    }

    ColumnLayout {
        id: inner
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: root.pad
        }
        spacing: Appearance.spacing.small

        // header row 
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            StyledText {
                text: root.noteData.created
                color: root.onCardVariant
                font.pixelSize: Appearance.font.size.small
                visible: root.expanded
            }

            Item { Layout.fillWidth: true }

            StyledText {
                text: root.noteData.type.charAt(0).toUpperCase() + root.noteData.type.slice(1)
                color: root.onCardVariant
                font.pixelSize: Appearance.font.size.small
            }

            StyledText {
                text: "expand_less"
                font.family: Appearance.font.family.material
                font.pixelSize: Appearance.font.size.normal
                color: root.onCardVariant
                visible: root.expanded
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.noteData.type !== "todo") {
                            var updated = Object.assign({}, root.noteData)
                            updated.content = contentArea.text
                            root.noteChanged(root.noteIndex, updated)
                        }
                        root.expanded = false
                    }
                }
            }
        }

        // compact: first line preview
        StyledText {
            Layout.fillWidth: true
            text: root.noteData.content.split("\n")[0].replace(/^\[[ x]\] /, "")
            color: root.onCard
            font.pixelSize: 13
            font.weight: Font.Medium
            elide: Text.ElideRight
            visible: !root.expanded
        }

        // compact: date + tags
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.smaller
            visible: !root.expanded

            StyledText {
                text: root.noteData.created
                color: root.onCardVariant
                font.pixelSize: Appearance.font.size.small
            }

            Repeater {
                model: root.noteData.tags ?? []
                delegate: StyledRect {
                    required property string modelData
                    radius: Appearance.rounding.full
                    color: Qt.alpha(root.onCardVariant, 0.2)
                    implicitWidth: tl.implicitWidth + Appearance.padding.small * 2
                    implicitHeight: tl.implicitHeight + 2
                    StyledText {
                        id: tl
                        anchors.centerIn: parent
                        text: parent.modelData
                        color: root.onCardVariant
                        font.pixelSize: Appearance.font.size.small
                    }
                }
            }
        }

        // expanded: divider 
        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Qt.alpha(root.onCardVariant, 0.3)
            visible: root.expanded
        }

        // expanded: text area (normal / important)
        TextArea {
            id: contentArea
            Layout.fillWidth: true
            visible: root.expanded && root.noteData.type !== "todo"
            height: visible ? Math.max(80, implicitHeight) : 0
            wrapMode: TextEdit.Wrap
            background: null
            color: root.onCard
            text: root.noteData.content
            font.family: Appearance.font.family.sans
            font.pixelSize: 14
            selectionColor: Qt.alpha(Colours.palette.m3primary, 0.3)
            selectedTextColor: root.onCard
        }

        // expanded: todo checklist
        Column {
            Layout.fillWidth: true
            spacing: Appearance.spacing.smaller
            visible: root.expanded && root.noteData.type === "todo"
            height: visible ? implicitHeight : 0

            Repeater {
                model: root.noteData.type === "todo"
                    ? root.noteData.content.split("\n").filter(l => l.trim().length > 0)
                    : []

                delegate: RowLayout {
                    required property string modelData
                    required property int index
                    width: parent.width
                    spacing: Appearance.spacing.small

                    readonly property bool isChecked: modelData.startsWith("[x]")
                    readonly property string itemText: modelData.replace(/^\[[ x]\] /, "")

                    StyledText {
                        text: parent.isChecked ? "check_box" : "check_box_outline_blank"
                        font.family: Appearance.font.family.material
                        font.pixelSize: Appearance.font.size.normal
                        color: root.onCard
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var lines = root.noteData.content.split("\n")
                                lines[parent.index] = (parent.isChecked ? "[ ] " : "[x] ") + parent.itemText
                                var updated = Object.assign({}, root.noteData)
                                updated.content = lines.join("\n")
                                root.noteChanged(root.noteIndex, updated)
                            }
                        }
                    }

                    StyledText {
                        text: parent.itemText
                        color: root.onCard
                        font.pixelSize: 14
                        font.strikeout: parent.isChecked
                        opacity: parent.isChecked ? 0.5 : 1
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }
            }
        }

        //expanded: bottom toolbar
        RowLayout {
            Layout.fillWidth: true
            visible: root.expanded
            spacing: Appearance.spacing.small

            Repeater {
                model: root.noteData.tags ?? []
                delegate: StyledRect {
                    required property string modelData
                    radius: Appearance.rounding.full
                    color: Qt.alpha(root.onCardVariant, 0.2)
                    implicitWidth: tl2.implicitWidth + Appearance.padding.small * 2
                    implicitHeight: tl2.implicitHeight + 2
                    StyledText {
                        id: tl2
                        anchors.centerIn: parent
                        text: parent.modelData
                        color: root.onCardVariant
                        font.pixelSize: Appearance.font.size.small
                    }
                }
            }

            Item { Layout.fillWidth: true }

            StyledText {
                text: "delete"
                font.family: Appearance.font.family.material
                font.pixelSize: Appearance.font.size.normal
                color: root.onCardVariant
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.noteDeleted(root.noteIndex)
                }
            }

            StyledRect {
                radius: Appearance.rounding.full
                color: Qt.alpha(root.onCard, 0.2)
                implicitWidth: doneLbl.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: doneLbl.implicitHeight + Appearance.padding.small * 2

                StyledText {
                    id: doneLbl
                    anchors.centerIn: parent
                    text: "Done"
                    color: root.onCard
                    font.pixelSize: Appearance.font.size.small
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.noteData.type !== "todo") {
                            var updated = Object.assign({}, root.noteData)
                            updated.content = contentArea.text
                            root.noteChanged(root.noteIndex, updated)
                        }
                        root.expanded = false
                    }
                }
            }
        }
    }
}
