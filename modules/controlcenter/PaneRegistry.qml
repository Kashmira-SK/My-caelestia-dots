pragma Singleton

import QtQuick

QtObject {
    id: root

    // Stable IDs keep existing IPC routes and saved page selections compatible.
    readonly property list<QtObject> panes: [
        QtObject {
            readonly property string id: "appearance"
            readonly property string keywords: qsTr("Colors light dark theme style palette profile fonts text size transparency opacity motion animations spacing padding corners borders")
            readonly property string label: qsTr("Theme & style")
            readonly property string icon: "palette"
            readonly property string component: "appearance/AppearancePane.qml"
            readonly property string group: qsTr("Personalise")
        },
        QtObject {
            readonly property string id: "desktop"
            readonly property string keywords: qsTr("Wallpaper background clock position size shadows visualiser audio bars transition")
            readonly property string label: qsTr("Desktop")
            readonly property string icon: "wallpaper"
            readonly property string component: "desktop/DesktopPane.qml"
            readonly property string group: qsTr("Personalise")
        },
        QtObject {
            readonly property string id: "taskbar"
            readonly property string keywords: qsTr("Bar workspaces status icons system tray mouse gestures scroll battery network Bluetooth volume clock")
            readonly property string label: qsTr("Bar & workspaces")
            readonly property string icon: "view_sidebar"
            readonly property string component: "taskbar/TaskbarPane.qml"
            readonly property string group: qsTr("Personalise")
        },
        QtObject {
            readonly property string id: "dashboard"
            readonly property string keywords: qsTr("Dashboard opening performance CPU GPU memory storage network battery refresh media drag")
            readonly property string label: qsTr("Dashboard")
            readonly property string icon: "dashboard"
            readonly property string component: "dashboard/DashboardPane.qml"
            readonly property string group: qsTr("Personalise")
        },
        QtObject {
            readonly property string id: "launcher"
            readonly property string keywords: qsTr("Launcher applications favorites hidden apps search fuzzy matching command prefixes navigation")
            readonly property string label: qsTr("Launcher")
            readonly property string icon: "apps"
            readonly property string component: "launcher/LauncherPane.qml"
            readonly property string group: qsTr("Personalise")
        },
        QtObject {
            readonly property string id: "network"
            readonly property string keywords: qsTr("Network Wi-Fi wifi wireless Ethernet wired internet connection password IP DNS frequency")
            readonly property string label: qsTr("Network")
            readonly property string icon: "router"
            readonly property string component: "network/NetworkingPane.qml"
            readonly property string group: qsTr("Connections")
        },
        QtObject {
            readonly property string id: "bluetooth"
            readonly property string keywords: qsTr("Bluetooth devices pairing adapters visibility discoverable timeout battery")
            readonly property string label: qsTr("Bluetooth")
            readonly property string icon: "settings_bluetooth"
            readonly property string component: "bluetooth/BtPane.qml"
            readonly property string group: qsTr("Connections")
        },
        QtObject {
            readonly property string id: "audio"
            readonly property string keywords: qsTr("Sound audio speakers headphones microphone input output volume mute applications")
            readonly property string label: qsTr("Sound")
            readonly property string icon: "volume_up"
            readonly property string component: "audio/AudioPane.qml"
            readonly property string group: qsTr("Connections")
        },
        QtObject {
            readonly property string id: "cheatsheet"
            readonly property string keywords: qsTr("Reference help commands shortcuts tools networking maintenance shell files folders copy")
            readonly property string label: qsTr("Reference & help")
            readonly property string icon: "menu_book"
            readonly property string component: "../cheatsheet/Content.qml"
            readonly property string group: ""
        }
    ]
    readonly property var barSections: [
        { id: "general", label: qsTr("General"), keywords: qsTr("visibility always show hover system tray background compact recolour") },
        { id: "workspaces", label: qsTr("Workspaces"), keywords: qsTr("visible count monitor active occupied highlight application icons") },
        { id: "indicators", label: qsTr("Indicators"), keywords: qsTr("status speakers microphone keyboard network wifi Wi-Fi Bluetooth battery caps lock clock") },
        { id: "interaction", label: qsTr("Interaction"), keywords: qsTr("mouse gestures scroll volume brightness detail popups drag distance") }
    ]

    readonly property var pageSections: ({
        appearance: [{id:"colors", label:qsTr("Colors"), keywords:"theme light dark palette profile"}, {id:"text", label:qsTr("Text"), keywords:"font size monospace icon"}, {id:"surfaces", label:qsTr("Surfaces & motion"), keywords:"transparency opacity animation"}, {id:"layout", label:qsTr("Spacing & borders"), keywords:"padding spacing corners rounding border"}],
        desktop: [{id:"wallpaper", label:qsTr("Wallpaper"), keywords:"background image video transition"}, {id:"clock", label:qsTr("Clock"), keywords:"position size shadow background"}, {id:"visualiser", label:qsTr("Visualiser"), keywords:"audio bars spacing"}],
        dashboard: [{id:"general", label:qsTr("General"), keywords:"opening hover gesture drag"}, {id:"performance", label:qsTr("Performance"), keywords:"CPU GPU memory storage network battery"}, {id:"timing", label:qsTr("Refresh timing"), keywords:"resource media interval"}],
        launcher: [{id:"general", label:qsTr("General"), keywords:"enabled keyboard vim command actions"}, {id:"search", label:qsTr("Search"), keywords:"fuzzy matching prefixes"}, {id:"applications", label:qsTr("Applications"), keywords:"favorites hidden apps"}, {id:"layout", label:qsTr("Layout"), keywords:"results size wallpaper"}],
        network: [{id:"connections", label:qsTr("Connections"), keywords:"Wi-Fi Ethernet devices connect"}, {id:"settings", label:qsTr("Settings"), keywords:"wifi enabled status frequency"}],
        bluetooth: [{id:"devices", label:qsTr("Devices"), keywords:"connected paired battery"}, {id:"settings", label:qsTr("Pairing & adapters"), keywords:"visibility discoverable timeout power"}],
        audio: [{id:"output", label:qsTr("Output"), keywords:"output sound volume mute sink"}, {id:"input", label:qsTr("Input"), keywords:"input volume mute source"}, {id:"applications", label:qsTr("Applications"), keywords:"streams volume"}],
        cheatsheet: [{id:"tools", label:qsTr("Everyday tools"), keywords:"commands terminal"}, {id:"network", label:qsTr("Networking"), keywords:"network commands"}, {id:"system", label:qsTr("Maintenance"), keywords:"system commands"}, {id:"shell", label:qsTr("Shell & shortcuts"), keywords:"keyboard commands"}, {id:"paths", label:qsTr("Files & folders"), keywords:"paths directories"}, {id:"fun", label:qsTr("Extras"), keywords:"fun"}]
    })

    function sectionsFor(page: string): var {
        return page === "taskbar" ? barSections : pageSections[page] ?? [];
    }

    function sectionLabel(page: string, section: string): string {
        return sectionsFor(page).find(item => item.id === section)?.label ?? "";
    }

    function barSectionLabel(id: string): string {
        return barSections.find(section => section.id === id)?.label ?? "";
    }

    function search(query: string): var {
        if (!query.trim()) return [];
        const results = [];
        for (const pane of panes) {
            if (matches(pane, query))
                results.push({ page: pane.id, section: "", label: pane.label, detail: pane.group });
        }
        for (const pane of panes) {
            for (const section of sectionsFor(pane.id)) {
                if (matches({ label: pane.label + " " + section.label, keywords: section.keywords }, query))
                    results.push({ page: pane.id, section: section.id, label: section.label, detail: pane.label });
            }
        }
        return results;
    }

    readonly property int count: panes.length
    readonly property var ids: {
        const result = [];
        for (let i = 0; i < panes.length; i++) {
            result.push(panes[i].id);
        }
        return result;
    }

    // Match every word, so searches such as "clock size" stay useful.
    function matches(pane: var, query: string): bool {
        const words = query.toLocaleLowerCase().trim().split(/\s+/).filter(Boolean);
        const text = (pane.label + " " + pane.keywords).toLocaleLowerCase();
        return words.every(word => text.includes(word));
    }

    function getByIndex(index: int) : QtObject {
        if (index >= 0 && index < panes.length)
            return panes[index];

        return null;
    }

    function getIndexByLabel(label: string) : int {
        for (let i = 0; i < panes.length; i++) {
            if (panes[i].id === label || panes[i].label === label)
                return i;

        }
        return -1;
    }

    function getByLabel(label: string) : QtObject {
        const index = getIndexByLabel(label);
        return getByIndex(index);
    }

    function getById(id: string) : QtObject {
        for (let i = 0; i < panes.length; i++) {
            if (panes[i].id === id)
                return panes[i];

        }
        return null;
    }

}
