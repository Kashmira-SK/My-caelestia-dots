import QtQuick
import QtTest
import "../../modules/session"

TestCase {
    id: testCase
    name: "PowerRail"
    width: 160
    height: 520
    visible: true
    when: windowShown
    property int backgroundPresses: 0

    Rectangle {
        id: stage
        anchors.centerIn: parent
        width: 84
        height: 428
        radius: 12
        color: "#161616"

        MouseArea {
            id: dragSurface
            anchors.fill: parent
            onPressed: testCase.backgroundPresses++
        }

        PowerRailLayout {
            id: rail
            anchors.fill: parent
            anchors.margins: 14
            pairSpacing: 20
            centerMargin: 14

            // Presentation-only controls. No desktop services or power actions.
            upperContent: [
                MockButton {
                    id: first
                    label: "↪"
                    color: "#3c3445"
                },
                MockButton {
                    id: second
                    label: "⏻"
                }
            ]
            lowerContent: [
                MockButton {
                    id: third
                    label: "☾"
                },
                MockButton {
                    id: fourth
                    label: "⟳"
                }
            ]
            centerContent: [
                DotTrail {
                    id: trail
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 28
                    ink: "#8b8491"
                    animating: false
                }
            ]
        }
    }

    component MockButton: Rectangle {
        required property string label
        width: rail.width
        height: 48
        radius: 12
        color: "transparent"
        Text {
            anchors.centerIn: parent
            text: parent.label
            color: "#cfc8d5"
            font.pixelSize: 22
        }
    }

    function init() {
        stage.width = 84;
        stage.height = 428;
        trail.visible = true;
        trail.animating = false;
        trail.phase = 0;
        backgroundPresses = 0;
    }

    function test_pairsUseBothEnds() {
        for (const height of [348, 428, 508]) {
            stage.height = height;
            waitForRendering(rail);
            const upper = findChild(rail, "upperPowerGroup");
            const lower = findChild(rail, "lowerPowerGroup");
            const middle = findChild(rail, "powerRailCenter");
            compare(upper.y, 0);
            compare(lower.y + lower.height, rail.height);
            compare(second.y - first.y - first.height, 20);
            compare(fourth.y - third.y - third.height, 20);
            verify(middle.y >= upper.y + upper.height + 14);
            verify(middle.y + middle.height <= lower.y - 14);
            verify(trail.height > 0);
        }
    }

    function test_trailDoesNotCaptureDrag() {
        mousePress(trail, trail.width / 2, trail.height / 2);
        compare(backgroundPresses, 1);
        compare(dragSurface.pressed, true);
        mouseMove(stage, -20, stage.height / 2);
        compare(dragSurface.pressed, true);
        mouseRelease(stage, -20, stage.height / 2);
        compare(dragSurface.pressed, false);
    }

    function test_trailAnimationAndPreview() {
        tryCompare(trail, "available", true);
        trail.requestPaint();
        waitForRendering(trail);
        grabImage(stage).save("/tmp/caelestia-power-rail-preview.png");
        trail.animating = true;
        tryVerify(() => trail.phase > 0.05);
        trail.visible = false;
        const stopped = trail.phase;
        wait(120);
        compare(trail.phase, stopped);
    }
}
