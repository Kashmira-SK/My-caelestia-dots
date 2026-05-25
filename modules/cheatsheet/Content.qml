pragma ComponentBehavior: Bound

import "../controlcenter"
import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io

Item {
    id: root
    required property Session session
    anchors.fill: parent

    readonly property string dataPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/quickshell/caelestia/modules/cheatsheet/data.json"
    property var tabs: []
    property bool isSaving: false
    property string activeTab: ""

    function save() {
        isSaving = true
        saveProcess.environment = { "DATA": JSON.stringify({ tabs: root.tabs }, null, 2) }
        saveProcess.running = true
    }

    function activeTabData(): var {
        for (let i = 0; i < tabs.length; i++)
            if (tabs[i].id === activeTab) return tabs[i]
        return null
    }

    FileView {
        id: fileView
        path: root.dataPath
        onTextChanged: {
            if (root.isSaving) return
            const t = fileView.text()
            if (!t || t.trim() === "") return
            try {
                const parsed = JSON.parse(t)
                root.tabs = parsed.tabs ?? []
                if (root.activeTab === "" && root.tabs.length > 0)
                    root.activeTab = root.tabs[0].id
            } catch(e) { console.warn("[Cheatsheet] parse error:", e) }
        }
    }

    Process {
        id: saveProcess
        command: ["bash", "-c", "printf '%s' \"$DATA\" > '" + root.dataPath + "'"]
        onExited: root.isSaving = false
    }

    Component.onCompleted: fileView.reload()

    // ── layout ────────────────────────────────────────────────────────────────

    RowLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.normal
        spacing: Appearance.padding.normal

        // ── left rail ─────────────────────────────────────────────────────────
        StyledRect {
            Layout.preferredWidth: 150
            Layout.fillHeight: true
            radius: Appearance.rounding.normal
            color: Colours.tPalette.m3surfaceContainer

            Flickable {
                id: leftFlick
                anchors.fill: parent
                anchors.margins: Appearance.padding.normal
                flickableDirection: Flickable.VerticalFlick
                contentHeight: leftCol.implicitHeight
                clip: true

                ColumnLayout {
                    id: leftCol
                    width: leftFlick.width
                    spacing: 2

                    StyledText {
                        text: "Cheatsheet"
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 500
                        color: Colours.palette.m3onSurface
                        Layout.bottomMargin: Appearance.spacing.normal
                    }

                    Repeater {
                        model: root.tabs

                        NavEntry {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            label: modelData.label
                            tabId: modelData.id
                        }
                    }
                }
            }
        }

        // ── right content ─────────────────────────────────────────────────────
        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.normal
            color: Colours.tPalette.m3surfaceContainer

            Repeater {
                model: root.tabs

                Item {
                    required property var modelData
                    required property int index

                    anchors.fill: parent
                    visible: root.activeTab === modelData.id

                    ListSection {
                        anchors.fill: parent
                        visible: modelData.type === "list" || modelData.type === undefined
                        tabData: modelData
                        allTabs: root.tabs
                        onRequestUpdate: function(newTabs) { root.tabs = newTabs; root.save() }
                    }

                    ReposSection {
                        anchors.fill: parent
                        visible: modelData.type === "repos"
                        tabData: modelData
                        allTabs: root.tabs
                        onRequestUpdate: function(newTabs) { root.tabs = newTabs; root.save() }
                    }

                    ZshSection {
                        anchors.fill: parent
                        visible: modelData.type === "zsh"
                        tabData: modelData
                        allTabs: root.tabs
                        onRequestUpdate: function(newTabs) { root.tabs = newTabs; root.save() }
                    }

                    LinuxSection {
                        anchors.fill: parent
                        visible: modelData.type === "linux"
                        tabData: modelData
                        allTabs: root.tabs
                        onRequestUpdate: function(newTabs) { root.tabs = newTabs; root.save() }
                    }

                    KeybindsSection {
                        anchors.fill: parent
                        visible: modelData.type === "keybinds"
                        tabData: modelData
                        allTabs: root.tabs
                        onRequestUpdate: function(newTabs) { root.tabs = newTabs; root.save() }
                    }
                }
            }
        }
    }

    // ── NavEntry ──────────────────────────────────────────────────────────────

    component NavEntry: Item {
        property string label: ""
        property string tabId: ""
        readonly property bool active: root.activeTab === tabId
        implicitHeight: navBg.implicitHeight

        StyledRect {
            id: navBg
            anchors.left: parent.left
            anchors.right: parent.right
            radius: Appearance.rounding.full
            color: active ? Colours.palette.m3secondaryContainer : "transparent"
            implicitHeight: navLbl.implicitHeight + Appearance.padding.normal * 2

            StateLayer {
                color: active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                function onClicked() { root.activeTab = tabId }
            }

            StyledText {
                id: navLbl
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Appearance.padding.normal
                text: label
                font.pointSize: Appearance.font.size.small
                font.capitalization: Font.Capitalize
                color: active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            }

            Behavior on color { Anim {} }
        }
    }

    // ── FieldBg ───────────────────────────────────────────────────────────────

    component FieldBg: StyledRect {
        radius: Appearance.rounding.small
        color: Colours.tPalette.m3surfaceContainerHighest
    }

    // ── DataRow ───────────────────────────────────────────────────────────────

    component DataRow: Item {
        property int rowIndex: 0
        default property alias rowChildren: rowLayout.data
        implicitHeight: rowLayout.implicitHeight + Appearance.padding.normal * 2

        StyledRect {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Qt.alpha(Colours.tPalette.m3surfaceContainer, rowIndex % 2 === 0 ? 0.5 : 0.8)
        }

        RowLayout {
            id: rowLayout
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.normal
        }
    }

    // ── SectionHeader ─────────────────────────────────────────────────────────

    component SectionHeader: StyledText {
        font.pointSize: Appearance.font.size.small
        font.weight: Font.Medium
        font.capitalization: Font.AllUppercase
        color: Colours.palette.m3outline
        Layout.topMargin: Appearance.spacing.normal
        Layout.bottomMargin: Appearance.spacing.smaller
    }

    // ── ListSection (cli games, cli visual, cli tools, media, apps) ───────────

    component ListSection: Item {
        property var tabData: ({})
        property var allTabs: []
        signal requestSave()
        signal requestUpdate(var newTabs)

        property int editIdx: -1
        property string editCmd: ""
        property string editDesc: ""

        Flickable {
            id: lFlick
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            contentHeight: lCol.implicitHeight
            clip: true

            ColumnLayout {
                id: lCol
                width: lFlick.width
                spacing: Appearance.spacing.smaller

                StyledText {
                    text: tabData.label ?? ""
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                    font.capitalization: Font.Capitalize
                    Layout.bottomMargin: Appearance.spacing.small
                }

                RowLayout {
                    Layout.fillWidth: true
                    StyledText { text: "command"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 280 }
                    StyledText { text: "description"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.fillWidth: true }
                    Item { implicitWidth: 56 }
                }

                Repeater {
                    model: tabData.items ?? []

                    DataRow {
                        required property var modelData
                        required property int index
                        rowIndex: index
                        width: lCol.width

                        StyledText { visible: editIdx !== index; text: modelData.command; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3secondary; Layout.preferredWidth: 280; elide: Text.ElideRight }
                        StyledText { visible: editIdx !== index; text: modelData.description; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                        TextField { visible: editIdx === index; text: editIdx === index ? editCmd : ""; Layout.preferredWidth: 280; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editCmd = text; background: FieldBg {} }
                        TextField { visible: editIdx === index; text: editIdx === index ? editDesc : ""; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editDesc = text; background: FieldBg {} }

                        StyledText { visible: editIdx === index; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const t = JSON.parse(JSON.stringify(allTabs))
                                    const ti = t.findIndex(x => x.id === tabData.id)
                                    t[ti].items[editIdx] = { command: editCmd, description: editDesc }
                                    requestUpdate(t); editIdx = -1
                                }
                            }
                        }
                        StyledText { visible: editIdx !== index; text: "edit"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { editIdx = index; editCmd = modelData.command; editDesc = modelData.description }
                            }
                        }
                        StyledText { text: "delete"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3error
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const t = JSON.parse(JSON.stringify(allTabs))
                                    const ti = t.findIndex(x => x.id === tabData.id)
                                    t[ti].items.splice(index, 1)
                                    requestUpdate(t)
                                }
                            }
                        }
                    }
                }

                // add row
                RowLayout {
                    id: addListRow
                    property bool expanded: false
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledText { visible: !addListRow.expanded; text: "+ add entry"; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3primary
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addListRow.expanded = true }
                    }
                    TextField { id: lCmd; visible: addListRow.expanded; placeholderText: "command"; Layout.preferredWidth: 280; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                    TextField { id: lDesc; visible: addListRow.expanded; placeholderText: "description"; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                    StyledText { visible: addListRow.expanded; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!lCmd.text) return
                                const t = JSON.parse(JSON.stringify(allTabs))
                                const ti = t.findIndex(x => x.id === tabData.id)
                                t[ti].items.push({ command: lCmd.text, description: lDesc.text })
                                requestUpdate(t)
                                lCmd.text = ""; lDesc.text = ""; addListRow.expanded = false
                            }
                        }
                    }
                    StyledText { visible: addListRow.expanded; text: "close"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addListRow.expanded = false }
                    }
                }
            }
        }
    }

    // ── ReposSection ──────────────────────────────────────────────────────────

    component ReposSection: Item {
        property var tabData: ({})
        property var allTabs: []
        signal requestUpdate(var newTabs)

        property int editIdx: -1
        property string editName: ""
        property string editPath: ""
        property string editRemote: ""
        property string editDesc: ""

        Flickable {
            id: rFlick
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            contentHeight: rCol.implicitHeight
            clip: true

            ColumnLayout {
                id: rCol
                width: rFlick.width
                spacing: Appearance.spacing.smaller

                StyledText { text: "Repos"; font.pointSize: Appearance.font.size.large; font.weight: 500; Layout.bottomMargin: Appearance.spacing.small }

                RowLayout {
                    Layout.fillWidth: true
                    StyledText { text: "name"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 160 }
                    StyledText { text: "path"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 220 }
                    StyledText { text: "description"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.fillWidth: true }
                    Item { implicitWidth: 56 }
                }

                Repeater {
                    model: tabData.items ?? []

                    ColumnLayout {
                        required property var modelData
                        required property int index
                        width: rCol.width
                        spacing: 2

                        DataRow {
                            rowIndex: index
                            width: rCol.width

                            StyledText { visible: editIdx !== index; text: modelData.name; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3secondary; Layout.preferredWidth: 160; elide: Text.ElideRight }
                            StyledText { visible: editIdx !== index; text: modelData.path; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; Layout.preferredWidth: 220; elide: Text.ElideRight }
                            StyledText { visible: editIdx !== index; text: modelData.desc; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurfaceVariant; Layout.fillWidth: true; elide: Text.ElideRight }
                            TextField { visible: editIdx === index; text: editIdx === index ? editName : ""; Layout.preferredWidth: 160; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editName = text; background: FieldBg {} }
                            TextField { visible: editIdx === index; text: editIdx === index ? editPath : ""; Layout.preferredWidth: 220; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editPath = text; background: FieldBg {} }
                            TextField { visible: editIdx === index; text: editIdx === index ? editDesc : ""; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editDesc = text; background: FieldBg {} }

                            StyledText { visible: editIdx === index; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const t = JSON.parse(JSON.stringify(allTabs))
                                        const ti = t.findIndex(x => x.id === tabData.id)
                                        t[ti].items[editIdx] = { name: editName, path: editPath, remote: editRemote, desc: editDesc }
                                        requestUpdate(t); editIdx = -1
                                    }
                                }
                            }
                            StyledText { visible: editIdx !== index; text: "edit"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { editIdx = index; editName = modelData.name; editPath = modelData.path; editRemote = modelData.remote ?? ""; editDesc = modelData.desc }
                                }
                            }
                            StyledText { text: "delete"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3error
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const t = JSON.parse(JSON.stringify(allTabs))
                                        const ti = t.findIndex(x => x.id === tabData.id)
                                        t[ti].items.splice(index, 1)
                                        requestUpdate(t)
                                    }
                                }
                            }
                        }

                        RowLayout {
                            visible: editIdx === index
                            width: rCol.width
                            TextField { placeholderText: "remote URL"; text: editIdx === index ? editRemote : ""; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editRemote = text; background: FieldBg {} }
                        }
                    }
                }

                RowLayout {
                    id: addRepoRow
                    property bool expanded: false
                    Layout.fillWidth: true; spacing: Appearance.spacing.small

                    StyledText { visible: !addRepoRow.expanded; text: "+ add repo"; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3primary
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addRepoRow.expanded = true }
                    }

                    ColumnLayout {
                        visible: addRepoRow.expanded; Layout.fillWidth: true; spacing: Appearance.spacing.small
                        RowLayout {
                            spacing: Appearance.spacing.small
                            TextField { id: rn; placeholderText: "name"; Layout.preferredWidth: 160; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                            TextField { id: rp; placeholderText: "path"; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                        }
                        RowLayout {
                            spacing: Appearance.spacing.small
                            TextField { id: rr; placeholderText: "remote URL"; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                            TextField { id: rd; placeholderText: "description"; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                            StyledText { text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!rn.text) return
                                        const t = JSON.parse(JSON.stringify(allTabs))
                                        const ti = t.findIndex(x => x.id === tabData.id)
                                        t[ti].items.push({ name: rn.text, path: rp.text, remote: rr.text, desc: rd.text })
                                        requestUpdate(t)
                                        rn.text=""; rp.text=""; rr.text=""; rd.text=""; addRepoRow.expanded = false
                                    }
                                }
                            }
                            StyledText { text: "close"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addRepoRow.expanded = false }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── ZshSection ────────────────────────────────────────────────────────────

    component ZshSection: Item {
        property var tabData: ({})
        property var allTabs: []
        signal requestUpdate(var newTabs)

        property int editAliasIdx: -1
        property string editAlias: ""
        property string editCmd: ""
        property int editFnIdx: -1
        property string editFnName: ""
        property string editFnUsage: ""
        property string editFnDesc: ""

        Flickable {
            id: zFlick
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            contentHeight: zCol.implicitHeight
            clip: true

            ColumnLayout {
                id: zCol
                width: zFlick.width
                spacing: Appearance.spacing.smaller

                StyledText { text: "Zsh"; font.pointSize: Appearance.font.size.large; font.weight: 500; Layout.bottomMargin: Appearance.spacing.small }

                SectionHeader { text: "aliases" }

                RowLayout {
                    Layout.fillWidth: true
                    StyledText { text: "alias"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 140 }
                    StyledText { text: "command"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.fillWidth: true }
                    Item { implicitWidth: 56 }
                }

                Repeater {
                    model: tabData.aliases ?? []

                    DataRow {
                        required property var modelData
                        required property int index
                        rowIndex: index
                        width: zCol.width

                        StyledText { visible: editAliasIdx !== index; text: modelData.alias; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3secondary; Layout.preferredWidth: 140; elide: Text.ElideRight }
                        StyledText { visible: editAliasIdx !== index; text: modelData.cmd; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; Layout.fillWidth: true; elide: Text.ElideRight }
                        TextField { visible: editAliasIdx === index; text: editAliasIdx === index ? editAlias : ""; Layout.preferredWidth: 140; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editAlias = text; background: FieldBg {} }
                        TextField { visible: editAliasIdx === index; text: editAliasIdx === index ? editCmd : ""; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editCmd = text; background: FieldBg {} }

                        StyledText { visible: editAliasIdx === index; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const t = JSON.parse(JSON.stringify(allTabs))
                                    const ti = t.findIndex(x => x.id === tabData.id)
                                    t[ti].aliases[editAliasIdx] = { alias: editAlias, cmd: editCmd }
                                    requestUpdate(t); editAliasIdx = -1
                                }
                            }
                        }
                        StyledText { visible: editAliasIdx !== index; text: "edit"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { editAliasIdx = index; editAlias = modelData.alias; editCmd = modelData.cmd }
                            }
                        }
                        StyledText { text: "delete"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3error
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const t = JSON.parse(JSON.stringify(allTabs))
                                    const ti = t.findIndex(x => x.id === tabData.id)
                                    t[ti].aliases.splice(index, 1); requestUpdate(t)
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    id: addAliasRow; property bool expanded: false
                    Layout.fillWidth: true; spacing: Appearance.spacing.small
                    StyledText { visible: !addAliasRow.expanded; text: "+ add alias"; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3primary
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addAliasRow.expanded = true }
                    }
                    TextField { id: aaF; visible: addAliasRow.expanded; placeholderText: "alias"; Layout.preferredWidth: 140; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                    TextField { id: acF; visible: addAliasRow.expanded; placeholderText: "command"; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                    StyledText { visible: addAliasRow.expanded; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!aaF.text) return
                                const t = JSON.parse(JSON.stringify(allTabs))
                                const ti = t.findIndex(x => x.id === tabData.id)
                                t[ti].aliases.push({ alias: aaF.text, cmd: acF.text }); requestUpdate(t)
                                aaF.text = ""; acF.text = ""; addAliasRow.expanded = false
                            }
                        }
                    }
                    StyledText { visible: addAliasRow.expanded; text: "close"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addAliasRow.expanded = false }
                    }
                }

                SectionHeader { text: "functions"; Layout.topMargin: Appearance.spacing.large }

                RowLayout {
                    Layout.fillWidth: true
                    StyledText { text: "name"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 100 }
                    StyledText { text: "usage"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 200 }
                    StyledText { text: "description"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.fillWidth: true }
                    Item { implicitWidth: 56 }
                }

                Repeater {
                    model: tabData.functions ?? []

                    DataRow {
                        required property var modelData
                        required property int index
                        rowIndex: index
                        width: zCol.width

                        StyledText { visible: editFnIdx !== index; text: modelData.name; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3secondary; Layout.preferredWidth: 100; elide: Text.ElideRight }
                        StyledText { visible: editFnIdx !== index; text: modelData.usage; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; Layout.preferredWidth: 200; elide: Text.ElideRight }
                        StyledText { visible: editFnIdx !== index; text: modelData.desc; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurfaceVariant; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                        TextField { visible: editFnIdx === index; text: editFnIdx === index ? editFnName : ""; Layout.preferredWidth: 100; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editFnName = text; background: FieldBg {} }
                        TextField { visible: editFnIdx === index; text: editFnIdx === index ? editFnUsage : ""; Layout.preferredWidth: 200; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editFnUsage = text; background: FieldBg {} }
                        TextField { visible: editFnIdx === index; text: editFnIdx === index ? editFnDesc : ""; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editFnDesc = text; background: FieldBg {} }

                        StyledText { visible: editFnIdx === index; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const t = JSON.parse(JSON.stringify(allTabs))
                                    const ti = t.findIndex(x => x.id === tabData.id)
                                    t[ti].functions[editFnIdx] = { name: editFnName, usage: editFnUsage, desc: editFnDesc }
                                    requestUpdate(t); editFnIdx = -1
                                }
                            }
                        }
                        StyledText { visible: editFnIdx !== index; text: "edit"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { editFnIdx = index; editFnName = modelData.name; editFnUsage = modelData.usage; editFnDesc = modelData.desc }
                            }
                        }
                        StyledText { text: "delete"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3error
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const t = JSON.parse(JSON.stringify(allTabs))
                                    const ti = t.findIndex(x => x.id === tabData.id)
                                    t[ti].functions.splice(index, 1); requestUpdate(t)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── LinuxSection ──────────────────────────────────────────────────────────

    component LinuxSection: Item {
        property var tabData: ({})
        property var allTabs: []
        signal requestUpdate(var newTabs)

        property string activeCategory: ""
        property int editIdx: -1
        property string editCmd: ""
        property string editDesc: ""

        Component.onCompleted: {
            if (activeCategory === "" && tabData.categories && tabData.categories.length > 0)
                activeCategory = tabData.categories[0].category
        }

        RowLayout {
            anchors.fill: parent
            spacing: Appearance.padding.normal

            // sub-nav
            ColumnLayout {
                Layout.preferredWidth: 100
                Layout.fillWidth: false
                Layout.fillHeight: true
                spacing: 2

                Repeater {
                    model: tabData.categories ?? []

                    Item {
                        required property var modelData
                        required property int index
                        readonly property bool active: activeCategory === modelData.category
                        Layout.fillWidth: true
                        implicitHeight: subBg.implicitHeight

                        StyledRect {
                            id: subBg
                            anchors.left: parent.left; anchors.right: parent.right
                            radius: Appearance.rounding.full
                            color: parent.active ? Colours.palette.m3secondaryContainer : "transparent"
                            implicitHeight: subLbl.implicitHeight + Appearance.padding.normal * 2

                            StateLayer {
                                color: parent.parent.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                                function onClicked() { activeCategory = modelData.category; editIdx = -1 }
                            }

                            StyledText {
                                id: subLbl
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Appearance.padding.normal
                                text: modelData.category
                                font.pointSize: Appearance.font.size.small
                                font.capitalization: Font.Capitalize
                                color: parent.parent.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                            }

                            Behavior on color { Anim {} }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }

            // content for selected sub-category
            Flickable {
                id: linFlick
                Layout.fillWidth: true
                Layout.fillHeight: true
                flickableDirection: Flickable.VerticalFlick
                contentHeight: linCol.implicitHeight
                clip: true

                ColumnLayout {
                    id: linCol
                    width: linFlick.width
                    spacing: Appearance.spacing.smaller

                    Repeater {
                        model: tabData.categories ?? []

                        ColumnLayout {
                            required property var modelData
                            required property int index
                            visible: activeCategory === modelData.category
                            width: linCol.width
                            spacing: Appearance.spacing.smaller

                            RowLayout {
                                Layout.fillWidth: true
                                StyledText { text: "command"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 280 }
                                StyledText { text: "description"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.fillWidth: true }
                                Item { implicitWidth: 56 }
                            }

                            Repeater {
                                model: modelData.items ?? []

                                DataRow {
                                    required property var modelData
                                    required property int index
                                    readonly property int catIdx: parent.parent.index
                                    rowIndex: index
                                    width: linCol.width

                                    StyledText { visible: editIdx !== index; text: modelData.command; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3secondary; Layout.preferredWidth: 280; elide: Text.ElideRight }
                                    StyledText { visible: editIdx !== index; text: modelData.description; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                                    TextField { visible: editIdx === index; text: editIdx === index ? editCmd : ""; Layout.preferredWidth: 280; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editCmd = text; background: FieldBg {} }
                                    TextField { visible: editIdx === index; text: editIdx === index ? editDesc : ""; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editDesc = text; background: FieldBg {} }

                                    StyledText { visible: editIdx === index; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                const t = JSON.parse(JSON.stringify(allTabs))
                                                const ti = t.findIndex(x => x.id === tabData.id)
                                                t[ti].categories[catIdx].items[editIdx] = { command: editCmd, description: editDesc }
                                                requestUpdate(t); editIdx = -1
                                            }
                                        }
                                    }
                                    StyledText { visible: editIdx !== index; text: "edit"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: { editIdx = index; editCmd = modelData.command; editDesc = modelData.description }
                                        }
                                    }
                                    StyledText { text: "delete"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3error
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                const t = JSON.parse(JSON.stringify(allTabs))
                                                const ti = t.findIndex(x => x.id === tabData.id)
                                                t[ti].categories[catIdx].items.splice(index, 1); requestUpdate(t)
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                id: addLinRow; property bool expanded: false
                                Layout.fillWidth: true; spacing: Appearance.spacing.small
                                readonly property int myCatIdx: parent.index

                                StyledText { visible: !addLinRow.expanded; text: "+ add entry"; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3primary
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addLinRow.expanded = true }
                                }
                                TextField { id: lcF; visible: addLinRow.expanded; placeholderText: "command"; Layout.preferredWidth: 280; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                                TextField { id: ldF; visible: addLinRow.expanded; placeholderText: "description"; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                                StyledText { visible: addLinRow.expanded; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (!lcF.text) return
                                            const t = JSON.parse(JSON.stringify(allTabs))
                                            const ti = t.findIndex(x => x.id === tabData.id)
                                            t[ti].categories[addLinRow.myCatIdx].items.push({ command: lcF.text, description: ldF.text })
                                            requestUpdate(t); lcF.text = ""; ldF.text = ""; addLinRow.expanded = false
                                        }
                                    }
                                }
                                StyledText { visible: addLinRow.expanded; text: "close"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addLinRow.expanded = false }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── KeybindsSection ───────────────────────────────────────────────────────

    component KeybindsSection: Item {
        property var tabData: ({})
        property var allTabs: []
        signal requestUpdate(var newTabs)

        property string activeCategory: ""
        property int editIdx: -1
        property string editKeys: ""
        property string editAction: ""

        Component.onCompleted: {
            if (activeCategory === "" && tabData.categories && tabData.categories.length > 0)
                activeCategory = tabData.categories[0].category
        }

        RowLayout {
            anchors.fill: parent
            spacing: Appearance.padding.normal

            // sub-nav
            ColumnLayout {
                Layout.preferredWidth: 100
                Layout.fillWidth: false
                Layout.fillHeight: true
                spacing: 2

                Repeater {
                    model: tabData.categories ?? []

                    Item {
                        required property var modelData
                        required property int index
                        readonly property bool active: activeCategory === modelData.category
                        Layout.fillWidth: true
                        implicitHeight: ksubBg.implicitHeight

                        StyledRect {
                            id: ksubBg
                            anchors.left: parent.left; anchors.right: parent.right
                            radius: Appearance.rounding.full
                            color: parent.active ? Colours.palette.m3secondaryContainer : "transparent"
                            implicitHeight: ksubLbl.implicitHeight + Appearance.padding.normal * 2

                            StateLayer {
                                color: parent.parent.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                                function onClicked() { activeCategory = modelData.category; editIdx = -1 }
                            }

                            StyledText {
                                id: ksubLbl
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Appearance.padding.normal
                                text: modelData.category
                                font.pointSize: Appearance.font.size.small
                                font.capitalization: Font.Capitalize
                                color: parent.parent.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                            }

                            Behavior on color { Anim {} }
                        }
                    }
                }

                StyledText {
                    text: "+ category"
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3primary
                    topPadding: Appearance.spacing.small
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: addKbCatRow.expanded = true
                    }
                }

                RowLayout {
                    id: addKbCatRow
                    property bool expanded: false
                    visible: expanded
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.smaller

                    TextField { id: kbCatF; placeholderText: "name"; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {}
                        onAccepted: addKbCatRow.commit()
                    }
                    StyledText { text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addKbCatRow.commit() }
                    }

                    function commit() {
                        if (!kbCatF.text) return
                        const t = JSON.parse(JSON.stringify(allTabs))
                        const ti = t.findIndex(x => x.id === tabData.id)
                        t[ti].categories.push({ category: kbCatF.text, binds: [] })
                        requestUpdate(t)
                        activeCategory = kbCatF.text
                        kbCatF.text = ""; expanded = false
                    }
                }

                Item { Layout.fillHeight: true }
            }

            // binds content
            Flickable {
                id: kbFlick
                Layout.fillWidth: true
                Layout.fillHeight: true
                flickableDirection: Flickable.VerticalFlick
                contentHeight: kbCol.implicitHeight
                clip: true

                ColumnLayout {
                    id: kbCol
                    width: kbFlick.width
                    spacing: Appearance.spacing.smaller

                    Repeater {
                        model: tabData.categories ?? []

                        ColumnLayout {
                            required property var modelData
                            required property int index
                            visible: activeCategory === modelData.category
                            width: kbCol.width
                            spacing: Appearance.spacing.smaller

                            RowLayout {
                                Layout.fillWidth: true
                                StyledText { text: "keys"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 200 }
                                StyledText { text: "action"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.fillWidth: true }
                                Item { implicitWidth: 56 }
                            }

                            Repeater {
                                model: modelData.binds ?? []

                                DataRow {
                                    required property var modelData
                                    required property int index
                                    readonly property int catIdx: parent.parent.index
                                    rowIndex: index
                                    width: kbCol.width

                                    StyledText { visible: editIdx !== index; text: modelData.keys; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3secondary; Layout.preferredWidth: 200; elide: Text.ElideRight }
                                    StyledText { visible: editIdx !== index; text: modelData.action; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; Layout.fillWidth: true; elide: Text.ElideRight }
                                    TextField { visible: editIdx === index; text: editIdx === index ? editKeys : ""; Layout.preferredWidth: 200; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editKeys = text; background: FieldBg {} }
                                    TextField { visible: editIdx === index; text: editIdx === index ? editAction : ""; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editAction = text; background: FieldBg {} }

                                    StyledText { visible: editIdx === index; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                const t = JSON.parse(JSON.stringify(allTabs))
                                                const ti = t.findIndex(x => x.id === tabData.id)
                                                t[ti].categories[catIdx].binds[editIdx] = { keys: editKeys, action: editAction }
                                                requestUpdate(t); editIdx = -1
                                            }
                                        }
                                    }
                                    StyledText { visible: editIdx !== index; text: "edit"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: { editIdx = index; editKeys = modelData.keys; editAction = modelData.action }
                                        }
                                    }
                                    StyledText { text: "delete"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3error
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                const t = JSON.parse(JSON.stringify(allTabs))
                                                const ti = t.findIndex(x => x.id === tabData.id)
                                                t[ti].categories[catIdx].binds.splice(index, 1); requestUpdate(t)
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                id: addBindRow; property bool expanded: false
                                Layout.fillWidth: true; spacing: Appearance.spacing.small
                                readonly property int myCatIdx: parent.index

                                StyledText { visible: !addBindRow.expanded; text: "+ add bind"; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3primary
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addBindRow.expanded = true }
                                }
                                TextField { id: bkF; visible: addBindRow.expanded; placeholderText: "Super+Key"; Layout.preferredWidth: 200; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                                TextField { id: baF; visible: addBindRow.expanded; placeholderText: "action"; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; background: FieldBg {} }
                                StyledText { visible: addBindRow.expanded; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (!bkF.text || !baF.text) return
                                            const t = JSON.parse(JSON.stringify(allTabs))
                                            const ti = t.findIndex(x => x.id === tabData.id)
                                            t[ti].categories[addBindRow.myCatIdx].binds.push({ keys: bkF.text, action: baF.text })
                                            requestUpdate(t); bkF.text = ""; baF.text = ""; addBindRow.expanded = false
                                        }
                                    }
                                }
                                StyledText { visible: addBindRow.expanded; text: "close"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addBindRow.expanded = false }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
