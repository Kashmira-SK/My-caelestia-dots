pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import Quickshell.Wayland
import QtQuick

Loader {
    active: Config.background.enabled

    sourceComponent: Variants {
        model: Quickshell.screens

        StyledWindow {
            id: win

            required property ShellScreen modelData

            screen: modelData
            name: "background"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            // Stay above mpvpaper so the poster can cover player replacement.
            WlrLayershell.layer: WlrLayer.Bottom
            color: "transparent"
            surfaceFormat.opaque: false

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Item {
                id: behindClock

                anchors.fill: parent

                Loader {
                    id: wallpaper

                    anchors.fill: parent
                    active: Config.background.wallpaperEnabled
                    opacity: !Wallpapers.liveRunning || Wallpapers.handoff || !item || item.transitioning ? 1 : 0
                    visible: opacity > 0
                    readonly property bool settled: !!item && !item.transitioning
                    property bool covered: false
                    property bool revealed: false
                    property bool transitioned: false
                    property int stableFrames: 0
                    readonly property bool coverReady: opacity === 1 && settled
                    readonly property bool revealReady: opacity === 0
                    function resetAcknowledgement(): void {
                        stableFrames = 0;
                        covered = false;
                        revealed = false;
                        transitioned = false;
                    }
                    onCoverReadyChanged: resetAcknowledgement()
                    onRevealReadyChanged: resetAcknowledgement()
                    onSettledChanged: resetAcknowledgement()
                    Component.onCompleted: Wallpapers.registerSurface(wallpaper)
                    Component.onDestruction: Wallpapers.unregisterSurface(wallpaper)

                    Connections {
                        target: Wallpapers
                        function onSelectionIdChanged(): void { wallpaper.resetAcknowledgement(); }
                    }

                    // Acknowledge stable rendered frames, not elapsed wall time.
                    FrameAnimation {
                        running: ["cover", "transition", "reveal"].includes(Wallpapers.phase)
                        onTriggered: {
                            if (++wallpaper.stableFrames >= 2) {
                                wallpaper.covered = wallpaper.coverReady;
                                wallpaper.transitioned = wallpaper.coverReady;
                                wallpaper.revealed = wallpaper.revealReady;
                                Wallpapers.checkTransition();
                            }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 220 }
                    }

                    sourceComponent: Wallpaper {}
                }

                Visualiser {
                    anchors.fill: parent
                    screen: win.modelData
                    wallpaper: wallpaper
                }
            }

            Loader {
                id: clockLoader
                active: Config.background.desktopClock.enabled

                anchors.margins: Appearance.padding.large * 2
                anchors.leftMargin: Appearance.padding.large * 2 + Config.bar.sizes.innerWidth + Math.max(Appearance.padding.smaller, Config.border.thickness)

                state: Config.background.desktopClock.position
                states: [
                    State {
                        name: "top-left"
                        AnchorChanges {
                            target: clockLoader
                            anchors.top: parent.top
                            anchors.left: parent.left
                        }
                    },
                    State {
                        name: "top-center"
                        AnchorChanges {
                            target: clockLoader
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    },
                    State {
                        name: "top-right"
                        AnchorChanges {
                            target: clockLoader
                            anchors.top: parent.top
                            anchors.right: parent.right
                        }
                    },
                    State {
                        name: "middle-left"
                        AnchorChanges {
                            target: clockLoader
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                        }
                    },
                    State {
                        name: "middle-center"
                        AnchorChanges {
                            target: clockLoader
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    },
                    State {
                        name: "middle-right"
                        AnchorChanges {
                            target: clockLoader
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                        }
                    },
                    State {
                        name: "bottom-left"
                        AnchorChanges {
                            target: clockLoader
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                        }
                    },
                    State {
                        name: "bottom-center"
                        AnchorChanges {
                            target: clockLoader
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    },
                    State {
                        name: "bottom-right"
                        AnchorChanges {
                            target: clockLoader
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                    }
                ]

                transitions: Transition {
                    AnchorAnimation {
                        duration: Appearance.anim.durations.expressiveDefaultSpatial
                        easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                    }
                }

                sourceComponent: DesktopClock {
                    wallpaper: behindClock
                    absX: clockLoader.x
                    absY: clockLoader.y
                }
            }
        }
    }
}
