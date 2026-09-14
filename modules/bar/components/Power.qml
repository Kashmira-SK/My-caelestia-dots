import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Controls as Controls

Controls.AbstractButton {
    id: root
    required property PersistentProperties visibilities

    implicitWidth: Config.bar.sizes.innerWidth
    implicitHeight: 30
    hoverEnabled: true
    activeFocusOnTab: true
    Accessible.name: qsTr("Power menu")
    onClicked: visibilities.session = !visibilities.session

    contentItem: Item {
        Canvas {
            anchors.centerIn: parent
            implicitWidth: 20
            implicitHeight: 20
            property color ink: Colours.palette.m3error
            onInkChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = ink;
                ctx.lineWidth = 1.5;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                // An open, softly squared power socket rather than a circular glyph.
                ctx.beginPath();
                ctx.moveTo(6, 5);
                ctx.lineTo(4, 5);
                ctx.lineTo(4, 13);
                ctx.quadraticCurveTo(4, 16, 7, 16);
                ctx.lineTo(13, 16);
                ctx.quadraticCurveTo(16, 16, 16, 13);
                ctx.lineTo(16, 5);
                ctx.lineTo(14, 5);
                ctx.moveTo(10, 2);
                ctx.lineTo(10, 10);
                ctx.stroke();
            }
        }
    }

    background: StyledRect {
        radius: Appearance.rounding.panel
        color: Colours.tPalette.m3surfaceContainer
        border.width: root.visibilities.session || root.visualFocus ? 1 : 0
        border.color: Colours.palette.m3error

        StyledRect {
            anchors.fill: parent
            radius: parent.radius
            color: Colours.palette.m3error
            opacity: root.down ? 0.12 : root.hovered ? 0.08 : 0
        }
    }
}
