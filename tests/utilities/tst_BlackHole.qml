import QtQuick
import QtTest
import "../../modules/sidebar"

TestCase {
    id: testCase
    name: "BlackHole"
    width: 340
    height: 340
    visible: true
    when: windowShown

    Rectangle {
        id: stage
        anchors.fill: parent
        color: "#161616"

        BlackHole {
            id: field
            anchors.centerIn: parent
            ink: "#8b8491"
            animating: false
        }
    }

    function test_renderAndPause() {
        tryCompare(field, "available", true);
        field.requestPaint();
        waitForRendering(field);
        const preview = grabImage(stage);
        compare(preview.width, stage.width);
        preview.save("/tmp/caelestia-black-hole-preview.png");
        field.animating = true;
        tryVerify(() => field.phase > 0.05);
        field.animating = false;
        const stopped = field.phase;
        wait(120);
        compare(field.phase, stopped);
        field.visible = false;
        field.animating = true;
        wait(120);
        compare(field.phase, stopped);
    }
}
