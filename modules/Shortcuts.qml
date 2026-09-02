import qs.components.misc
import qs.modules.controlcenter
import qs.services
import qs.config
import Caelestia
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool launcherInterrupted
    readonly property bool hasFullscreen: Hypr.focusedWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2) ?? false

    CustomShortcut {
        name: "controlCenter"
        description: "Open control center"
        onPressed: WindowFactory.create()
    }

    CustomShortcut {
        name: "showall"
        description: "Toggle launcher, dashboard and osd"
        onPressed: {
            if (root.hasFullscreen)
                return;
            const v = Visibilities.getForActive();
            v.launcher = v.dashboard = v.osd = v.utilities = !(v.launcher || v.dashboard || v.osd || v.utilities);
        }
    }

    CustomShortcut {
        name: "dashboard"
        description: "Toggle dashboard"
        onPressed: {
            if (root.hasFullscreen)
                return;
            const visibilities = Visibilities.getForActive();
            visibilities.dashboard = !visibilities.dashboard;
        }
    }

    CustomShortcut {
        name: "session"
        description: "Toggle session menu"
        onPressed: {
            if (root.hasFullscreen)
                return;
            const visibilities = Visibilities.getForActive();
            visibilities.session = !visibilities.session;
        }
    }

    CustomShortcut {
        name: "launcher"
        description: "Toggle launcher"
        onPressed: root.launcherInterrupted = false
        onReleased: {
            if (!root.launcherInterrupted && !root.hasFullscreen) {
                const visibilities = Visibilities.getForActive();
                visibilities.launcher = !visibilities.launcher;
            }
            root.launcherInterrupted = false;
        }
    }

    CustomShortcut {
        name: "launcherInterrupt"
        description: "Interrupt launcher keybind"
        onPressed: root.launcherInterrupted = true
    }


    CustomShortcut {
        name: "sidebar"
        description: "Toggle sidebar"
        onPressed: {
            if (root.hasFullscreen)
                return;
            const visibilities = Visibilities.getForActive();
            visibilities.sidebar = !visibilities.sidebar;
        }
    }

    CustomShortcut {
        name: "utilities"
        description: "Toggle utilities"
        onPressed: {
            if (root.hasFullscreen)
                return;
            const visibilities = Visibilities.getForActive();
            visibilities.utilities = !visibilities.utilities;
        }
    }
    
    IpcHandler {
        target: "wallpaperTransition"

        function transitionNames(): var {
            return [
                "radial",
                "ripple",
                "diagonal",
                "corner",
                "cross",
                "random"
            ];
        }

        function get(): string {
            return Config.background.wallpaperTransition;
        }

        function set(name: string): void {
            if (!transitionNames().includes(name)) {
                console.warn(`[IPC] Unknown wallpaper transition "${name}"`);
                return;
            }

            Config.background.wallpaperTransition = name;
            Config.save();

            Toaster.toast(
                qsTr("Wallpaper transition"),
                name.charAt(0).toUpperCase() + name.slice(1),
                "animation",
                Toast.Info
            );
        }

        function next(): void {
            const current =
                transitionNames().indexOf(Config.background.wallpaperTransition);

            const nextIndex =
                current < 0
                    ? 0
                    : (current + 1) % transitionNames().length;

            set(transitionNames()[nextIndex]);
        }

        function previous(): void {
            const current =
                transitionNames().indexOf(Config.background.wallpaperTransition);

            const previousIndex =
                current <= 0
                    ? transitionNames().length - 1
                    : current - 1;

            set(transitionNames()[previousIndex]);
        }
    }

    IpcHandler {
        target: "drawers"

        function toggle(drawer: string): void {
            if (list().split("\n").includes(drawer)) {
                if (root.hasFullscreen && ["launcher", "session", "dashboard", "wallpaperPicker"].includes(drawer))
                    return;
                const visibilities = Visibilities.getForActive();
                visibilities[drawer] = !visibilities[drawer];
            } else {
                console.warn(`[IPC] Drawer "${drawer}" does not exist`);
            }
        }

        function list(): string {
            const visibilities = Visibilities.getForActive();
            return Object.keys(visibilities).filter(k => typeof visibilities[k] === "boolean").join("\n");
        }
    }

    IpcHandler {
        target: "controlCenter"

        function open(pane: string): void {
            WindowFactory.create(null, {
                active: pane || "network"
            });
        }
    }

    IpcHandler {
        target: "toaster"

        function info(title: string, message: string, icon: string): void {
            Toaster.toast(title, message, icon, Toast.Info);
        }

        function success(title: string, message: string, icon: string): void {
            Toaster.toast(title, message, icon, Toast.Success);
        }

        function warn(title: string, message: string, icon: string): void {
            Toaster.toast(title, message, icon, Toast.Warning);
        }

        function error(title: string, message: string, icon: string): void {
            Toaster.toast(title, message, icon, Toast.Error);
        }
    }
}
