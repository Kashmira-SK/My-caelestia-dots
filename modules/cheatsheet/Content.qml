pragma ComponentBehavior: Bound

import "../controlcenter"
import qs.components
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property Session session
    anchors.fill: parent

    StyledFlickable {
        id: flick
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        contentHeight: layout.implicitHeight
        flickableDirection: Flickable.VerticalFlick

        ColumnLayout {
            id: layout
            width: flick.width
            spacing: Appearance.spacing.small

            SectionHeader {
                title: qsTr("CLI Tools")
            }

            StyledText { text: "eza      - ls replacement" }
            StyledText { text: "zoxide   - cd replacement (z)" }
            StyledText { text: "fzf      - fuzzy finder" }
            StyledText { text: "starship - shell prompt" }
            StyledText { text: "nvim     - editor" }

            SectionHeader {
                title: qsTr("Repos")
            }

            StyledText { text: "caelestia    - github.com/Kashmira-SK/My-caelestia-dots" }
            StyledText { text: "firefox-dots - github.com/Kashmira-SK/firefox-dots (private)" }
            StyledText { text: "ticket app   - ~/git/ticket-booking/" }
            StyledText { text: "termchat     - ~/git/ (python / cerebras)" }
        }
    }
}
