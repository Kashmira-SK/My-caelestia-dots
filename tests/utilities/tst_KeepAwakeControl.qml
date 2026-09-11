pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import "../../modules/utilities/cards"

TestCase {
    id: testCase

    name: "KeepAwakeControl"
    width: 440
    height: 160
    visible: true
    when: windowShown

    // Isolated presentation fixture: never toggles the desktop's idle inhibitor.
    property bool inhibited: false
    property string sinceText: "Since 08:39 pm"
    readonly property var theme: ({
        m3primary: "steelblue",
        m3outlineVariant: "gray",
        m3onSurfaceVariant: "white",
        m3surfaceContainerHighest: "darkslategray"
    })
    readonly property var appearance: ({
        spacing: { normal: 10, small: 6 },
        rounding: { small: 12 },
        font: { family: { sans: "sans-serif", mono: "monospace" }, size: { small: 11, smaller: 10 } }
    })

    Component {
        id: controlComponent

        KeepAwakeControl {
            inhibited: testCase.inhibited
            sinceText: testCase.sinceText
            theme: testCase.theme
            appearance: testCase.appearance
            onToggleRequested: testCase.inhibited = !testCase.inhibited
        }
    }

    function init() {
        inhibited = false;
        sinceText = "Since 08:39 pm";
    }

    function makeControl(width = 372) {
        const control = createTemporaryObject(controlComponent, testCase, { width });
        verify(control !== null);
        tryVerify(() => control.height > 0);
        return control;
    }

    function assertTimestamp(control) {
        const timestamp = findChild(control, "awakeTimestamp");
        verify(timestamp !== null);
        tryVerify(() => timestamp.width > 100);
        compare(timestamp.text, sinceText);
        verify(timestamp.visible);
        verify(timestamp.x + timestamp.width <= timestamp.parent.width + 1);
    }

    function test_reopenWhileActive() {
        inhibited = true;
        for (let i = 0; i < 5; i++) {
            const control = makeControl();
            assertTimestamp(control);
            control.destroy();
            wait(0);
            compare(inhibited, true);
            compare(sinceText, "Since 08:39 pm");
        }
    }

    function test_toggleThenReopen() {
        const first = makeControl();
        mouseClick(first, first.width / 2, first.height / 2);
        compare(inhibited, true);
        assertTimestamp(first);
        first.destroy();
        wait(0);
        const reopened = makeControl();
        assertTimestamp(reopened);
        mouseClick(reopened, reopened.width / 2, reopened.height / 2);
        compare(inhibited, false);
    }

    function test_widthChangesAndExternalState() {
        const control = makeControl(280);
        inhibited = true;
        assertTimestamp(control);
        control.width = 400;
        assertTimestamp(control);
        inhibited = false;
        compare(findChild(control, "awakeTimestamp").text, "Click to keep awake");
        inhibited = true;
        sinceText = "Since 21:15";
        assertTimestamp(control);
    }

    function test_keyboardToggle() {
        const control = makeControl();
        control.forceActiveFocus();
        keyClick(Qt.Key_Space);
        compare(inhibited, true);
        keyClick(Qt.Key_Space);
        compare(inhibited, false);
    }
}
