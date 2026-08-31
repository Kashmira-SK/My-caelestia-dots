pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.components
import qs.components.misc
import qs.config
import qs.services

Item {
    id: root

    property int currentDiskIndex: 0
    property int diskCount: SystemUsage.disks.length

    readonly property var currentDisk:
        SystemUsage.disks.length > 0
        ? SystemUsage.disks[
            Math.min(
                currentDiskIndex,
                SystemUsage.disks.length - 1
            )
        ]
        : null

    readonly property bool showBattery:
        UPower.displayDevice.isLaptopBattery
        && Config.dashboard.performance.showBattery

    readonly property bool showResources:
        Config.dashboard.performance.showMemory
        || Config.dashboard.performance.showStorage
        || showBattery

    function displayTemp(temp: real): string {
        return `${Math.ceil(temp)}°C`;
    }

    function memoryText(): string {
        const usedFmt =
            SystemUsage.formatKib(
                SystemUsage.memUsed
            );

        const totalFmt =
            SystemUsage.formatKib(
                SystemUsage.memTotal
            );

        return `${usedFmt.value.toFixed(1)} / ${Math.floor(totalFmt.value)} ${totalFmt.unit}`;
    }

    function storageText(): string {
        if (!currentDisk)
            return "—";

        const usedFmt =
            SystemUsage.formatKib(
                currentDisk.used
            );

        const totalFmt =
            SystemUsage.formatKib(
                currentDisk.total
            );

        return `${usedFmt.value.toFixed(1)} / ${Math.floor(totalFmt.value)} ${totalFmt.unit}`;
    }

    function batteryStatus(): string {
        if (
            UPower.displayDevice.state
            === UPowerDeviceState.FullyCharged
        )
            return qsTr("Full");

        if (
            UPower.displayDevice.state
            === UPowerDeviceState.Charging
        )
            return qsTr("Charging");

        const s =
            UPower.displayDevice.timeToEmpty;

        if (s === 0)
            return qsTr("...");

        const hr =
            Math.floor(s / 3600);

        const min =
            Math.floor((s % 3600) / 60);

        return hr > 0
            ? `${hr}h ${min}m`
            : `${min}m`;
    }

    implicitWidth: 840

    implicitHeight:
        placeholder.visible
        ? placeholder.implicitHeight
        : content.implicitHeight

    Ref {
        service: SystemUsage
    }

    Ref {
        service: NetworkUsage
    }

    Connections {
        target: SystemUsage

        function onDisksChanged() {
            root.diskCount =
                SystemUsage.disks.length;

            if (
                root.currentDiskIndex
                >= root.diskCount
            )
                root.currentDiskIndex =
                    Math.max(
                        0,
                        root.diskCount - 1
                    );
        }
    }

    Item {
        id: placeholder

        anchors.horizontalCenter:
            parent.horizontalCenter

        implicitWidth: 440
        implicitHeight: 170

        visible:
            !Config.dashboard.performance.showCpu
            && !(
                Config.dashboard.performance.showGpu
                && SystemUsage.gpuType !== "NONE"
            )
            && !Config.dashboard.performance.showMemory
            && !Config.dashboard.performance.showStorage
            && !Config.dashboard.performance.showNetwork
            && !root.showBattery

        ColumnLayout {
            anchors.centerIn: parent

            spacing:
                Appearance.spacing.small

            StyledText {
                Layout.alignment:
                    Qt.AlignHCenter

                text:
                    qsTr("No performance modules enabled")

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.normal

                font.weight: 500
            }

            StyledText {
                Layout.alignment:
                    Qt.AlignHCenter

                text:
                    qsTr(
                        "Enable them in dashboard settings."
                    )

                color:
                    Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.46
                    )

                font.pointSize:
                    Appearance.font.size.small
            }
        }
    }

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right

        spacing:
            Appearance.spacing.normal

        visible:
            !placeholder.visible

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8

            spacing:
                Appearance.spacing.normal

            PerfFrame {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                visible:
                    Config.dashboard.performance.showCpu

                label: qsTr("CPU")
                icon: "memory"

                ProcessorBody {
                    name:
                        SystemUsage.cpuName
                        || qsTr("Processor")

                    percentage:
                        SystemUsage.cpuPerc

                    temperature:
                        SystemUsage.cpuTemp

                    accent:
                        Colours.palette.m3primary
                }
            }

            PerfFrame {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                visible:
                    Config.dashboard.performance.showGpu
                    && SystemUsage.gpuType !== "NONE"

                label: qsTr("GPU")
                icon: "desktop_windows"

                ProcessorBody {
                    name:
                        SystemUsage.gpuName
                        || qsTr("Graphics")

                    percentage:
                        SystemUsage.gpuPerc

                    temperature:
                        SystemUsage.gpuTemp

                    accent:
                        Colours.palette.m3secondary
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8

            spacing:
                Appearance.spacing.normal

            PerfFrame {
                Layout.fillWidth: true
                Layout.preferredHeight: 188
                Layout.alignment: Qt.AlignTop

                visible:
                    root.showResources

                label: qsTr("Resources")
                icon: "monitoring"

                RowLayout {
                    Layout.fillWidth: true

                    spacing:
                        Appearance.spacing.normal

                    ResourceStat {
                        Layout.fillWidth: true

                        visible:
                            Config.dashboard.performance.showMemory

                        icon: "memory_alt"
                        title: qsTr("Memory")

                        value:
                            `${Math.round(
                                SystemUsage.memPerc * 100
                            )}%`

                        detail:
                            root.memoryText()

                        progress:
                            SystemUsage.memPerc

                        accent:
                            Colours.palette.m3tertiary
                    }

                    ResourceDivider {
                        visible:
                            Config.dashboard.performance.showMemory
                            && (
                                Config.dashboard.performance.showStorage
                                || root.showBattery
                            )
                    }

                    ResourceStat {
                        Layout.fillWidth: true

                        visible:
                            Config.dashboard.performance.showStorage

                        icon: "hard_disk"

                        title:
                            root.currentDisk
                            ? root.currentDisk.mount
                            : qsTr("Storage")

                        value:
                            root.currentDisk
                            ? `${Math.round(
                                root.currentDisk.perc * 100
                            )}%`
                            : "—"

                        detail:
                            root.storageText()

                        progress:
                            root.currentDisk
                            ? root.currentDisk.perc
                            : 0

                        accent:
                            Colours.palette.m3secondary

                        MouseArea {
                            anchors.fill: parent

                            acceptedButtons:
                                Qt.NoButton

                            onWheel: wheel => {
                                if (
                                    root.diskCount <= 1
                                )
                                    return;

                                if (
                                    wheel.angleDelta.y > 0
                                )
                                    root.currentDiskIndex =
                                        (
                                            root.currentDiskIndex
                                            - 1
                                            + root.diskCount
                                        )
                                        % root.diskCount;

                                else if (
                                    wheel.angleDelta.y < 0
                                )
                                    root.currentDiskIndex =
                                        (
                                            root.currentDiskIndex
                                            + 1
                                        )
                                        % root.diskCount;
                            }
                        }
                    }

                    ResourceDivider {
                        visible:
                            root.showBattery
                            && (
                                Config.dashboard.performance.showMemory
                                || Config.dashboard.performance.showStorage
                            )
                    }

                    ResourceStat {
                        Layout.fillWidth: true

                        visible:
                            root.showBattery

                        icon: {
                            if (
                                UPower.displayDevice.state
                                === UPowerDeviceState.FullyCharged
                            )
                                return "battery_full";

                            if (
                                UPower.displayDevice.state
                                === UPowerDeviceState.Charging
                            )
                                return "battery_charging_full";

                            return "battery_5_bar";
                        }

                        title:
                            qsTr("Battery")

                        value:
                            `${Math.round(
                                UPower.displayDevice.percentage
                                * 100
                            )}%`

                        detail:
                            root.batteryStatus()

                        progress:
                            UPower.displayDevice.percentage

                        accent:
                            Colours.palette.m3primary
                    }
                }
            }

            PerfFrame {
                Layout.fillWidth: true
                Layout.preferredHeight: 188
                Layout.alignment: Qt.AlignTop

                visible:
                    Config.dashboard.performance.showNetwork

                label: qsTr("Network")
                icon: "swap_vert"

                ColumnLayout {
                    Layout.fillWidth: true

                    spacing:
                        Appearance.spacing.small

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 88

                        Canvas {
                            id: sparklineCanvas

                            property var downHistory:
                                NetworkUsage.downloadHistory

                            property var upHistory:
                                NetworkUsage.uploadHistory

                            property real targetMax: 1024
                            property real smoothMax:
                                targetMax

                            property real slideProgress: 0
                            property int _tickCount: 0
                            property int _lastTickCount: -1

                            function checkAndAnimate(): void {
                                const currentLength =
                                    (
                                        downHistory
                                        || []
                                    ).length;

                                if (
                                    currentLength > 0
                                    && _tickCount
                                    !== _lastTickCount
                                ) {
                                    _lastTickCount =
                                        _tickCount;

                                    updateMax();
                                }
                            }

                            function updateMax(): void {
                                const downHist =
                                    downHistory
                                    || [];

                                const upHist =
                                    upHistory
                                    || [];

                                const allValues =
                                    downHist.concat(
                                        upHist
                                    );

                                targetMax =
                                    Math.max(
                                        ...allValues,
                                        1024
                                    );

                                requestPaint();
                            }

                            anchors.fill: parent

                            onDownHistoryChanged:
                                checkAndAnimate()

                            onUpHistoryChanged:
                                checkAndAnimate()

                            onSmoothMaxChanged:
                                requestPaint()

                            onSlideProgressChanged:
                                requestPaint()

                            onPaint: {
                                const ctx =
                                    getContext("2d");

                                ctx.reset();

                                const w = width;
                                const h = height;

                                const downHist =
                                    downHistory || [];

                                const upHist =
                                    upHistory || [];

                                if (
                                    downHist.length < 2
                                    && upHist.length < 2
                                )
                                    return;

                                const maxVal =
                                    smoothMax;

                                const drawLine =
                                    (
                                        history,
                                        color,
                                        alpha
                                    ) => {
                                        if (
                                            history.length < 2
                                        )
                                            return;

                                        const len =
                                            history.length;

                                        const stepX =
                                            w
                                            / (
                                                NetworkUsage.historyLength
                                                - 1
                                            );

                                        const startX =
                                            w
                                            - (
                                                len - 1
                                            )
                                            * stepX
                                            - stepX
                                            * slideProgress
                                            + stepX;

                                        ctx.beginPath();

                                        ctx.moveTo(
                                            startX,
                                            h
                                            - (
                                                history[0]
                                                / maxVal
                                            )
                                            * h
                                        );

                                        for (
                                            let i = 1;
                                            i < len;
                                            i++
                                        ) {
                                            const x =
                                                startX
                                                + i
                                                * stepX;

                                            const y =
                                                h
                                                - (
                                                    history[i]
                                                    / maxVal
                                                )
                                                * h;

                                            ctx.lineTo(
                                                x,
                                                y
                                            );
                                        }

                                        ctx.strokeStyle =
                                            color;

                                        ctx.lineWidth = 1.5;
                                        ctx.lineCap =
                                            "round";

                                        ctx.lineJoin =
                                            "round";

                                        ctx.stroke();

                                        ctx.lineTo(
                                            startX
                                            + (
                                                len - 1
                                            )
                                            * stepX,
                                            h
                                        );

                                        ctx.lineTo(
                                            startX,
                                            h
                                        );

                                        ctx.closePath();

                                        const c =
                                            Qt.color(
                                                color
                                            );

                                        ctx.fillStyle =
                                            Qt.rgba(
                                                c.r,
                                                c.g,
                                                c.b,
                                                alpha
                                            );

                                        ctx.fill();
                                    };

                                drawLine(
                                    upHist,
                                    Colours.palette.m3secondary.toString(),
                                    0.06
                                );

                                drawLine(
                                    downHist,
                                    Colours.palette.m3tertiary.toString(),
                                    0.08
                                );
                            }

                            Component.onCompleted:
                                updateMax()

                            Connections {
                                target: Colours

                                function onPaletteChanged() {
                                    sparklineCanvas.requestPaint();
                                }
                            }

                            Timer {
                                interval:
                                    Config.dashboard.resourceUpdateInterval

                                running: true
                                repeat: true

                                onTriggered:
                                    sparklineCanvas._tickCount++
                            }

                            NumberAnimation on slideProgress {
                                from: 0
                                to: 1

                                duration:
                                    Config.dashboard.resourceUpdateInterval

                                loops:
                                    Animation.Infinite

                                running: true
                            }

                            Behavior on smoothMax {
                                Anim {
                                    duration:
                                        Appearance.anim.durations.large
                                }
                            }
                        }

                        StyledText {
                            anchors.centerIn: parent

                            visible:
                                NetworkUsage.downloadHistory.length
                                < 2

                            text:
                                qsTr("Collecting data...")

                            color:
                                Qt.alpha(
                                    Colours.palette.m3onSurfaceVariant,
                                    0.38
                                )

                            font.pointSize:
                                Appearance.font.size.smaller
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        implicitHeight: 1

                        color:
                            Qt.alpha(
                                Colours.palette.m3outlineVariant,
                                0.22
                            )
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        spacing:
                            Appearance.spacing.normal

                        NetworkStat {
                            Layout.fillWidth: true

                            arrow: "↓"
                            label: qsTr("Down")

                            value: {
                                const fmt =
                                    NetworkUsage.formatBytes(
                                        NetworkUsage.downloadSpeed
                                        ?? 0
                                    );

                                return fmt
                                    ? `${fmt.value.toFixed(1)} ${fmt.unit}`
                                    : "0.0 B/s";
                            }

                            accent:
                                Colours.palette.m3tertiary
                        }

                        NetworkStat {
                            Layout.fillWidth: true

                            arrow: "↑"
                            label: qsTr("Up")

                            value: {
                                const fmt =
                                    NetworkUsage.formatBytes(
                                        NetworkUsage.uploadSpeed
                                        ?? 0
                                    );

                                return fmt
                                    ? `${fmt.value.toFixed(1)} ${fmt.unit}`
                                    : "0.0 B/s";
                            }

                            accent:
                                Colours.palette.m3secondary
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text:
                                qsTr("Session")

                            color:
                                Qt.alpha(
                                    Colours.palette.m3onSurfaceVariant,
                                    0.38
                                )

                            font.pointSize:
                                Appearance.font.size.smaller
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: {
                                const down =
                                    NetworkUsage.formatBytesTotal(
                                        NetworkUsage.downloadTotal
                                        ?? 0
                                    );

                                const up =
                                    NetworkUsage.formatBytesTotal(
                                        NetworkUsage.uploadTotal
                                        ?? 0
                                    );

                                return (
                                    down && up
                                )
                                    ? `↓ ${down.value.toFixed(1)} ${down.unit}   ↑ ${up.value.toFixed(1)} ${up.unit}`
                                    : "↓ 0.0 B   ↑ 0.0 B";
                            }

                            color:
                                Qt.alpha(
                                    Colours.palette.m3onSurfaceVariant,
                                    0.54
                                )

                            font.family:
                                Appearance.font.family.mono

                            font.pointSize:
                                Appearance.font.size.smaller
                        }
                    }
                }
            }
        }
    }

    component PerfFrame: Item {
        id: frame

        required property string label
        required property string icon

        default property alias content:
            frameContent.data

        Layout.fillWidth: true

        implicitHeight:
            frameContent.implicitHeight
            + 42

        MaterialIcon {
            id: frameIcon

            x: 15
            y: -height / 2 + 1

            text:
                frame.icon

            color:
                Qt.alpha(
                    Colours.palette.m3primary,
                    0.74
                )

            font.pointSize:
                Appearance.font.size.small
        }

        StyledText {
            id: frameLabel

            x:
                frameIcon.x
                + frameIcon.width
                + 7

            y:
                -height / 2

            text:
                frame.label

            color:
                Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.68
                )

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 500
            font.letterSpacing: 0.7

            onPaintedWidthChanged:
                frameBorder.requestPaint()
        }

        Canvas {
            id: frameBorder

            anchors.fill: parent

            onWidthChanged:
                requestPaint()

            onHeightChanged:
                requestPaint()

            onPaint: {
                const ctx =
                    getContext("2d");

                ctx.reset();

                const w = width;
                const h = height;

                const r =
                    Math.min(
                        Appearance.rounding.normal,
                        14
                    );

                const gapLeft =
                    Math.max(
                        r + 7,
                        frameIcon.x - 6
                    );

                const gapRight =
                    Math.min(
                        w - r - 7,
                        frameLabel.x
                        + frameLabel.paintedWidth
                        + 7
                    );

                ctx.strokeStyle =
                    Qt.alpha(
                        Colours.palette.m3outlineVariant,
                        0.44
                    );

                ctx.lineWidth = 1;
                ctx.beginPath();

                ctx.moveTo(
                    gapRight,
                    0.5
                );

                ctx.lineTo(
                    w - r,
                    0.5
                );

                ctx.quadraticCurveTo(
                    w - 0.5,
                    0.5,
                    w - 0.5,
                    r
                );

                ctx.lineTo(
                    w - 0.5,
                    h - r
                );

                ctx.quadraticCurveTo(
                    w - 0.5,
                    h - 0.5,
                    w - r,
                    h - 0.5
                );

                ctx.lineTo(
                    r,
                    h - 0.5
                );

                ctx.quadraticCurveTo(
                    0.5,
                    h - 0.5,
                    0.5,
                    h - r
                );

                ctx.lineTo(
                    0.5,
                    r
                );

                ctx.quadraticCurveTo(
                    0.5,
                    0.5,
                    r,
                    0.5
                );

                ctx.lineTo(
                    gapLeft,
                    0.5
                );

                ctx.stroke();
            }
        }

        ColumnLayout {
            id: frameContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            anchors.leftMargin:
                Appearance.padding.normal

            anchors.rightMargin:
                Appearance.padding.normal

            anchors.topMargin: 20
            anchors.bottomMargin:
                Appearance.padding.normal

            spacing:
                Appearance.spacing.small
        }
    }

    component ProcessorBody: ColumnLayout {
        id: processor

        required property string name
        required property real percentage
        required property real temperature
        required property color accent

        Layout.fillWidth: true

        spacing:
            Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                Layout.fillWidth: true

                text:
                    processor.name

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.normal

                font.weight: 500

                elide:
                    Text.ElideRight
            }

            StyledText {
                text:
                    `${Math.round(
                        processor.percentage * 100
                    )}%`

                color:
                    processor.accent

                font.family:
                    Appearance.font.family.mono

                font.pointSize:
                    Appearance.font.size.extraLarge

                font.weight: 500
            }
        }

        MeterLine {
            label: qsTr("usage")
            value: processor.percentage
            valueText:
                `${Math.round(
                    processor.percentage * 100
                )}%`

            accent:
                processor.accent
        }

        MeterLine {
            label: qsTr("temp")
            value:
                Math.min(
                    1,
                    Math.max(
                        0,
                        processor.temperature
                        / 100
                    )
                )

            valueText:
                root.displayTemp(
                    processor.temperature
                )

            accent:
                Qt.alpha(
                    processor.accent,
                    0.78
                )
        }
    }

    component MeterLine: ColumnLayout {
        id: meter

        required property string label
        required property real value
        required property string valueText
        required property color accent

        Layout.fillWidth: true

        spacing: 3

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text:
                    meter.label

                color:
                    Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.42
                    )

                font.pointSize:
                    Appearance.font.size.smaller
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text:
                    meter.valueText

                color:
                    Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.62
                    )

                font.family:
                    Appearance.font.family.mono

                font.pointSize:
                    Appearance.font.size.smaller
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 5

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter:
                    parent.verticalCenter

                height: 1

                color:
                    Qt.alpha(
                        Colours.palette.m3outlineVariant,
                        0.32
                    )
            }

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter:
                    parent.verticalCenter

                width:
                    parent.width
                    * Math.max(
                        0,
                        Math.min(
                            1,
                            meter.value
                        )
                    )

                height: 3
                radius: 1.5

                color:
                    meter.accent

                Behavior on width {
                    Anim {
                        duration:
                            Appearance.anim.durations.large
                    }
                }
            }
        }
    }

    component ResourceDivider: Rectangle {
        Layout.fillHeight: true

        implicitWidth: 1

        color:
            Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.24
            )
    }

    component ResourceStat: Item {
        id: stat

        required property string icon
        required property string title
        required property string value
        required property string detail
        required property real progress
        required property color accent

        implicitHeight: 120

        ColumnLayout {
            anchors.fill: parent

            spacing:
                Appearance.spacing.small

            RowLayout {
                Layout.fillWidth: true

                spacing:
                    Appearance.spacing.small

                MaterialIcon {
                    text:
                        stat.icon

                    color:
                        Qt.alpha(
                            stat.accent,
                            0.78
                        )

                    font.pointSize:
                        Appearance.font.size.small
                }

                StyledText {
                    Layout.fillWidth: true

                    text:
                        stat.title

                    color:
                        Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.62
                        )

                    font.pointSize:
                        Appearance.font.size.small

                    elide:
                        Text.ElideRight
                }
            }

            StyledText {
                text:
                    stat.value

                color:
                    stat.accent

                font.family:
                    Appearance.font.family.mono

                font.pointSize:
                    Appearance.font.size.extraLarge

                font.weight: 500
            }

            StyledText {
                Layout.fillWidth: true

                text:
                    stat.detail

                color:
                    Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.46
                    )

                font.pointSize:
                    Appearance.font.size.smaller

                elide:
                    Text.ElideRight
            }

            Item {
                Layout.fillHeight: true
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 5

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter:
                        parent.verticalCenter

                    height: 1

                    color:
                        Qt.alpha(
                            Colours.palette.m3outlineVariant,
                            0.30
                        )
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter:
                        parent.verticalCenter

                    width:
                        parent.width
                        * Math.max(
                            0,
                            Math.min(
                                1,
                                stat.progress
                            )
                        )

                    height: 3
                    radius: 1.5

                    color:
                        stat.accent

                    Behavior on width {
                        Anim {
                            duration:
                                Appearance.anim.durations.large
                        }
                    }
                }
            }
        }
    }

    component NetworkStat: ColumnLayout {
        id: stat

        required property string arrow
        required property string label
        required property string value
        required property color accent

        spacing: 1

        RowLayout {
            spacing: 5

            StyledText {
                text:
                    stat.arrow

                color:
                    stat.accent

                font.family:
                    Appearance.font.family.mono

                font.pointSize:
                    Appearance.font.size.small
            }

            StyledText {
                text:
                    stat.label

                color:
                    Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.42
                    )

                font.pointSize:
                    Appearance.font.size.smaller
            }
        }

        StyledText {
            text:
                stat.value

            color:
                Colours.palette.m3onSurface

            font.family:
                Appearance.font.family.mono

            font.pointSize:
                Appearance.font.size.normal

            font.weight: 500
        }
    }
}
