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
    spacing: Appearance.spacing.large * 2

    Center {
        lock: root.lock
        showClock: false
        Layout.preferredWidth: (root.width - root.spacing) * 0.43
        Layout.fillHeight: false
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: Appearance.padding.large
        Layout.topMargin: Appearance.padding.large
        Layout.bottomMargin: Appearance.padding.large
    }

    ColumnLayout {
        id: details
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.alignment: Qt.AlignVCenter
        spacing: Appearance.spacing.large
        Layout.rightMargin: Appearance.padding.large

        readonly property bool mediaPlaying: Players.active?.isPlaying ?? false

        // Render disjoint strips: the actual digits shift during each glitch.
        Item {
            id: clockItem
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: clockMetrics.implicitWidth + 24
            implicitHeight: clockMetrics.implicitHeight
            property real displacement: 0

            StyledText {
                id: clockMetrics
                visible: false
                text: Time.hourStr + ":" + Time.minuteStr
                font.family: "Rubik Glitch"
                font.pointSize: Appearance.font.size.extraLarge * 2
                renderType: Text.CurveRendering
            }

            Repeater {
                model: 5
                delegate: Item {
                    id: strip
                    required property int index
                    readonly property real stripHeight: clockMetrics.implicitHeight / 5
                    x: 12 + clockItem.displacement * (index % 2 === 0 ? 1 : -1)
                    y: index * stripHeight
                    width: clockMetrics.implicitWidth
                    height: stripHeight
                    clip: true

                    StyledText {
                        y: -strip.index * strip.stripHeight
                        text: clockMetrics.text
                        font: clockMetrics.font
                        renderType: Text.CurveRendering
                        color: Colours.palette.m3primary
                    }
                }
            }

            Timer {
                interval: 4800
                running: root.visible && !root.lock.unlocking
                repeat: true
                onTriggered: glitchAnim.restart()
            }

            SequentialAnimation {
                id: glitchAnim
                PropertyAction { target: clockItem; property: "displacement"; value: 5 }
                PauseAnimation { duration: 55 }
                PropertyAction { target: clockItem; property: "displacement"; value: -7 }
                PauseAnimation { duration: 45 }
                PropertyAction { target: clockItem; property: "displacement"; value: 2 }
                PauseAnimation { duration: 45 }
                PropertyAction { target: clockItem; property: "displacement"; value: 0 }
            }
        }

        // ── Greeting — vertically centered ─────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            Behavior on opacity {
                NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
            }

            StyledText {
                Layout.fillWidth: true
                Layout.topMargin: Appearance.spacing.small
                horizontalAlignment: Text.AlignHCenter
                readonly property int hr: Time.hours
                text: hr < 12 ? "Good morning," : hr < 17 ? "Good afternoon," : hr < 21 ? "Good evening," : "Good night,"
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.larger
                font.family: Appearance.font.family.sans
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: nameText.implicitHeight + Appearance.padding.normal * 2

                Text {
                    id: nameText
                    anchors.centerIn: parent
                    width: parent.width - Appearance.padding.large * 2
                    text: "Kashmira"
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.extraLarge * 4
                    minimumPointSize: Appearance.font.size.large
                    fontSizeMode: Text.HorizontalFit
                    horizontalAlignment: Text.AlignHCenter
                    renderType: Text.CurveRendering
                    font.family: "Great Vibes"
                    font.weight: Font.Normal
                }
            }

            property int msgIndex: Math.floor(Math.random() * 4)


            StyledText {
                Layout.fillWidth: true
                visible: !details.mediaPlaying
                horizontalAlignment: Text.AlignHCenter
                readonly property int hr: Time.hours
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

            Item {
                Layout.fillWidth: true
                implicitHeight: mediaWidget.implicitHeight
                visible: details.mediaPlaying

                Media {
                    id: mediaWidget
                    lock: root.lock
                }
            }

        }
    }
}
