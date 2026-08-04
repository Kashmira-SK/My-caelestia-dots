pragma ComponentBehavior: Bound

import "../controlcenter"
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property Session session
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 8

            Text {
                text: "CLI Tools"
                color: "#f5e0dc"
                font.pixelSize: 24
                font.bold: true
            }

            Text { text: "eza      - ls replacement"; color: "#cdd6f4"; font.pixelSize: 16 }
            Text { text: "zoxide   - cd replacement (z)"; color: "#cdd6f4"; font.pixelSize: 16 }
            Text { text: "fzf      - fuzzy finder"; color: "#cdd6f4"; font.pixelSize: 16 }
            Text { text: "starship - shell prompt"; color: "#cdd6f4"; font.pixelSize: 16 }
            Text { text: "nvim     - editor"; color: "#cdd6f4"; font.pixelSize: 16 }

            Text {
                text: "Repos"
                color: "#f5e0dc"
                font.pixelSize: 24
                font.bold: true
                Layout.topMargin: 16
            }

            Text { text: "caelestia    - github.com/Kashmira-SK/My-caelestia-dots"; color: "#cdd6f4"; font.pixelSize: 16 }
            Text { text: "firefox-dots - github.com/Kashmira-SK/firefox-dots (private)"; color: "#cdd6f4"; font.pixelSize: 16 }
            Text { text: "ticket app   - ~/git/ticket-booking/"; color: "#cdd6f4"; font.pixelSize: 16 }
            Text { text: "termchat     - ~/git/ (python / cerebras)"; color: "#cdd6f4"; font.pixelSize: 16 }

            Item { Layout.fillHeight: true }
        }
    }
}
