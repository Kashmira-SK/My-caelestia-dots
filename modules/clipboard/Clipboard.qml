import qs.components.misc
import qs.services
import Quickshell
import Quickshell.Io

Scope {
    id: root

    function toggle(): void {
        if (popup.active) {
            popup.item.dismiss();
        } else {
            popup.active = true;
        }
    }

    LazyLoader {
        id: popup
        Popup {
            onDismissed: popup.active = false
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { root.toggle(); }
    }

    CustomShortcut {
        name: "clipboard"
        description: "Toggle clipboard history"
        onPressed: root.toggle()
    }
}
