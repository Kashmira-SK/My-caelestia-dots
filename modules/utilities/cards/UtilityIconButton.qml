pragma ComponentBehavior: Bound

import qs.components.controls
import qs.components.effects
import QtQuick

IconButton {
    id: root

    required property string glyph

    // Keep IconButton's existing state, size and palette bindings; only swap the glyph.
    label.visible: false

    ColouredIcon {
        anchors.centerIn: parent
        implicitSize: 16
        source: Qt.resolvedUrl("../../../assets/icons/lucide/" + root.glyph + ".svg")
        colour: root.label.color
    }
}
