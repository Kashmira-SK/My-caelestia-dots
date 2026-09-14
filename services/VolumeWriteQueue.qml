import QtQuick

// Keep wpctl for speaker compatibility, but never overlap volume commands.
QtObject {
    id: root
    property int deviceId: -1
    property real latestValue: 0
    property int latestDeviceId: -1
    property bool queued: false
    property bool busy: false
    readonly property bool pending: queued || busy
    signal writeRequested(real value, int device)

    onDeviceIdChanged: queued = false

    function enqueue(value: real): void {
        if (deviceId < 0 || !Number.isFinite(value))
            return;
        latestValue = value;
        latestDeviceId = deviceId;
        queued = true;
        flush();
    }

    function flush(): void {
        if (!queued || busy || cadence.running || deviceId < 0)
            return;
        busy = true;
        queued = false;
        cadence.start();
        writeRequested(latestValue, deviceId);
    }

    function complete(): void {
        busy = false;
        flush();
    }

    property Timer cadence: Timer {
        interval: 50
        onTriggered: root.flush()
    }
}
