pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property var lock
    spacing: Appearance.spacing.large * 3

    Center {
        lock: root.lock
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        readonly property bool mediaPlaying: Players.active?.isPlaying ?? false

        // ── Glitch clock top-right ──────────────────────────────────────────
        Item {
            id: clockItem
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Appearance.padding.large * 3
            anchors.rightMargin: Appearance.padding.large * 2
            width: 300
            height: 90

            StyledText {
                id: clockBase
                x: 0
                y: 0
                text: Time.hourStr + ":" + Time.minuteStr
                color: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.extraLarge * 2.4
                font.family: "Rubik Glitch"
                font.bold: true
            }

            // Subtle white ghost 1 — left
            StyledText {
                id: g1
                x: 0
                y: 0
                text: clockBase.text
                color: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.extraLarge * 2.4
                font.family: "Rubik Glitch"
                font.bold: true
                opacity: 0
            }

            // Subtle white ghost 2 — right
            StyledText {
                id: g2
                x: 0
                y: 0
                text: clockBase.text
                color: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.extraLarge * 2.4
                font.family: "Rubik Glitch"
                font.bold: true
                opacity: 0
            }

            Timer {
                interval: 3500
                running: true
                onTriggered: glitchAnim.restart()
            }

            SequentialAnimation {
                id: glitchAnim
                ParallelAnimation {
                    PropertyAction { target: g1; property: "x"; value: -14 }
                    PropertyAction { target: g1; property: "y"; value: -1 }
                    PropertyAction { target: g1; property: "opacity"; value: 0.4 }
                    PropertyAction { target: g2; property: "x"; value: 12 }
                    PropertyAction { target: g2; property: "y"; value: 1 }
                    PropertyAction { target: g2; property: "opacity"; value: 0.3 }
                }
                PauseAnimation { duration: 70 }
                ParallelAnimation {
                    PropertyAction { target: g1; property: "x"; value: 16 }
                    PropertyAction { target: g2; property: "x"; value: -12 }
                }
                PauseAnimation { duration: 45 }
                ParallelAnimation {
                    PropertyAction { target: g1; property: "opacity"; value: 0 }
                    PropertyAction { target: g1; property: "x"; value: 0 }
                    PropertyAction { target: g1; property: "y"; value: 0 }
                    PropertyAction { target: g2; property: "opacity"; value: 0 }
                    PropertyAction { target: g2; property: "x"; value: 0 }
                    PropertyAction { target: g2; property: "y"; value: 0 }
                }
            }
        }

        // ── Greeting — vertically centered ─────────────────────────────────
        ColumnLayout {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 60
            spacing: Appearance.spacing.large * 3
            opacity: parent.mediaPlaying ? 0 : 1
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
            }

            StyledText {
                Layout.alignment: Qt.AlignLeft
                readonly property int hr: new Date().getHours()
                text: hr < 12 ? "Good morning," : hr < 17 ? "Good afternoon," : hr < 21 ? "Good evening," : "Good night,"
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.extraLarge
                font.family: Appearance.font.family.sans
            }

            Item {
                Layout.alignment: Qt.AlignLeft
                implicitWidth: nameText.implicitWidth
                implicitHeight: nameText.implicitHeight

                Text {
                    id: nameText
                    text: "Kashmira"
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.extraLarge * 4
                    font.family: "Great Vibes"
                    font.weight: Font.Normal
                    rotation: -8
                    transformOrigin: Item.Left
                }
            }

            property int msgIndex: Math.floor(Math.random() * 4)

            }

            StyledText {
                Layout.alignment: Qt.AlignLeft
                Layout.maximumWidth: 400
                readonly property int hr: new Date().getHours()
                readonly property var msgs: hr < 12 ? [
                    "The morning light is soft and new,\nmay all your plans come gently true.",
                    "A brand new day is yours to own,\nthe seeds you plant today are sown.",
                    "Rise and shine, the world awaits,\nopen wide your morning gates.",
                    "Every morning holds a chance,\nto grow, to love, to sing and dance."
                ] : hr < 17 ? [
                    "The day is yours to shape and keep,\nmay every moment run beautifully deep. 🌸",
                    "You're halfway through, keep going strong,\nthe afternoon won't last too long.",
                    "Take a breath, you're doing great,\nsome things are worth the extra wait.",
                    "The sun is high, the day is bright,\neverything will be alright."
                ] : hr < 21 ? [
                    "The evening folds the daylight in,\nyou made it through — that's always a win.",
                    "The day winds down, the sky turns gold,\nyou've got stories yet to be told.",
                    "Well done today, you gave your best,\nnow let the evening do the rest.",
                    "The dusk is soft, the air is kind,\nleave all your worries far behind."
                ] : [
                    "The stars are out, the world is still,\nrest easy now, you've had your fill.",
                    "Close your eyes, let dreams begin,\ntomorrow's waiting just within.",
                    "The night is calm, the day is done,\nyou were enough — you were the one.",
                    "Sleep well, dream deep, rest your soul,\nmorning comes to make you whole."
                ]
                text: msgs[parent.msgIndex % msgs.length]
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.normal
                font.family: Appearance.font.family.mono
                wrapMode: Text.WordWrap
                lineHeight: 1.5
            }
        }

        // ── Media centered ──────────────────────────────────────────────────
        Item {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 60
            width: parent.width * 0.85
            implicitHeight: mediaWidget.implicitHeight
            opacity: parent.mediaPlaying ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
            }

            Media {
                id: mediaWidget
                lock: root.lock
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
    }
}
