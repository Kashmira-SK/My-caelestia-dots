import QtQuick
import QtTest
import "../../modules/sidebar"

TestCase {
    id: testCase
    name: "SpaceScene"
    width: 360
    height: 560
    visible: true
    when: windowShown

    property int notificationCount: 0
    property color ink: "#8b8491"

    Rectangle {
        id: stage
        anchors.fill: parent
        color: "#161616"

        Loader {
            id: emptyState
            anchors.fill: parent
            active: testCase.notificationCount === 0
            sourceComponent: SpaceScene {
                ink: testCase.ink
                animating: false
            }
        }
    }

    function init() {
        ink = "#8b8491";
        notificationCount = 0;
        tryVerify(() => emptyState.item !== null);
        emptyState.item.visible = true;
        emptyState.item.animating = false;
        emptyState.item.phase = 0;
        width = 360;
        height = 560;
    }

    function test_renderAtPanelSizes() {
        for (const size of [[200, 240], [260, 400], [360, 560], [430, 760]]) {
            width = size[0];
            height = size[1];
            const sky = findChild(emptyState.item, "spaceSky");
            tryCompare(sky, "available", true);
            sky.requestPaint();
            waitForRendering(sky);
            compare(emptyState.item.width, width);
            compare(emptyState.item.height, height);
            if (width === 360)
                grabImage(stage).save("/tmp/caelestia-space-scene-preview.png");
        }
    }

    function test_notificationsDestroyAndRecreateScene() {
        for (let i = 0; i < 5; i++) {
            emptyState.item.animating = true;
            tryVerify(() => emptyState.item.phase > 0);
            notificationCount = 1;
            tryCompare(emptyState, "item", null);
            notificationCount = 0;
            tryVerify(() => emptyState.item !== null);
            compare(emptyState.item.phase, 0);
        }
    }

    function test_hidePausesAndPalettePropagates() {
        const scene = emptyState.item;
        scene.animating = true;
        tryVerify(() => scene.phase > 0.05);
        scene.visible = false;
        const paused = scene.phase;
        wait(120);
        compare(scene.phase, paused);
        scene.animating = false;
        scene.visible = true;
        ink = "#8877aa";
        compare(scene.ink, ink);
        compare(findChild(scene, "spaceBlackHole").ink, ink);
    }
}
