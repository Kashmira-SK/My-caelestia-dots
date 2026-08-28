import qs.components
import qs.config
import qs.services
import QtQuick

StyledText {
    color: Qt.alpha(
        Colours.palette.m3onSurfaceVariant,
        0.7
    )

    font.pointSize:
        Appearance.font.size.smaller

    font.weight: 600
    font.letterSpacing: 1.2
}