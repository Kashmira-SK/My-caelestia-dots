pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

StyledWindow {
    id: root

    signal dismissed
    property bool opened: false
    property bool confirmingClear: false
    property var entries: []
    property string error: ""
    readonly property string helper: Paths.toLocalFile(Qt.resolvedUrl("backend.py"))
    readonly property var filtered: entries.filter(e => e.text.toLowerCase().includes(search.text.toLowerCase()))

    function dismiss(): void { opened = false; }
    function run(action: string, id: string): void {
        if (operation.running) return;
        error = "";
        operation.action = action;
        operation.command = ["python3", helper, action].concat(id ? [id] : []);
        operation.running = true;
    }

    name: "clipboard"
    screen: Quickshell.screens.find(s => s.name === Hypr.focusedMonitor?.name) ?? Quickshell.screens[0]
    implicitWidth: Math.min(620, screen.width - 40)
    implicitHeight: Math.min(650, screen.height - 80)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Component.onCompleted: {
        opened = true;
        run("list", "");
        search.forceActiveFocus();
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.opened
        onCleared: root.dismiss()
    }

    Timer {
        interval: Appearance.anim.durations.normal + 30
        running: !root.opened
        onTriggered: root.dismissed()
    }

    Process {
        id: operation
        property string action
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (result.error) root.error = result.error;
                    else if (operation.action === "list") root.entries = result.entries;
                    else if (operation.action === "copy") root.dismiss();
                } catch (_) { root.error = qsTr("Could not read clipboard history."); }
            }
        }
        onExited: (code, status) => {
            if (code !== 0 && !root.error) root.error = qsTr("Clipboard command failed.");
            if (code === 0 && (action === "delete" || action === "wipe")) root.run("list", "");
        }
    }

    StyledRect {
        id: panel
        anchors.fill: parent
        anchors.margins: 8
        radius: Appearance.rounding.large
        color: Colours.palette.m3surfaceContainer
        border.width: 1
        border.color: Colours.palette.m3outlineVariant
        opacity: root.opened ? 1 : 0
        scale: root.opened ? 1 : 0.96
        enabled: root.opened

        Behavior on opacity { Anim {} }
        Behavior on scale { Anim {} }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                MaterialIcon { text: "content_paste" }
                StyledText {
                    text: qsTr("Clipboard")
                    font.pointSize: Appearance.font.size.large
                    Layout.fillWidth: true
                }
                IconButton {
                    icon: root.confirmingClear ? "check" : "delete_sweep"
                    type: IconButton.Text
                    disabled: !root.entries.length || operation.running
                    Accessible.name: root.confirmingClear ? qsTr("Confirm clear history") : qsTr("Clear history")
                    onClicked: {
                        if (root.confirmingClear) root.run("wipe", "");
                        root.confirmingClear = !root.confirmingClear;
                    }
                }
                IconButton {
                    icon: "close"
                    type: IconButton.Text
                    Accessible.name: qsTr("Close clipboard")
                    onClicked: root.dismiss()
                }
            }

            StyledText {
                visible: root.confirmingClear
                text: qsTr("Clear all history? Click the checkmark to confirm.")
                color: Colours.palette.m3primary
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 48
                radius: Appearance.rounding.normal
                color: Colours.palette.m3surfaceContainerHigh
                StyledTextField {
                    id: search
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.small
                    placeholderText: qsTr("Search clipboard history…")
                    onTextChanged: list.currentIndex = 0
                    Keys.onEscapePressed: root.dismiss()
                    Keys.onDownPressed: list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
                    Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)
                    Keys.onReturnPressed: if (list.currentIndex >= 0 && list.count) root.run("copy", root.filtered[list.currentIndex].id)
                    Keys.onDeletePressed: event => {
                        if (event.modifiers & Qt.ControlModifier && list.count) {
                            root.run("delete", root.filtered[list.currentIndex].id);
                            event.accepted = true;
                        } else event.accepted = false;
                    }
                }
            }

            StyledText {
                visible: !!root.error
                text: root.error
                color: Colours.palette.m3error
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: Appearance.spacing.small
                model: root.filtered
                currentIndex: 0
                cacheBuffer: 0
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                delegate: Entry {
                    required property var modelData
                    required property int index
                    width: list.width
                    entry: modelData
                    helper: root.helper
                    selected: list.currentIndex === index
                    busy: operation.running
                    onChosen: root.run("copy", modelData.id)
                    onRemove: root.run("delete", modelData.id)
                }
                StyledText {
                    anchors.centerIn: parent
                    visible: !list.count
                    text: operation.running ? qsTr("Loading history…") : search.text ? qsTr("No matching entries") : qsTr("Clipboard history is empty")
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
            StyledText {
                text: qsTr("%1 entries · Enter to copy · Ctrl+Delete to remove · Esc to close").arg(list.count)
                font.pointSize: Appearance.font.size.small
                color: Colours.palette.m3onSurfaceVariant
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
        }
    }
}
