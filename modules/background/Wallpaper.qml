pragma ComponentBehavior: Bound

import qs.components
import qs.components.images
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
        property real revealProgress: 0

        function update(): void {
            if (path === root.source) {
                if (wallpaper.status === Image.Ready)
                    showLoaded();
                return;
            }

            revealAnim.stop();
            revealProgress = 0;
            path = root.source;
        }

        function showLoaded(): void {
            revealAnim.stop();
            revealProgress = 0;
            root.current = img;
            revealAnim.start();
        }

        anchors.fill: parent
        z: root.current === img ? 1 : 0

        Item {
            id: reveal

            anchors.centerIn: parent

            width: Math.max(1, root.width * img.revealProgress)
            height: Math.max(1, root.height * img.revealProgress)

            clip: true

            CachingImage {
                id: wallpaper

                width: root.width
                height: root.height

                x: (reveal.width - width) / 2
                y: (reveal.height - height) / 2

                scale: 1.035 - img.revealProgress * 0.035

                onStatusChanged: {
                    if (status === Image.Ready)
                        img.showLoaded();
                }
            }
        }

        NumberAnimation {
            id: revealAnim

            target: img
            property: "revealProgress"

            from: 0
            to: 1

            duration: 700
            easing.type: Easing.OutCubic
        }
    }

}
