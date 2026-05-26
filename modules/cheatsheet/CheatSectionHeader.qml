pragma ComponentBehavior: Bound

import qs.components
import qs.config
import QtQuick
import QtQuick.Layouts

StyledText {
    font.pointSize: Appearance.font.size.small
    font.weight: Font.Medium
    font.capitalization: Font.AllUppercase
    color: Colours.palette.m3outline

    Layout.topMargin: Appearance.spacing.normal
    Layout.bottomMargin: Appearance.spacing.smaller
}
