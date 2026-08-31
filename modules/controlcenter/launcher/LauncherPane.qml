pragma ComponentBehavior: Bound

import ".."
import "../components"
import "../../launcher/services"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Caelestia
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../../utils/scripts/fuzzysort.js" as Fuzzy

Item {
    id: root

    required property Session session

    property var selectedApp: root.session.launcher.active
    property bool hideFromLauncherChecked: false
    property bool favouriteChecked: false
    property string searchText: ""
    property list<var> filteredApps: []

    anchors.fill: parent

    onSelectedAppChanged: {
        root.session.launcher.active = root.selectedApp;
        updateToggleState();
    }

    Connections {
        target: root.session.launcher

        function onActiveChanged() {
            root.selectedApp = root.session.launcher.active;
            updateToggleState();
        }
    }

    function updateToggleState() {
        if (!root.selectedApp) {
            root.hideFromLauncherChecked = false;
            root.favouriteChecked = false;
            return;
        }

        const appId = root.selectedApp.id || root.selectedApp.entry?.id;

        root.hideFromLauncherChecked =
            Config.launcher.hiddenApps
            && Config.launcher.hiddenApps.length > 0
            && Strings.testRegexList(
                Config.launcher.hiddenApps,
                appId
            );

        root.favouriteChecked =
            Config.launcher.favouriteApps
            && Config.launcher.favouriteApps.length > 0
            && Strings.testRegexList(
                Config.launcher.favouriteApps,
                appId
            );
    }

    function saveHiddenApps(isHidden) {
        if (!root.selectedApp)
            return;

        const appId =
            root.selectedApp.id
            || root.selectedApp.entry?.id;

        const hiddenApps =
            Config.launcher.hiddenApps
            ? [...Config.launcher.hiddenApps]
            : [];

        if (isHidden) {
            if (!hiddenApps.includes(appId))
                hiddenApps.push(appId);
        } else {
            const index = hiddenApps.indexOf(appId);

            if (index !== -1)
                hiddenApps.splice(index, 1);
        }

        Config.launcher.hiddenApps = hiddenApps;
        Config.save();
    }

    AppDb {
        id: allAppsDb

        path: `${Paths.state}/apps.sqlite`
        favouriteApps: Config.launcher.favouriteApps
        entries: DesktopEntries.applications.values
    }

    function filterApps(search: string): list<var> {
        if (!search || search.trim() === "") {
            const apps = [];

            for (let i = 0; i < allAppsDb.apps.length; i++)
                apps.push(allAppsDb.apps[i]);

            return apps;
        }

        if (!allAppsDb.apps || allAppsDb.apps.length === 0)
            return [];

        const preparedApps = [];

        for (let i = 0; i < allAppsDb.apps.length; i++) {
            const app = allAppsDb.apps[i];
            const name =
                app.name
                || app.entry?.name
                || "";

            preparedApps.push({
                _item: app,
                name: Fuzzy.prepare(name)
            });
        }

        const results = Fuzzy.go(
            search,
            preparedApps,
            {
                all: true,
                keys: ["name"],
                scoreFn: r => r[0].score
            }
        );

        return results
            .sort((a, b) => b._score - a._score)
            .map(r => r.obj._item);
    }

    function updateFilteredApps() {
        filteredApps = filterApps(searchText);
    }

    onSearchTextChanged:
        updateFilteredApps()

    Component.onCompleted:
        updateFilteredApps()

    Connections {
        target: allAppsDb

        function onAppsChanged() {
            updateFilteredApps();
        }
    }

    SplitPaneLayout {
        anchors.fill: parent

        leftContent: Component {
            ColumnLayout {
                id: leftLauncherLayout

                anchors.fill: parent
                spacing: Appearance.spacing.normal

                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: Appearance.spacing.small
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: qsTr("LAUNCHER")
                        font.pointSize: Appearance.font.size.large
                        font.weight: 500
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1

                        color: Qt.alpha(
                            Colours.palette.m3outlineVariant,
                            0.22
                        )
                    }

                    ToolButton {
                        active:
                            root.session.launcher.active === null

                        icon: "settings"
                        text: qsTr("Settings")

                        onClicked: {
                            if (root.session.launcher.active) {
                                root.session.launcher.active = null;
                            } else if (root.filteredApps.length > 0) {
                                root.session.launcher.active =
                                    root.filteredApps[0];
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledText {
                        text:
                            qsTr("APPLICATIONS")
                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.72
                        )
                        font.pointSize:
                            Appearance.font.size.smaller
                        font.weight: 500
                        font.letterSpacing: 0.8
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1

                        color: Qt.alpha(
                            Colours.palette.m3outlineVariant,
                            0.20
                        )
                    }

                    StyledText {
                        text:
                            qsTr("%1")
                            .arg(
                                root.searchText
                                ? root.filteredApps.length
                                : allAppsDb.apps.length
                            )

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.46
                        )

                        font.family:
                            Appearance.font.family.mono

                        font.pointSize:
                            Appearance.font.size.smaller
                    }
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 42

                    Rectangle {
                        anchors.fill: parent

                        radius: Appearance.rounding.small
                        color: "transparent"

                        border.width: 1
                        border.color: searchField.activeFocus
                            ? Qt.alpha(
                                Colours.palette.m3primary,
                                0.62
                            )
                            : Qt.alpha(
                                Colours.palette.m3outlineVariant,
                                0.28
                            )
                    }

                    MaterialIcon {
                        id: searchIcon

                        anchors.left: parent.left
                        anchors.leftMargin: Appearance.padding.normal
                        anchors.verticalCenter: parent.verticalCenter

                        text: "search"
                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.62
                        )
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledTextField {
                        id: searchField

                        anchors.left: searchIcon.right
                        anchors.right: clearIcon.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        anchors.leftMargin: Appearance.spacing.small
                        anchors.rightMargin: Appearance.spacing.small

                        topPadding: 0
                        bottomPadding: 0

                        placeholderText:
                            qsTr("Search applications")

                        onTextChanged:
                            root.searchText = text
                    }

                    MaterialIcon {
                        id: clearIcon

                        anchors.right: parent.right
                        anchors.rightMargin: Appearance.padding.normal
                        anchors.verticalCenter: parent.verticalCenter

                        visible: searchField.text !== ""
                        text: "close"

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            clearMouse.containsMouse ? 0.86 : 0.58
                        )

                        font.pointSize: Appearance.font.size.small

                        MouseArea {
                            id: clearMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                searchField.text = ""
                        }
                    }
                }

                Loader {
                    id: appsListLoader

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    asynchronous: true
                    active: true

                    sourceComponent: StyledListView {
                        id: appsListView

                        model: root.filteredApps
                        spacing: 2
                        clip: true

                        delegate: Item {
                            required property var modelData

                            width:
                                parent
                                ? parent.width
                                : 0

                            implicitHeight: 46

                            readonly property bool isSelected:
                                root.selectedApp === modelData

                            Rectangle {
                                anchors.fill: parent

                                radius: Appearance.rounding.small

                                color: isSelected
                                    ? Qt.alpha(
                                        Colours.palette.m3primary,
                                        0.055
                                    )
                                    : appMouse.containsMouse
                                        ? Qt.alpha(
                                            Colours.palette.m3onSurface,
                                            0.025
                                        )
                                        : "transparent"
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                                width: 2
                                height: isSelected ? 24 : 0
                                radius: 1

                                color: Colours.palette.m3primary

                                Behavior on height {
                                    Anim {}
                                }
                            }

                            RowLayout {
                                anchors.fill: parent

                                anchors.leftMargin:
                                    Appearance.padding.normal

                                anchors.rightMargin:
                                    Appearance.padding.normal

                                spacing: Appearance.spacing.normal

                                IconImage {
                                    Layout.alignment: Qt.AlignVCenter
                                    implicitSize: 28

                                    source: {
                                        const entry = modelData.entry;

                                        return entry
                                            ? Quickshell.iconPath(
                                                entry.icon,
                                                "image-missing"
                                            )
                                            : "image-missing";
                                    }
                                }

                                StyledText {
                                    Layout.fillWidth: true

                                    text:
                                        modelData.name
                                        || modelData.entry?.name
                                        || qsTr("Unknown")

                                    color: isSelected
                                        ? Colours.palette.m3onSurface
                                        : Qt.alpha(
                                            Colours.palette.m3onSurface,
                                            0.82
                                        )

                                    font.pointSize:
                                        Appearance.font.size.small

                                    font.weight:
                                        isSelected ? 500 : 400

                                    elide: Text.ElideRight
                                }

                                MaterialIcon {
                                    visible:
                                        modelData
                                        && Strings.testRegexList(
                                            Config.launcher.hiddenApps,
                                            modelData.id
                                        )

                                    text: "visibility_off"
                                    fill: 1

                                    color:
                                        Colours.palette.m3primary

                                    font.pointSize:
                                        Appearance.font.size.small
                                }

                                MaterialIcon {
                                    visible:
                                        modelData
                                        && Strings.testRegexList(
                                            Config.launcher.favouriteApps,
                                            modelData.id
                                        )

                                    text: "favorite"
                                    fill: 1

                                    color:
                                        Colours.palette.m3primary

                                    font.pointSize:
                                        Appearance.font.size.small
                                }
                            }

                            MouseArea {
                                id: appMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked:
                                    root.session.launcher.active =
                                        modelData
                            }
                        }
                    }
                }
            }
        }

        rightContent: Component {
            Item {
                id: rightLauncherPane

                property var pane:
                    root.session.launcher.active

                property string paneId:
                    pane
                    ? (
                        pane.id
                        || pane.entry?.id
                        || ""
                    )
                    : ""

                property Component targetComponent:
                    settings

                property Component nextComponent:
                    settings

                property var displayedApp: null

                function getComponentForPane() {
                    return pane
                        ? appDetails
                        : settings;
                }

                Component.onCompleted: {
                    displayedApp = pane;
                    targetComponent =
                        getComponentForPane();

                    nextComponent =
                        targetComponent;
                }

                Loader {
                    id: rightLauncherLoader

                    anchors.fill: parent

                    opacity: 1
                    scale: 1

                    transformOrigin: Item.Center
                    clip: true

                    sourceComponent:
                        rightLauncherPane.targetComponent

                    active: true

                    property var displayedApp:
                        rightLauncherPane.displayedApp

                    onItemChanged: {
                        if (
                            item
                            && rightLauncherPane.pane
                            && rightLauncherPane.displayedApp
                                !== rightLauncherPane.pane
                        ) {
                            rightLauncherPane.displayedApp =
                                rightLauncherPane.pane;
                        }
                    }
                }

                Behavior on paneId {
                    PaneTransition {
                        target: rightLauncherLoader

                        propertyActions: [
                            PropertyAction {
                                target: rightLauncherPane
                                property: "displayedApp"
                                value: rightLauncherPane.pane
                            },
                            PropertyAction {
                                target: rightLauncherLoader
                                property: "active"
                                value: false
                            },
                            PropertyAction {
                                target: rightLauncherPane
                                property: "targetComponent"
                                value: rightLauncherPane.nextComponent
                            },
                            PropertyAction {
                                target: rightLauncherLoader
                                property: "active"
                                value: true
                            }
                        ]
                    }
                }

                onPaneChanged: {
                    nextComponent =
                        getComponentForPane();

                    paneId =
                        pane
                        ? (
                            pane.id
                            || pane.entry?.id
                            || ""
                        )
                        : "";
                }

                onDisplayedAppChanged: {
                    if (displayedApp) {
                        const appId =
                            displayedApp.id
                            || displayedApp.entry?.id;

                        root.hideFromLauncherChecked =
                            Config.launcher.hiddenApps
                            && Config.launcher.hiddenApps.length > 0
                            && Strings.testRegexList(
                                Config.launcher.hiddenApps,
                                appId
                            );

                        root.favouriteChecked =
                            Config.launcher.favouriteApps
                            && Config.launcher.favouriteApps.length > 0
                            && Strings.testRegexList(
                                Config.launcher.favouriteApps,
                                appId
                            );
                    } else {
                        root.hideFromLauncherChecked = false;
                        root.favouriteChecked = false;
                    }
                }
            }
        }
    }

    Component {
        id: settings

        StyledFlickable {
            id: settingsFlickable

            flickableDirection:
                Flickable.VerticalFlick

            contentHeight:
                settingsInner.height

            Settings {
                id: settingsInner

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                session: root.session
            }
        }
    }

    Component {
        id: appDetails

        StyledFlickable {
            id: appDetailsFlickable

            readonly property var displayedApp:
                parent
                && parent.displayedApp !== undefined
                ? parent.displayedApp
                : null

            flickableDirection:
                Flickable.VerticalFlick

            contentHeight:
                appDetailsLayout.height

            ColumnLayout {
                id: appDetailsLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                spacing: Appearance.spacing.large

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.normal

                    IconImage {
                        Layout.alignment: Qt.AlignVCenter
                        implicitSize: 64

                        source: {
                            const app =
                                appDetailsFlickable.displayedApp;

                            if (!app)
                                return "image-missing";

                            const entry = app.entry;

                            return entry && entry.icon
                                ? Quickshell.iconPath(
                                    entry.icon,
                                    "image-missing"
                                )
                                : "image-missing";
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true

                            text:
                                appDetailsFlickable.displayedApp
                                ? (
                                    appDetailsFlickable.displayedApp.name
                                    || appDetailsFlickable.displayedApp.entry?.name
                                    || qsTr("Application")
                                )
                                : ""

                            font.pointSize:
                                Appearance.font.size.large

                            font.weight: 500
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true

                            text:
                                appDetailsFlickable.displayedApp
                                ? (
                                    appDetailsFlickable.displayedApp.id
                                    || appDetailsFlickable.displayedApp.entry?.id
                                    || ""
                                )
                                : ""

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.52
                            )

                            font.family:
                                Appearance.font.family.mono

                            font.pointSize:
                                Appearance.font.size.smaller

                            elide: Text.ElideMiddle
                        }
                    }
                }

                SectionTitle {
                    title: qsTr("APPLICATION")
                }

                DetailRow {
                    label: qsTr("Favourite")

                    StyledSwitch {
                        checked:
                            root.favouriteChecked

                        enabled:
                            appDetailsFlickable.displayedApp !== null
                            && !root.hideFromLauncherChecked
                            && (
                                Config.launcher.favouriteApps.indexOf(
                                    appDetailsFlickable.displayedApp.id
                                    || appDetailsFlickable.displayedApp.entry?.id
                                ) !== -1
                                || !root.favouriteChecked
                            )

                        opacity:
                            enabled ? 1 : 0.6

                        onToggled: {
                            root.favouriteChecked = checked;

                            const app =
                                appDetailsFlickable.displayedApp;

                            if (!app)
                                return;

                            const appId =
                                app.id
                                || app.entry?.id;

                            const favouriteApps =
                                Config.launcher.favouriteApps
                                ? [...Config.launcher.favouriteApps]
                                : [];

                            if (checked) {
                                if (!favouriteApps.includes(appId))
                                    favouriteApps.push(appId);
                            } else {
                                const index =
                                    favouriteApps.indexOf(appId);

                                if (index !== -1)
                                    favouriteApps.splice(index, 1);
                            }

                            Config.launcher.favouriteApps =
                                favouriteApps;

                            Config.save();
                        }
                    }
                }

                DetailRow {
                    label: qsTr("Hide from launcher")

                    StyledSwitch {
                        checked:
                            root.hideFromLauncherChecked

                        enabled:
                            appDetailsFlickable.displayedApp !== null
                            && !root.favouriteChecked
                            && (
                                Config.launcher.hiddenApps.indexOf(
                                    appDetailsFlickable.displayedApp.id
                                    || appDetailsFlickable.displayedApp.entry?.id
                                ) !== -1
                                || !root.hideFromLauncherChecked
                            )

                        opacity:
                            enabled ? 1 : 0.6

                        onToggled: {
                            root.hideFromLauncherChecked = checked;

                            const app =
                                appDetailsFlickable.displayedApp;

                            if (!app)
                                return;

                            const appId =
                                app.id
                                || app.entry?.id;

                            const hiddenApps =
                                Config.launcher.hiddenApps
                                ? [...Config.launcher.hiddenApps]
                                : [];

                            if (checked) {
                                if (!hiddenApps.includes(appId))
                                    hiddenApps.push(appId);
                            } else {
                                const index =
                                    hiddenApps.indexOf(appId);

                                if (index !== -1)
                                    hiddenApps.splice(index, 1);
                            }

                            Config.launcher.hiddenApps =
                                hiddenApps;

                            Config.save();
                        }
                    }
                }
            }
        }
    }

    component ToolButton: Item {
        id: toolButton

        required property string icon
        required property string text

        property bool active: false

        signal clicked

        implicitWidth:
            buttonRow.implicitWidth
            + Appearance.padding.normal * 2

        implicitHeight: 34

        Rectangle {
            anchors.fill: parent

            radius: Appearance.rounding.small

            color: toolButton.active
                ? Qt.alpha(
                    Colours.palette.m3primary,
                    0.07
                )
                : buttonMouse.containsMouse
                    ? Qt.alpha(
                        Colours.palette.m3onSurface,
                        0.03
                    )
                    : "transparent"

            border.width: 1

            border.color: toolButton.active
                ? Qt.alpha(
                    Colours.palette.m3primary,
                    0.44
                )
                : Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.24
                )
        }

        RowLayout {
            id: buttonRow

            anchors.centerIn: parent
            spacing: 5

            MaterialIcon {
                text: toolButton.icon
                fill: toolButton.active ? 1 : 0

                color: toolButton.active
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.64
                    )

                font.pointSize:
                    Appearance.font.size.small
            }

            StyledText {
                text: toolButton.text

                color: toolButton.active
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.72
                    )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight:
                    toolButton.active ? 500 : 400
            }
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
                toolButton.clicked()
        }
    }

    component SectionTitle: RowLayout {
        id: sectionTitle

        required property string title

        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        StyledText {
            text: sectionTitle.title

            color: Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.72
            )

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 500
            font.letterSpacing: 0.8
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.22
            )
        }
    }

    component DetailRow: Item {
        id: detailRow

        required property string label

        default property alias control:
            controlHost.data

        Layout.fillWidth: true
        implicitHeight: 54

        StyledText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            text: detailRow.label

            color:
                Colours.palette.m3onSurface

            font.pointSize:
                Appearance.font.size.small
        }

        RowLayout {
            id: controlHost

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.15
            )
        }
    }
}
