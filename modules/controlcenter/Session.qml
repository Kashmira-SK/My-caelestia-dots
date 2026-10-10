import QtQuick
import qs.config
import "./state"
import qs.modules.controlcenter

QtObject {
    id: session
    readonly property list<string> panes: PaneRegistry.ids

    required property var root
    property bool floating: false
    property string active: "network"
    property int activeIndex: 0
    property bool navExpanded: false
    property string barSection: "workspaces"

    property var sections: ({})
    function sectionFor(page: string): string {
        return page === "taskbar" ? barSection : sections[page] ?? PaneRegistry.sectionsFor(page)[0]?.id ?? "";
    }
    function setSection(page: string, section: string): void {
        if (page === "taskbar") barSection = section;
        else sections = Object.assign({}, sections, { [page]: section });
        // Settings views must not retain a selected device's detail panel.
        if (page === "network") { network.active = null; ethernet.active = null; }
        if (page === "bluetooth") bt.active = null;
    }

    readonly property BluetoothState bt: BluetoothState {}
    readonly property NetworkState network: NetworkState {}
    readonly property EthernetState ethernet: EthernetState {}
    readonly property LauncherState launcher: LauncherState {}
    readonly property VpnState vpn: VpnState {}

    // Store field edits only: external theme generation and wallpaper processes
    // cannot be safely reversed by restoring a configuration value.
    property var visualHistory: []
    readonly property var lastVisualEdit: visualHistory.length ? visualHistory[visualHistory.length - 1] : null
    readonly property bool canUndoVisual: !!lastVisualEdit && lastVisualEdit.target[lastVisualEdit.key] === lastVisualEdit.after

    function changeVisual(target: var, key: string, value: var): void {
        const before = target[key];
        if (before === value)
            return;
        const history = visualHistory.slice();
        const previous = history.length ? history[history.length - 1] : null;
        const now = Date.now();
        // A slider drag is one edit; pause or switch controls to start another.
        if (previous && previous.target === target && previous.key === key
            && previous.after === before && now - previous.time < 750) {
            previous.after = value;
            previous.time = now;
            if (previous.before === value)
                history.pop();
        } else {
            history.push({ target, key, before, after: value, time: now, page: active, section: sectionFor(active) });
        }
        target[key] = value;
        visualHistory = history.slice(-30);
        Config.save();
    }

    function undoVisual(): void {
        // Never overwrite a value another window or process changed meanwhile.
        if (!canUndoVisual)
            return;
        const edit = lastVisualEdit;
        edit.target[edit.key] = edit.before;
        visualHistory = visualHistory.slice(0, -1);
        active = edit.page;
        if (edit.section) setSection(edit.page, edit.section);
        Config.save();
    }

    Component.onCompleted: activeIndex = Math.max(0, panes.indexOf(active))

    onActiveChanged: activeIndex = Math.max(0, panes.indexOf(active))
    onActiveIndexChanged: if (panes[activeIndex])
        active = panes[activeIndex]
}
