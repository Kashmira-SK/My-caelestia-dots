pragma ComponentBehavior: Bound

import qs.components.misc
import qs.services
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    property alias lock: lock

    WlSessionLock {
        id: lock

        signal unlock

        onLockedChanged: Wallpapers.locked = lock.locked
        Component.onCompleted: Wallpapers.locked = lock.locked

        LockSurface {
            lock: lock
            pam: pam
        }
    }

    // Reconcile the actual state after unlock surface teardown as well as
    // handling the initial lock notification.
    Timer {
        interval: 250
        repeat: true
        running: Wallpapers.locked || lock.locked
        onTriggered: Wallpapers.locked = lock.locked
    }

    Pam {
        id: pam

        lock: lock
    }

    CustomShortcut {
        name: "lock"
        description: "Lock the current session"
        onPressed: lock.locked = true
    }

    CustomShortcut {
        name: "unlock"
        description: "Unlock the current session"
        onPressed: lock.unlock()
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            lock.locked = true;
        }

        function unlock(): void {
            lock.unlock();
        }

        function isLocked(): bool {
            return lock.locked;
        }
    }
}
