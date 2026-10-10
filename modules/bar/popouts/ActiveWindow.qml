import qs.components
import qs.services
import qs.utils
import qs.config
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Item wrapper
    readonly property var windowSize: Hypr.activeToplevel?.lastIpcObject.size ?? [1, 1]
    readonly property real previewAspect: Math.max(1, windowSize[0]) / Math.max(1, windowSize[1])

    implicitWidth: Hypr.activeToplevel ? Config.bar.sizes.windowPreviewSize : -Appearance.padding.large * 2
    implicitHeight: child.implicitHeight

    Column {
        id: child

        anchors.centerIn: parent
        width: Math.max(0, root.implicitWidth)
        spacing: Appearance.spacing.normal

        RowLayout {
            id: detailsRow

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.normal

            IconImage {
                id: icon

                Layout.alignment: Qt.AlignVCenter
                implicitSize: 24
                source: Icons.getAppIcon(Hypr.activeToplevel?.lastIpcObject.class ?? "", "image-missing")
            }

            ColumnLayout {
                id: details

                spacing: 0
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: Hypr.activeToplevel?.title ?? ""
                    font.pointSize: Appearance.font.size.small
                    font.family: Appearance.font.family.sans
                    font.weight: 500
                    wrapMode: Text.Wrap
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Hypr.activeToplevel?.lastIpcObject.class ?? ""
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                    font.family: Appearance.font.family.sans
                    elide: Text.ElideRight
                }
            }

            ConnectionAction {
                Layout.alignment: Qt.AlignVCenter
                glyph: "scan"
                text: qsTr("Open window controls")
                onClicked: root.wrapper.detach("winfo")
            }
        }

        ClippingWrapperRectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            radius: Appearance.rounding.panel
            // Reserve the capture area before the first frame arrives.
            implicitWidth: Config.bar.sizes.windowPreviewSize * Math.min(1, root.previewAspect)
            implicitHeight: Config.bar.sizes.windowPreviewSize / Math.max(1, root.previewAspect)

            ScreencopyView {
                id: preview

                captureSource: Hypr.activeToplevel?.wayland ?? null
                live: visible
                opacity: hasContent ? 1 : 0

                Behavior on opacity {
                    Anim {
                        duration: Appearance.anim.durations.small
                    }
                }

                constraintSize.width: Config.bar.sizes.windowPreviewSize
                constraintSize.height: Config.bar.sizes.windowPreviewSize
            }
        }
    }
}
