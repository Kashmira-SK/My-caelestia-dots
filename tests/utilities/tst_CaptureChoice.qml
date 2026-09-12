import QtQuick
import QtTest
import "../../modules/utilities/cards"

TestCase {
    id: testCase
    name: "CaptureChoice"
    width: 360
    height: 120
    visible: true
    when: windowShown

    property int clicks: 0
    property bool selected: false
    property var theme: ({ m3primary: "steelblue", m3onPrimary: "white", m3onSurfaceVariant: "silver", m3surfaceContainerHighest: "gray" })
    readonly property var appearance: ({ font: { family: { sans: "sans-serif" }, size: { small: 11 } }, rounding: { small: 12 } })

    Component {
        id: choiceComponent
        CaptureChoice {
            x: 20
            y: 20
            width: 100
            text: "Screen"
            selected: testCase.selected
            theme: testCase.theme
            appearance: testCase.appearance
            onClicked: {
                testCase.clicks++;
                testCase.selected = true;
            }
        }
    }

    function init() {
        clicks = 0;
        selected = false;
    }

    function test_hoverHasPaddingAndNoOutline() {
        const choice = createTemporaryObject(choiceComponent, testCase);
        verify(choice);
        const label = findChild(choice, "captureChoiceLabel");
        const background = findChild(choice, "captureChoiceBackground");
        for (const width of [90, 110, 160]) {
            choice.width = width;
            mouseMove(choice, width / 2, choice.height / 2);
            tryCompare(choice, "hovered", true);
            compare(background.border.width, 0);
            compare(label.font.underline, false);
            verify(label.width >= label.contentWidth);
            verify(label.height >= label.implicitHeight);
            verify(background.radius < choice.height / 2);
        }
    }

    function test_clicksAndKeyboardKeepExternalSelection() {
        const choice = createTemporaryObject(choiceComponent, testCase);
        for (let i = 0; i < 10; i++) {
            selected = false;
            mouseClick(choice);
            compare(selected, true);
        }
        compare(clicks, 10);
        choice.forceActiveFocus();
        selected = false;
        keyClick(Qt.Key_Space);
        compare(selected, true);
        compare(clicks, 11);
    }
}
