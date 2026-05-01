pragma Singleton

import ".."
import qs.config
import qs.utils
import Quickshell
import QtQuick

Searcher {
    id: root

    function transformSearch(search: string): string {
        return search.slice(`${Config.launcher.actionPrefix}variant `.length);
    }

    list: [
        Variant {
            variant: "tonalspot"
            icon: "lens" 
            name: qsTr("Tonal Spot")
            description: qsTr("A balanced, pastel palette that is easy on the eyes.")
        },
        Variant {
            variant: "expressive"
            icon: "compare_arrows"
            name: qsTr("Expressive")
            description: qsTr("Brings in complementary colors for a more varied UI.")
        },
        Variant {
            variant: "fidelity"
            icon: "compare"
            name: qsTr("Fidelity")
            description: qsTr("Tries to perfectly match the exact color of your wallpaper.")
        },
        Variant {
            variant: "vibrant"
            icon: "palette"
            name: qsTr("Vibrant")
            description: qsTr("Maximum color intensity. Good for very dull wallpapers.")
        },
        Variant {
            variant: "neutral"
            icon: "contrast"
            name: qsTr("Neutral")
            description: qsTr("Washes out most of the color. Great for focus.")
        }
    ]
    useFuzzy: Config.launcher.useFuzzy.variants

    component Variant: QtObject {
        required property string variant
        required property string icon
        required property string name
        required property string description

        function onClicked(list: AppList): void {
            list.visibilities.launcher = false;
            Quickshell.execDetached(["caelestia", "scheme", "set", "-v", variant]);
        }
    }
}
