import QtQuick
import QtQuick.Templates as T

// Pointer input owns the handle until the final backend write is acknowledged.
QtObject {
    id: root
    required property T.Slider slider
    required property real backendValue
    property bool backendPending: false
    property int deviceId: -1
    property bool waiting: false
    property bool cancelled: false
    signal requested(real value)

    function reconcile(): void {
        if (!slider || slider.pressed)
            return;
        if (waiting && !backendPending && Math.abs(backendValue - slider.value) <= 0.011) {
            waiting = false;
            fallback.stop();
        }
        if (!waiting)
            slider.value = backendValue;
    }

    onBackendValueChanged: reconcile()
    onBackendPendingChanged: reconcile()
    onDeviceIdChanged: {
        waiting = false;
        fallback.stop();
        cancelled = slider?.pressed ?? false;
        if (slider)
            slider.value = backendValue;
    }
    Component.onCompleted: reconcile()

    property Connections input: Connections {
        target: root.slider
        function onMoved(): void {
            if (root.cancelled || root.deviceId < 0) {
                root.slider.value = root.backendValue;
                return;
            }
            root.waiting = true;
            fallback.restart();
            root.requested(root.slider.value);
        }
        function onPressedChanged(): void {
            if (!root.slider.pressed) {
                root.cancelled = false;
                root.reconcile();
            }
        }
    }

    // Recover from rejected writes without holding a stale level indefinitely.
    property Timer fallback: Timer {
        interval: 1000
        onTriggered: {
            if (root.slider.pressed || root.backendPending) {
                restart();
                return;
            }
            root.waiting = false;
            root.reconcile();
        }
    }
}
