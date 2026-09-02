import qs.components
import qs.components.images
import qs.services
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities

    property int selectedIndex: 0

    readonly property int wallpaperCount: Wallpapers.list.length

    readonly property var selectedWallpaper:
        wallpaperCount > 0
            ? Wallpapers.list[wrappedIndex(selectedIndex)]
            : null

    readonly property var previousWallpaper:
        wallpaperCount > 1
            ? Wallpapers.list[wrappedIndex(selectedIndex - 1)]
            : null

    readonly property var nextWallpaper:
        wallpaperCount > 1
            ? Wallpapers.list[wrappedIndex(selectedIndex + 1)]
            : null

    readonly property bool selectedIsCurrent:
        selectedWallpaper
        && selectedWallpaper.path === Wallpapers.actualCurrent

    implicitWidth: 980
    implicitHeight: 430

    focus: visibilities.wallpaperPicker

    function wrappedIndex(index: int): int {
        if (wallpaperCount <= 0)
            return 0;

        return ((index % wallpaperCount) + wallpaperCount) % wallpaperCount;
    }

    function syncToCurrent(): void {
        if (wallpaperCount <= 0) {
            selectedIndex = 0;
            return;
        }

        const index = Wallpapers.list.findIndex(
            wallpaper => wallpaper.path === Wallpapers.actualCurrent
        );

        selectedIndex = index >= 0 ? index : 0;
    }

    function previous(): void {
        if (wallpaperCount <= 1)
            return;

        selectedIndex = wrappedIndex(selectedIndex - 1);
        navigationAnim.restart();
    }

    function next(): void {
        if (wallpaperCount <= 1)
            return;

        selectedIndex = wrappedIndex(selectedIndex + 1);
        navigationAnim.restart();
    }

    function applySelected(): void {
        if (!selectedWallpaper)
            return;

        if (!selectedIsCurrent)
            Wallpapers.setWallpaper(selectedWallpaper.path);

        visibilities.wallpaperPicker = false;
    }

    Keys.onLeftPressed: previous()
    Keys.onRightPressed: next()
    Keys.onReturnPressed: applySelected()
    Keys.onEnterPressed: applySelected()

    Keys.onEscapePressed: {
        visibilities.wallpaperPicker = false;
    }

    Connections {
        target: root.visibilities

        function onWallpaperPickerChanged(): void {
            if (!root.visibilities.wallpaperPicker)
                return;

            root.syncToCurrent();
            Qt.callLater(() => root.forceActiveFocus());
        }
    }

    Item {
        id: gallery

        anchors.left: parent.left
        anchors.right: parent.right

        anchors.verticalCenter: parent.verticalCenter

        height: 405

        PreviewCard {
            id: previousCard

            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter

            width: 330
            height: 286

            z: 0
            scale: 0.9
            opacity: 0.5

            imagePath:
                root.previousWallpaper?.path ?? ""

            overlayOpacity: 0.18

            onActivated: {
                root.forceActiveFocus();
                root.previous();
            }
        }

        PreviewCard {
            id: nextCard

            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter

            width: 330
            height: 286

            z: 0
            scale: 0.9
            opacity: 0.5

            imagePath:
                root.nextWallpaper?.path ?? ""

            overlayOpacity: 0.18

            onActivated: {
                root.forceActiveFocus();
                root.next();
            }
        }

        PreviewCard {
            id: heroCard

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            width: 660
            height: 372

            z: 2

            imagePath:
                root.selectedWallpaper?.path ?? ""

            borderWidth: root.selectedIsCurrent ? 2 : 1

            borderColour: root.selectedIsCurrent
                ? Qt.alpha(Colours.palette.m3primary, 0.8)
                : Qt.alpha(Colours.palette.m3outlineVariant, 0.4)

            onActivated: {
                root.forceActiveFocus();
                root.applySelected();
            }

        }
    }

    ParallelAnimation {
        id: navigationAnim

        NumberAnimation {
            target: heroCard
            property: "scale"

            from: 0.975
            to: 1

            duration: 220
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: heroCard
            property: "opacity"

            from: 0.72
            to: 1

            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    component PreviewCard: Item {
        id: card

        property string imagePath
        property int retryCount: 0
        property bool resettingSource: false

        property real overlayOpacity: 0

        property int borderWidth: 1
        property color borderColour:
            Qt.alpha(Colours.palette.m3outlineVariant, 0.25)

        signal activated()

        StyledClippingRect {
            anchors.fill: parent

            radius: Appearance.rounding.large

            color: Colours.palette.m3surfaceContainer

            border.width: card.borderWidth
            border.color: card.borderColour

            MaterialIcon {
                anchors.centerIn: parent

                text: "wallpaper"
                color: Colours.palette.m3outline

                font.pointSize:
                    Appearance.font.size.extraLarge * 2.5
            }

            CachingImage {
                id: image

                anchors.fill: parent

                path: card.resettingSource
                    ? ""
                    : card.imagePath

                cache: true
                smooth: true

                onStatusChanged: {
                    if (status === Image.Ready) {
                        card.retryCount = 0;
                    } else if (
                        status === Image.Error
                        && card.retryCount < 2
                    ) {
                        card.retryCount++;
                        card.resettingSource = true;
                        retryTimer.restart();
                    }
                }
            }

            StyledRect {
                visible: card.overlayOpacity > 0

                anchors.fill: parent

                radius: parent.radius

                color: Qt.alpha(
                    Colours.palette.m3surface,
                    card.overlayOpacity
                )
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: card.activated()
            }
        }

        Timer {
            id: retryTimer

            interval: 160

            onTriggered:
                card.resettingSource = false
        }
    }

}
