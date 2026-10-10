import QtQuick
import QtQuick.Controls
import QtTest

TestCase {
    id: testCase
    name: "SettingsConsistency"
    width: 800
    height: 600
    visible: true
    when: windowShown
    property var appearance: ({padding: {large: 16, normal: 12}, spacing: {large: 16}, font: {size: {scale: 1}}})
    property var theme: ({palette: {m3primary: "cyan", m3onSurfaceVariant: "white", m3surfaceContainerLow: "black", m3outlineVariant: "gray"}})
    property var fixture

    function create(name) {
        const request = new XMLHttpRequest();
        request.open("GET", Qt.resolvedUrl("../../modules/controlcenter/components/" + name + ".qml"), false);
        request.send();
        const source = request.responseText.replace(/^import .*$/gm, "").replace(/^pragma .*$/gm, "")
            .replace(/\bAppearance\b/g, "testCase.appearance").replace(/\bColours\b/g, "testCase.theme")
            .replace(/\bStyledTextField\b/g, "TextField").replace(/\bStyledText\b/g, "Text");
        fixture = Qt.createQmlObject('import QtQuick; import QtQuick.Controls; import QtQuick.Controls as Controls; import QtQuick.Layouts;\n' + source, testCase);
        return fixture;
    }
    function cleanup() { if (fixture) fixture.destroy(); fixture = null; }
    function test_detail_viewport() {
        const pane = create("SplitPaneLayout");
        pane.width = 800; pane.height = 600; pane.singlePane = true;
        compare(pane.leftLoader.width, 744);
        pane.showRightPane = true;
        compare(pane.rightLoader.width, 744);
        compare(pane.rightLoader.y, 64);
        verify(pane.rightLoader.clip, "Scrolling must not paint over Back to list");
        pane.showRightPane = false;
        compare(pane.leftLoader.width, 744, "Returning must not resize the list");
        pane.showRightPane = true;
        compare(pane.rightLoader.width, 744);
    }
    function test_decimal_stepper() {
        const spin = create("SettingsSpinBox");
        spin.decimals = 1; spin.from = 1; spin.to = 50; spin.value = 10;
        compare(spin.textFromValue(spin.value, Qt.locale("en_US")), "1.0");
        mouseClick(spin, spin.width - 14, spin.height / 2);
        compare(spin.value, 11);
        mouseClick(spin, 14, spin.height / 2);
        compare(spin.value, 10);
        compare(spin.valueFromText("1.5", Qt.locale("en_US")), 15);
    }
}
