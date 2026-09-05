pragma ComponentBehavior: Bound

import qs.components
import qs.components.images
import qs.components.effects
import qs.components.filedialog
import qs.services
import qs.config
import qs.utils
import QtQuick

Item {
    id: root

    property string source: Wallpapers.current
    property Item current: one

    onSourceChanged: {
        if (!source)
            current = null;
        else if (current === one)
            two.update();
        else
            one.update();
    }

    Component.onCompleted: {
        if (source)
            Qt.callLater(() => one.update());
    }

    Loader {
        anchors.fill: parent

        active: !root.source

        sourceComponent: StyledRect {
            color: Colours.palette.m3surfaceContainer

            Row {
                anchors.centerIn: parent
                spacing: Appearance.spacing.large

                MaterialIcon {
                    text: "sentiment_stressed"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.extraLarge * 5
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: qsTr("Wallpaper missing?")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.extraLarge * 2
                        font.bold: true
                    }

                    StyledRect {
                        implicitWidth: selectWallText.implicitWidth + Appearance.padding.large * 2
                        implicitHeight: selectWallText.implicitHeight + Appearance.padding.small * 2

                        radius: Appearance.rounding.full
                        color: Colours.palette.m3primary

                        FileDialog {
                            id: dialog

                            title: qsTr("Select a wallpaper")
                            filterLabel: qsTr("Image files")
                            filters: Images.validImageExtensions
                            onAccepted: path => Wallpapers.setWallpaper(path)
                        }

                        StateLayer {
                            radius: parent.radius
                            color: Colours.palette.m3onPrimary

                            function onClicked(): void {
                                dialog.open();
                            }
                        }

                        StyledText {
                            id: selectWallText

                            anchors.centerIn: parent

                            text: qsTr("Set it now!")
                            color: Colours.palette.m3onPrimary
                            font.pointSize: Appearance.font.size.large
                        }
                    }
                }
            }
        }
    }

    Img {
        id: one
    }

    Img {
        id: two
    }

    component Img: Item {
        id: img

        property alias path: wallpaper.path
        property real transitionProgress: 0
        property string activeTransition: "radial"

        readonly property bool usesMask:
            [
                "radial",
                "split",
                "blinds",
                "curtain",
                "columns",
                "diagonal",
                "slices",
                "corner",
                "cross"
            ].indexOf(activeTransition) >= 0

        readonly property Item activeMask: {
            switch (activeTransition) {
            case "split":
                return splitMask;
            case "blinds":
                return blindsMask;
            case "curtain":
                return curtainMask;
            case "columns":
                return columnsMask;
            case "diagonal":
                return diagonalMask;
            case "slices":
                return slicesMask;
            case "corner":
                return cornerMask;
            case "cross":
                return crossMask;
            default:
                return radialMask;
            }
        }

        readonly property int transitionDuration: {
            switch (activeTransition) {
            case "ripple":
                return 1550;
            case "split":
                return 720;
            case "blinds":
                return 820;
            case "wipe":
                return 650;
            case "curtain":
                return 760;
            case "columns":
                return 850;
            case "diagonal":
                return 900;
            case "slices":
                return 950;
            case "corner":
                return 950;
            case "cross":
                return 800;
            default:
                return 900;
            }
        }

        function chooseTransition(): string {
            const configured =
                Config.background.wallpaperTransition ?? "radial";

            const effects = [
                "radial",
                "ripple",
                "diagonal",
                "corner",
                "cross"
            ];

            if (configured === "random")
                return effects[Math.floor(Math.random() * effects.length)];

            return effects.indexOf(configured) >= 0
                ? configured
                : "radial";
        }

        function stopAnimations(): void {
            radialAnim.stop();
            transitionAnim.stop();
        }

        function update(): void {
            if (path === root.source) {
                if (wallpaper.status === Image.Ready)
                    showLoaded();
                return;
            }

            stopAnimations();
            transitionProgress = 0;
            path = root.source;
        }

        function showLoaded(): void {
            stopAnimations();

            activeTransition = chooseTransition();
            transitionProgress = 0;

            root.current = img;

            if (activeTransition === "radial")
                radialAnim.start();
            else
                transitionAnim.start();
        }

        anchors.fill: parent
        z: root.current === img ? 1 : 0

        Component {
            id: maskLayerEffect

            OpacityMask {
                maskSource: img.activeMask
            }
        }

        Component {
            id: rippleLayerEffect

            RippleTransition {
                progress: img.transitionProgress

                aspectRatio:
                    root.height > 0
                        ? root.width / root.height
                        : 1
            }
        }

        Item {
            id: viewport

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            width: img.activeTransition === "wipe"
                ? Math.max(1, root.width * img.transitionProgress)
                : root.width

            height: root.height

            clip: img.activeTransition === "wipe"

            CachingImage {
                id: wallpaper

                width: root.width
                height: root.height

                x: 0
                y: 0

                cache: true
                smooth: true

                layer.enabled:
                    img.usesMask
                    || img.activeTransition === "ripple"

                layer.effect:
                    img.activeTransition === "ripple"
                        ? rippleLayerEffect
                        : maskLayerEffect

                onStatusChanged: {
                    if (status === Image.Ready)
                        img.showLoaded();
                }
            }
        }

        Item {
            id: radialMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                anchors.centerIn: parent

                readonly property real startDiameter: 34

                readonly property real maxDiameter:
                    Math.sqrt(
                        root.width * root.width
                        + root.height * root.height
                    )

                width:
                    startDiameter
                    + (maxDiameter - startDiameter)
                    * img.transitionProgress

                height: width
                radius: width / 2

                color: "white"
                antialiasing: true
            }
        }

        Item {
            id: splitMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                x:
                    root.width / 2
                    - root.width / 2
                    * img.transitionProgress

                y: 0

                width:
                    root.width / 2
                    * img.transitionProgress

                height: root.height
                color: "white"
            }

            Rectangle {
                x: root.width / 2
                y: 0

                width:
                    root.width / 2
                    * img.transitionProgress

                height: root.height
                color: "white"
            }
        }

        Item {
            id: blindsMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            readonly property int rows: 9

            Repeater {
                model: blindsMask.rows

                Rectangle {
                    required property int index

                    readonly property real rowHeight:
                        root.height / blindsMask.rows

                    y: index * rowHeight

                    width:
                        root.width
                        * img.transitionProgress

                    height: rowHeight + 1

                    x: index % 2 === 0
                        ? 0
                        : root.width - width

                    color: "white"
                }
            }
        }

        // curtain
        //
        // Opens upward and downward from the horizontal centre.

        Item {
            id: curtainMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                x: 0

                y:
                    root.height / 2
                    - root.height / 2
                    * img.transitionProgress

                width: root.width

                height:
                    root.height / 2
                    * img.transitionProgress

                color: "white"
            }

            Rectangle {
                x: 0
                y: root.height / 2

                width: root.width

                height:
                    root.height / 2
                    * img.transitionProgress

                color: "white"
            }
        }

        // columns
        //
        // Alternating vertical shutters from top and bottom.

        Item {
            id: columnsMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            readonly property int columns: 11
            readonly property real columnWidth:
                root.width / columns

            Repeater {
                model: columnsMask.columns

                Rectangle {
                    required property int index

                    x:
                        index
                        * columnsMask.columnWidth

                    width:
                        columnsMask.columnWidth + 1

                    height:
                        root.height
                        * img.transitionProgress

                    y:
                        index % 2 === 0
                            ? 0
                            : root.height - height

                    color: "white"
                }
            }
        }

        // diagonal
        //
        // Horizontal strips begin at slightly different times.

        Item {
            id: diagonalMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            readonly property int rows: 22
            readonly property real rowHeight:
                root.height / rows

            Repeater {
                model: diagonalMask.rows

                Rectangle {
                    required property int index

                    readonly property real delay:
                        index
                        / Math.max(1, diagonalMask.rows - 1)
                        * 0.32

                    readonly property real progress:
                        Math.max(
                            0,
                            Math.min(
                                1,
                                (
                                    img.transitionProgress
                                    - delay
                                ) / 0.68
                            )
                        )

                    x: 0

                    y:
                        index
                        * diagonalMask.rowHeight

                    width:
                        root.width
                        * progress

                    height:
                        diagonalMask.rowHeight + 1

                    color: "white"
                }
            }
        }

        // slices
        //
        // Vertical strips arrive with staggered timing.

        Item {
            id: slicesMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            readonly property int columns: 13
            readonly property real columnWidth:
                root.width / columns

            Repeater {
                model: slicesMask.columns

                Rectangle {
                    required property int index

                    readonly property real delay:
                        index
                        / Math.max(1, slicesMask.columns - 1)
                        * 0.34

                    readonly property real progress:
                        Math.max(
                            0,
                            Math.min(
                                1,
                                (
                                    img.transitionProgress
                                    - delay
                                ) / 0.66
                            )
                        )

                    x:
                        index
                        * slicesMask.columnWidth

                    width:
                        slicesMask.columnWidth + 1

                    height:
                        root.height
                        * progress

                    y:
                        index % 2 === 0
                            ? 0
                            : root.height - height

                    color: "white"
                }
            }
        }

        // corner
        //
        // Radial reveal starting from the top-left corner.

        Item {
            id: cornerMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                readonly property real maxDiameter:
                    Math.sqrt(
                        root.width * root.width
                        + root.height * root.height
                    ) * 2

                width:
                    Math.max(
                        1,
                        maxDiameter
                        * img.transitionProgress
                    )

                height: width
                radius: width / 2

                x: -width / 2
                y: -height / 2

                color: "white"
                antialiasing: true
            }
        }

        // cross
        //
        // A thin centre cross expands until it fills the display.

        Item {
            id: crossMask

            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                anchors.centerIn: parent

                width: root.width

                height:
                    Math.max(
                        1,
                        root.height
                        * img.transitionProgress
                    )

                color: "white"
            }

            Rectangle {
                anchors.centerIn: parent

                width:
                    Math.max(
                        1,
                        root.width
                        * img.transitionProgress
                    )

                height: root.height

                color: "white"
            }
        }

        SequentialAnimation {
            id: radialAnim

            NumberAnimation {
                target: img
                property: "transitionProgress"

                from: 0
                to: 0.09

                duration: 380
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: img
                property: "transitionProgress"

                from: 0.09
                to: 1

                duration: 820
                easing.type: Easing.InOutCubic
            }
        }

        NumberAnimation {
            id: transitionAnim

            target: img
            property: "transitionProgress"

            from: 0
            to: 1

            duration: img.transitionDuration
            easing.type: Easing.InOutCubic
        }
    }

}
