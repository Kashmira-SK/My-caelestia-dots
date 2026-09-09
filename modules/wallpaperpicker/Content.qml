pragma ComponentBehavior: Bound

import qs.services
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities

    property int selectedIndex: 0
    property int pendingStep: 0
    property bool pendingApply: false
    property int direction: 1
    property real travel: 0
    property bool initialized: false
    property bool presentationReady: false
    property bool browsed: false

    readonly property int wallpaperCount: Wallpapers.list.length
    readonly property var currentCard: cardAtSlot(0)
    readonly property bool moving: slide.running

    implicitWidth: 980
    implicitHeight: 430
    focus: visibilities.wallpaperPicker

    function wrappedIndex(index: int): int {
        return wallpaperCount > 0
            ? ((index % wallpaperCount) + wallpaperCount) % wallpaperCount
            : 0;
    }

    function cardAtSlot(slot: int): var {
        for (let i = 0; i < cards.count; i++) {
            const card = cards.itemAt(i);
            if (card && card.slot === slot)
                return card;
        }
        return null;
    }

    function pathAtOffset(offset: int): string {
        if (wallpaperCount === 0 || (wallpaperCount === 1 && offset !== 0))
            return "";
        return Wallpapers.list[wrappedIndex(selectedIndex + offset)].path;
    }

    function revealCurrent(): void {
        if (initialized && currentCard && (currentCard.ready || currentCard.failed))
            presentationReady = true;
    }

    function syncToCurrent(): void {
        if (!initialized)
            return;

        presentationReady = false;
        slide.stop();
        travel = 0;
        pendingStep = 0;
        pendingApply = false;
        browsed = false;
        const index = Wallpapers.list.findIndex(w => w.path === Wallpapers.actualCurrent);
        selectedIndex = index >= 0 ? index : 0;

        for (let i = 0; i < cards.count; i++) {
            const card = cards.itemAt(i);
            card.slot = i - 2;
            // The wallpaper list may still be loading when the picker opens.
            card.imagePath = card.slot === 0 && Wallpapers.actualCurrent
                ? Wallpapers.actualCurrent : pathAtOffset(card.slot);
        }
        Qt.callLater(revealCurrent);
    }

    function navigate(step: int, autoRepeat: bool): void {
        if (!visibilities.wallpaperPicker || !presentationReady || wallpaperCount <= 1 || (step !== -1 && step !== 1))
            return;

        pendingApply = false;
        if (moving) {
            // Queue one deliberate press without accumulating held-key repeats.
            if (!autoRepeat)
                pendingStep = step;
            return;
        }
        pendingStep = 0;
        browsed = true;
        direction = step;
        slide.start();
    }

    function finishSlide(): void {
        selectedIndex = wrappedIndex(selectedIndex + direction);
        for (let i = 0; i < cards.count; i++) {
            const card = cards.itemAt(i);
            let slot = card.slot - direction;
            if (slot < -2 || slot > 2) {
                slot = slot < -2 ? 2 : -2;
                // Only recycle the card beyond the visible edge. All other
                // cards retain their textures as they move through the centre.
                card.imagePath = pathAtOffset(slot);
            }
            card.slot = slot;
        }
        travel = 0;
        if (pendingApply)
            applySelected();
        else if (pendingStep) {
            const step = pendingStep;
            pendingStep = 0;
            Qt.callLater(() => root.navigate(step, false));
        }
    }

    function applySelected(): void {
        pendingStep = 0;
        if (moving) {
            pendingApply = true;
            return;
        }
        pendingApply = false;
        if (!currentCard?.imagePath || !currentCard.ready)
            return;
        if (currentCard.imagePath !== Wallpapers.actualCurrent)
            Wallpapers.setWallpaper(currentCard.imagePath);
        visibilities.wallpaperPicker = false;
    }

    Keys.onLeftPressed: event => navigate(-1, event.isAutoRepeat)
    Keys.onUpPressed: event => navigate(-1, event.isAutoRepeat)
    Keys.onRightPressed: event => navigate(1, event.isAutoRepeat)
    Keys.onDownPressed: event => navigate(1, event.isAutoRepeat)
    Keys.onReturnPressed: applySelected()
    Keys.onEnterPressed: applySelected()
    Keys.onEscapePressed: visibilities.wallpaperPicker = false

    Component.onCompleted: {
        initialized = true;
        syncToCurrent();
    }

    Connections {
        target: root.visibilities

        function onWallpaperPickerChanged(): void {
            root.pendingStep = 0;
            root.pendingApply = false;
            if (root.visibilities.wallpaperPicker) {
                root.syncToCurrent();
                Qt.callLater(() => root.forceActiveFocus());
            } else {
                // Keep the last rendered frame for the wrapper's exit animation.
                slide.stop();
            }
        }
    }

    Connections {
        target: Wallpapers

        function onActualCurrentChanged(): void {
            if (root.visibilities.wallpaperPicker && !root.browsed)
                root.syncToCurrent();
        }

        function onListChanged(): void {
            if (root.visibilities.wallpaperPicker && !root.browsed)
                root.syncToCurrent();
        }
    }

    NumberAnimation {
        id: slide
        target: root
        property: "travel"
        from: 0
        to: root.direction
        duration: 360
        easing.type: Easing.OutCubic
        onFinished: root.finishSlide()
    }

    Item {
        id: gallery

        anchors.fill: parent
        visible: root.presentationReady
        clip: true

        // Three visible cards, plus one preloaded card beyond each edge.
        Repeater {
            id: cards
            model: 5

            PreviewCard {
                id: card
                required property int index
                property int slot: index - 2
                readonly property real position: slot - root.travel
                readonly property real distance: Math.abs(position)
                readonly property real centre: {
                    const side = position < 0 ? -1 : 1;
                    if (distance <= 1)
                        return gallery.width / 2 + position * 300;
                    return gallery.width / 2 + side * (300 + (distance - 1) * 420);
                }

                width: 660
                height: 372
                x: centre - width / 2
                y: (gallery.height - height) / 2
                scale: 1 - Math.min(distance, 1) * 0.48
                opacity: distance <= 1 ? 1 - distance * 0.45 : Math.max(0, 0.55 * (2 - distance))
                z: 2 - distance
                visible: imagePath !== "" && distance < 2
                overlayOpacity: Math.min(distance, 1) * 0.18
                borderWidth: imagePath === Wallpapers.actualCurrent ? 2 : 1
                borderColour: imagePath === Wallpapers.actualCurrent
                    ? Qt.alpha(Colours.palette.m3primary, 0.8)
                    : Qt.alpha(Colours.palette.m3outlineVariant, 0.4)

                onReadyChanged: Qt.callLater(root.revealCurrent)
                onFailedChanged: Qt.callLater(root.revealCurrent)
                onActivated: {
                    root.forceActiveFocus();
                    if (slot === 0)
                        root.applySelected();
                    else
                        root.navigate(slot < 0 ? -1 : 1, false);
                }
            }
        }
    }
}
