import QtQuick
import QtTest

TestCase {
    id: testCase
    name: "PerformanceSizing"
    width: 900
    height: 650
    when: windowShown

    property var appearance: ({
            rounding: {
                panel: 6
            },
            padding: {
                normal: 10
            },
            spacing: {
                small: 7
            },
            font: {
                size: {
                    small: 11,
                    smaller: 12
                }
            }
        })
    property var colours: ({
            palette: {
                m3primary: "white",
                m3onSurfaceVariant: "white",
                m3outlineVariant: "gray"
            }
        })
    property string frameSource

    function initTestCase() {
        // Exercise the production frame with inert content, without starting
        // hardware monitoring or loading the user's desktop services.
        const request = new XMLHttpRequest();
        request.open("GET", Qt.resolvedUrl("../../modules/dashboard/Performance.qml"), false);
        request.send();
        const source = request.responseText;
        const start = source.indexOf("    component PerfFrame:");
        const end = source.indexOf("    component ProcessorBody:", start);
        verify(start >= 0 && end > start);
        frameSource = source.slice(start, end).replace(/\bAppearance\b/g, "testCase.appearance").replace(/\bColours\b/g, "testCase.colours").replace(/\b(MaterialIcon|StyledText)\b/g, "Text");
    }

    function test_contentFits_data() {
        return [
            {
                tag: "normal",
                panelWidth: 840,
                statsHeight: 44
            },
            {
                tag: "narrow",
                panelWidth: 420,
                statsHeight: 70
            },
            {
                tag: "large-text",
                panelWidth: 840,
                statsHeight: 110
            }
        ];
    }

    function test_contentFits(data) {
        const row = Qt.createQmlObject(`
            import QtQuick
            import QtQuick.Layouts
            RowLayout {
                width: ${data.panelWidth}; height: implicitHeight
                ${frameSource}
                PerfFrame {
                    objectName: "resources"; label: "Resources"; icon: "R"
                    Layout.preferredHeight: 188; Layout.fillHeight: true
                    Item { implicitHeight: 120 }
                }
                PerfFrame {
                    objectName: "network"; label: "Network"; icon: "N"
                    Layout.preferredHeight: 188; Layout.fillHeight: true
                    ColumnLayout {
                        spacing: 7
                        Item { implicitHeight: 88 }
                        Item { implicitHeight: 1 }
                        Item { implicitHeight: ${data.statsHeight} }
                        Item { objectName: "totals"; implicitHeight: 20 }
                    }
                }
            }
        `, testCase);
        try {
            verify(waitForItemPolished(row));
            const network = findChild(row, "network");
            const resources = findChild(row, "resources");
            const totals = findChild(row, "totals");
            verify(network.height >= network.implicitHeight);
            compare(resources.height, network.height);
            verify(totals.mapToItem(network, 0, totals.height).y <= network.height - 10);
        } finally {
            row.destroy();
        }
    }
}
