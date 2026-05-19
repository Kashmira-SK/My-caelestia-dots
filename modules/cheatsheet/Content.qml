import qs.components
import qs.services
import qs.config
import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io

Item {
    id: root

    readonly property string dataPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/quickshell/caelestia/modules/cheatsheet/data.json"
    readonly property int pad: Appearance.padding.large

    property var cheatData: ({ keybinds: [], tools: [], aliases: [], repos: [] })
    property bool isSaving: false
    property int activeTab: 0

    function save() {
        isSaving = true
        saveProcess.environment = { "DATA": JSON.stringify(cheatData, null, 2) }
        saveProcess.running = true
    }

    FileView {
        id: fileView
        path: root.dataPath
        onTextChanged: {
            if (root.isSaving) return
            const t = fileView.text()
            if (!t || t.trim() === "") return
            try { root.cheatData = JSON.parse(t) }
            catch(e) { console.warn("[Cheatsheet] parse error:", e) }
        }
    }

    Process {
        id: saveProcess
        command: ["bash", "-c", "printf '%s' \"$DATA\" > '" + root.dataPath + "'"]
        onExited: root.isSaving = false
    }

    Component.onCompleted: fileView.reload()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.pad
        spacing: Appearance.spacing.normal

        //Tab Bar 
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            Repeater {
                model: ["keybinds", "tools", "aliases", "repos"]

                delegate: StyledRect {
                    required property string modelData
                    required property int index
                    readonly property bool active: root.activeTab === index

                    radius: Appearance.rounding.full
                    color: active ? Colours.palette.m3secondaryContainer : "transparent"
                    implicitWidth: tabLabel.implicitWidth + Appearance.padding.larger * 2
                    implicitHeight: tabLabel.implicitHeight + Appearance.padding.normal * 2

                    StateLayer {
                        color: active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                        function onClicked() { root.activeTab = index }
                    }

                    StyledText {
                        id: tabLabel
                        anchors.centerIn: parent
                        text: modelData
                        color: active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                        font.capitalization: Font.Capitalize
                    }

                    Behavior on color { Anim {} }
                }
            }

            Item { Layout.fillWidth: true }

            StyledText {
                visible: root.isSaving
                text: "saving…"
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colours.tPalette.m3outlineVariant
        }

        // Tab Contetnt
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            KeybindsView {
                anchors.fill: parent
                visible: root.activeTab === 0
                keybinds: root.cheatData.keybinds ?? []
                onRequestUpdate: function(kb) {
                    const d = JSON.parse(JSON.stringify(root.cheatData))
                    d.keybinds = kb
                    root.cheatData = d
                    root.save()
                }
            }

            ToolsView {
                anchors.fill: parent
                visible: root.activeTab === 1
                tools: root.cheatData.tools ?? []
                onRequestUpdate: function(t) {
                    const d = JSON.parse(JSON.stringify(root.cheatData))
                    d.tools = t
                    root.cheatData = d
                    root.save()
                }
            }

            AliasesView {
                anchors.fill: parent
                visible: root.activeTab === 2
                aliases: root.cheatData.aliases ?? []
                onRequestUpdate: function(a) {
                    const d = JSON.parse(JSON.stringify(root.cheatData))
                    d.aliases = a
                    root.cheatData = d
                    root.save()
                }
            }

            ReposView {
                anchors.fill: parent
                visible: root.activeTab === 3
                repos: root.cheatData.repos ?? []
                onRequestUpdate: function(r) {
                    const d = JSON.parse(JSON.stringify(root.cheatData))
                    d.repos = r
                    root.cheatData = d
                    root.save()
                }
            }
        }
    }

    //Shared TextField background component
    component FieldBg: StyledRect {
        radius: Appearance.rounding.small
        color: Colours.tPalette.m3surfaceContainerHighest
    }

    //KeybindsView
    component KeybindsView: Item {
        property var keybinds: []
        signal requestUpdate(var newData)

        property int editCatIdx: -1
        property int editBindIdx: -1
        property string editKeys: ""
        property string editAction: ""
        property int addingToCat: -1
        property string newKeys: ""
        property string newAction: ""
        property bool addingCat: false
        property string newCatName: ""

        ScrollView {
            anchors.fill: parent
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
                width: parent.width
                spacing: Appearance.spacing.large

                Repeater {
                    model: keybinds

                    Column {
                        required property var modelData
                        required property int index
                        readonly property int ci: index

                        width: parent.width
                        spacing: 2

                        RowLayout {
                            width: parent.width
                            height: 30

                            StyledText {
                                text: modelData.category
                                font.pointSize: Appearance.font.size.small
                                font.weight: Font.Medium
                                font.capitalization: Font.AllUppercase
                                color: Colours.palette.m3primary
                                Layout.fillWidth: true
                            }

                            StyledText {
                                text: "add"
                                font.family: Appearance.font.family.material
                                font.pointSize: Appearance.font.size.normal
                                color: Colours.palette.m3primary
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { addingToCat = ci; newKeys = ""; newAction = "" }
                                }
                            }

                            Item { width: Appearance.spacing.small }

                            StyledText {
                                text: "delete"
                                font.family: Appearance.font.family.material
                                font.pointSize: Appearance.font.size.normal
                                color: Colours.palette.m3error
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: requestUpdate(keybinds.filter((_, i) => i !== ci))
                                }
                            }
                        }

                        Repeater {
                            model: modelData.binds

                            Item {
                                required property var modelData
                                required property int index
                                readonly property int bi: index
                                readonly property bool isEditing: editCatIdx === ci && editBindIdx === bi

                                width: parent.width
                                height: bindRow.implicitHeight + Appearance.padding.small * 2

                                StyledRect {
                                    anchors.fill: parent
                                    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, bi % 2 === 0 ? 0.4 : 0.6)
                                    radius: Appearance.rounding.small
                                }

                                RowLayout {
                                    id: bindRow
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: Appearance.padding.normal
                                    spacing: Appearance.spacing.normal

                                    StyledText {
                                        visible: !isEditing
                                        text: modelData.keys
                                        font.family: Appearance.font.family.mono
                                        font.pointSize: Appearance.font.size.small
                                        color: Colours.palette.m3secondary
                                        Layout.preferredWidth: 160
                                        elide: Text.ElideRight
                                    }
                                    StyledText {
                                        visible: !isEditing
                                        text: modelData.action
                                        font.pointSize: Appearance.font.size.small
                                        color: Colours.palette.m3onSurface
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    TextField {
                                        visible: isEditing
                                        text: isEditing ? editKeys : ""
                                        placeholderText: "Super+Key"
                                        Layout.preferredWidth: 160
                                        font.family: Appearance.font.family.mono
                                        font.pointSize: Appearance.font.size.small
                                        color: Colours.palette.m3onSurface
                                        onTextEdited: editKeys = text
                                        background: FieldBg {}
                                    }
                                    TextField {
                                        visible: isEditing
                                        text: isEditing ? editAction : ""
                                        placeholderText: "action"
                                        Layout.fillWidth: true
                                        font.pointSize: Appearance.font.size.small
                                        color: Colours.palette.m3onSurface
                                        onTextEdited: editAction = text
                                        background: FieldBg {}
                                    }

                                    StyledText {
                                        visible: isEditing
                                        text: "check"
                                        font.family: Appearance.font.family.material
                                        font.pointSize: Appearance.font.size.normal
                                        color: Colours.palette.m3primary
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                const kb = JSON.parse(JSON.stringify(keybinds))
                                                kb[editCatIdx].binds[editBindIdx] = { keys: editKeys, action: editAction }
                                                requestUpdate(kb)
                                                editCatIdx = -1; editBindIdx = -1
                                            }
                                        }
                                    }
                                    StyledText {
                                        visible: !isEditing
                                        text: "edit"
                                        font.family: Appearance.font.family.material
                                        font.pointSize: Appearance.font.size.normal
                                        color: Colours.palette.m3onSurfaceVariant
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                editCatIdx = ci; editBindIdx = bi
                                                editKeys = modelData.keys; editAction = modelData.action
                                            }
                                        }
                                    }
                                    StyledText {
                                        text: "delete"
                                        font.family: Appearance.font.family.material
                                        font.pointSize: Appearance.font.size.normal
                                        color: Colours.palette.m3error
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                const kb = JSON.parse(JSON.stringify(keybinds))
                                                kb[ci].binds.splice(bi, 1)
                                                requestUpdate(kb)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // add bind form
                        RowLayout {
                            visible: addingToCat === ci
                            width: parent.width
                            spacing: Appearance.spacing.small

                            TextField {
                                id: newKeysField
                                placeholderText: "Super+Key"
                                Layout.preferredWidth: 160
                                font.family: Appearance.font.family.mono
                                font.pointSize: Appearance.font.size.small
                                color: Colours.palette.m3onSurface
                                onTextEdited: newKeys = text
                                background: FieldBg {}
                            }
                            TextField {
                                id: newActionField
                                placeholderText: "action description"
                                Layout.fillWidth: true
                                font.pointSize: Appearance.font.size.small
                                color: Colours.palette.m3onSurface
                                onTextEdited: newAction = text
                                background: FieldBg {}
                            }
                            StyledText {
                                text: "check"
                                font.family: Appearance.font.family.material
                                font.pointSize: Appearance.font.size.normal
                                color: Colours.palette.m3primary
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!newKeys || !newAction) return
                                        const kb = JSON.parse(JSON.stringify(keybinds))
                                        kb[ci].binds.push({ keys: newKeys, action: newAction })
                                        requestUpdate(kb)
                                        addingToCat = -1
                                        newKeysField.text = ""; newActionField.text = ""
                                    }
                                }
                            }
                            StyledText {
                                text: "close"
                                font.family: Appearance.font.family.material
                                font.pointSize: Appearance.font.size.normal
                                color: Colours.palette.m3onSurfaceVariant
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: addingToCat = -1
                                }
                            }
                        }
                    }
                }

                // add category form
                RowLayout {
                    visible: addingCat
                    width: parent.width
                    spacing: Appearance.spacing.small

                    TextField {
                        id: catNameField
                        placeholderText: "category name"
                        Layout.fillWidth: true
                        font.pointSize: Appearance.font.size.small
                        color: Colours.palette.m3onSurface
                        onTextEdited: newCatName = text
                        background: FieldBg {}
                    }
                    StyledText {
                        text: "check"
                        font.family: Appearance.font.family.material
                        font.pointSize: Appearance.font.size.normal
                        color: Colours.palette.m3primary
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!newCatName) return
                                const kb = JSON.parse(JSON.stringify(keybinds))
                                kb.push({ category: newCatName, binds: [] })
                                requestUpdate(kb)
                                addingCat = false
                                catNameField.text = ""
                            }
                        }
                    }
                    StyledText {
                        text: "close"
                        font.family: Appearance.font.family.material
                        font.pointSize: Appearance.font.size.normal
                        color: Colours.palette.m3onSurfaceVariant
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: addingCat = false
                        }
                    }
                }

                StyledText {
                    visible: !addingCat
                    text: "+ add category"
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3primary
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { addingCat = true; newCatName = "" }
                    }
                }
            }
        }
    }

    //ToolsView
    component ToolsView: Item {
        property var tools: []
        signal requestUpdate(var newData)

        property int editIdx: -1
        property string editCmd: ""
        property string editDesc: ""
        property string editExample: ""
        property bool adding: false
        property string newCmd: ""
        property string newDesc: ""
        property string newExample: ""

        ScrollView {
            anchors.fill: parent
            clip: true

            Column {
                width: parent.width
                spacing: 2

                RowLayout {
                    width: parent.width
                    height: 28
                    StyledText { text: "command"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 140 }
                    StyledText { text: "description"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.fillWidth: true }
                    StyledText { text: "example"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 200 }
                    Item { width: 72 }
                }

                Repeater {
                    model: tools

                    Item {
                        required property var modelData
                        required property int index
                        readonly property bool isEditing: editIdx === index

                        width: parent.width
                        height: tRow.implicitHeight + Appearance.padding.small * 2

                        StyledRect {
                            anchors.fill: parent
                            color: Qt.alpha(Colours.tPalette.m3surfaceContainer, index % 2 === 0 ? 0.4 : 0.6)
                            radius: Appearance.rounding.small
                        }

                        RowLayout {
                            id: tRow
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left; anchors.right: parent.right
                            anchors.margins: Appearance.padding.small
                            spacing: Appearance.spacing.small

                            StyledText { visible: !isEditing; text: modelData.cmd; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3secondary; Layout.preferredWidth: 140; elide: Text.ElideRight }
                            StyledText { visible: !isEditing; text: modelData.desc; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; Layout.fillWidth: true; elide: Text.ElideRight }
                            StyledText { visible: !isEditing; text: modelData.example; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurfaceVariant; Layout.preferredWidth: 200; elide: Text.ElideRight }

                            TextField { visible: isEditing; text: isEditing ? editCmd : ""; Layout.preferredWidth: 140; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editCmd = text; background: FieldBg {} }
                            TextField { visible: isEditing; text: isEditing ? editDesc : ""; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editDesc = text; background: FieldBg {} }
                            TextField { visible: isEditing; text: isEditing ? editExample : ""; Layout.preferredWidth: 200; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editExample = text; background: FieldBg {} }

                            StyledText { visible: isEditing; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { const t = tools.slice(); t[editIdx] = { cmd: editCmd, desc: editDesc, example: editExample }; requestUpdate(t); editIdx = -1 }
                                }
                            }
                            StyledText { visible: !isEditing; text: "edit"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { editIdx = index; editCmd = modelData.cmd; editDesc = modelData.desc; editExample = modelData.example }
                                }
                            }
                            StyledText { text: "delete"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3error
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: requestUpdate(tools.filter((_, i) => i !== index))
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    visible: adding; width: parent.width; spacing: Appearance.spacing.small
                    TextField { id: tAddCmd; placeholderText: "command"; Layout.preferredWidth: 140; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: newCmd = text; background: FieldBg {} }
                    TextField { id: tAddDesc; placeholderText: "description"; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: newDesc = text; background: FieldBg {} }
                    TextField { id: tAddEx; placeholderText: "example"; Layout.preferredWidth: 200; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: newExample = text; background: FieldBg {} }
                    StyledText { text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!newCmd) return
                                const t = tools.slice(); t.push({ cmd: newCmd, desc: newDesc, example: newExample }); requestUpdate(t)
                                adding = false; tAddCmd.text = ""; tAddDesc.text = ""; tAddEx.text = ""
                            }
                        }
                    }
                    StyledText { text: "close"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: adding = false }
                    }
                }

                StyledText { visible: !adding; text: "+ add tool"; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3primary
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: adding = true }
                }
            }
        }
    }

    //AliasesView
    component AliasesView: Item {
        property var aliases: []
        signal requestUpdate(var newData)

        property int editIdx: -1
        property string editAlias: ""
        property string editCmd: ""
        property bool adding: false
        property string newAlias: ""
        property string newCmd: ""

        ScrollView {
            anchors.fill: parent
            clip: true

            Column {
                width: parent.width
                spacing: 2

                RowLayout {
                    width: parent.width; height: 28
                    StyledText { text: "alias"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 160 }
                    StyledText { text: "command"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.fillWidth: true }
                    Item { width: 72 }
                }

                Repeater {
                    model: aliases

                    Item {
                        required property var modelData
                        required property int index
                        readonly property bool isEditing: editIdx === index

                        width: parent.width
                        height: aRow.implicitHeight + Appearance.padding.small * 2

                        StyledRect {
                            anchors.fill: parent
                            color: Qt.alpha(Colours.tPalette.m3surfaceContainer, index % 2 === 0 ? 0.4 : 0.6)
                            radius: Appearance.rounding.small
                        }

                        RowLayout {
                            id: aRow
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left; anchors.right: parent.right
                            anchors.margins: Appearance.padding.small
                            spacing: Appearance.spacing.small

                            StyledText { visible: !isEditing; text: modelData.alias; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3secondary; Layout.preferredWidth: 160; elide: Text.ElideRight }
                            StyledText { visible: !isEditing; text: modelData.cmd; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; Layout.fillWidth: true; elide: Text.ElideRight }

                            TextField { visible: isEditing; text: isEditing ? editAlias : ""; Layout.preferredWidth: 160; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editAlias = text; background: FieldBg {} }
                            TextField { visible: isEditing; text: isEditing ? editCmd : ""; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editCmd = text; background: FieldBg {} }

                            StyledText { visible: isEditing; text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { const a = aliases.slice(); a[editIdx] = { alias: editAlias, cmd: editCmd }; requestUpdate(a); editIdx = -1 }
                                }
                            }
                            StyledText { visible: !isEditing; text: "edit"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { editIdx = index; editAlias = modelData.alias; editCmd = modelData.cmd }
                                }
                            }
                            StyledText { text: "delete"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3error
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: requestUpdate(aliases.filter((_, i) => i !== index))
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    visible: adding; width: parent.width; spacing: Appearance.spacing.small
                    TextField { id: aAddAlias; placeholderText: "alias"; Layout.preferredWidth: 160; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: newAlias = text; background: FieldBg {} }
                    TextField { id: aAddCmd; placeholderText: "command"; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: newCmd = text; background: FieldBg {} }
                    StyledText { text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!newAlias) return
                                const a = aliases.slice(); a.push({ alias: newAlias, cmd: newCmd }); requestUpdate(a)
                                adding = false; aAddAlias.text = ""; aAddCmd.text = ""
                            }
                        }
                    }
                    StyledText { text: "close"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: adding = false }
                    }
                }

                StyledText { visible: !adding; text: "+ add alias"; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3primary
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: adding = true }
                }
            }
        }
    }

    //ReposView
    component ReposView: Item {
        property var repos: []
        signal requestUpdate(var newData)

        property int editIdx: -1
        property string editName: ""
        property string editPath: ""
        property string editRemote: ""
        property string editDesc: ""
        property bool adding: false
        property string newName: ""
        property string newPath: ""
        property string newRemote: ""
        property string newDesc: ""

        ScrollView {
            anchors.fill: parent
            clip: true

            Column {
                width: parent.width
                spacing: 2

                RowLayout {
                    width: parent.width; height: 28
                    StyledText { text: "name"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 160 }
                    StyledText { text: "path"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.preferredWidth: 200 }
                    StyledText { text: "description"; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium; color: Colours.palette.m3outline; Layout.fillWidth: true }
                    Item { width: 72 }
                }

                Repeater {
                    model: repos

                    Item {
                        required property var modelData
                        required property int index
                        readonly property bool isEditing: editIdx === index

                        width: parent.width
                        implicitHeight: isEditing
                            ? rEditCol.implicitHeight + Appearance.padding.normal * 2
                            : rRow.implicitHeight + Appearance.padding.small * 2

                        StyledRect {
                            anchors.fill: parent
                            color: Qt.alpha(Colours.tPalette.m3surfaceContainer, index % 2 === 0 ? 0.4 : 0.6)
                            radius: Appearance.rounding.small
                        }

                        RowLayout {
                            id: rRow
                            visible: !isEditing
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left; anchors.right: parent.right
                            anchors.margins: Appearance.padding.small
                            spacing: Appearance.spacing.small

                            StyledText { text: modelData.name; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3secondary; Layout.preferredWidth: 160; elide: Text.ElideRight }
                            StyledText { text: modelData.path; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; Layout.preferredWidth: 200; elide: Text.ElideRight }
                            StyledText { text: modelData.desc; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurfaceVariant; Layout.fillWidth: true; elide: Text.ElideRight }

                            StyledText { text: "edit"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { editIdx = index; editName = modelData.name; editPath = modelData.path; editRemote = modelData.remote ?? ""; editDesc = modelData.desc }
                                }
                            }
                            StyledText { text: "delete"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3error
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: requestUpdate(repos.filter((_, i) => i !== index))
                                }
                            }
                        }

                        Column {
                            id: rEditCol
                            visible: isEditing
                            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                            anchors.margins: Appearance.padding.normal
                            spacing: Appearance.spacing.small

                            RowLayout {
                                width: parent.width; spacing: Appearance.spacing.small
                                TextField { placeholderText: "name"; text: isEditing ? editName : ""; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editName = text; background: FieldBg {} }
                                TextField { placeholderText: "path"; text: isEditing ? editPath : ""; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editPath = text; background: FieldBg {} }
                            }
                            RowLayout {
                                width: parent.width; spacing: Appearance.spacing.small
                                TextField { placeholderText: "remote URL"; text: isEditing ? editRemote : ""; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editRemote = text; background: FieldBg {} }
                                TextField { placeholderText: "description"; text: isEditing ? editDesc : ""; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: editDesc = text; background: FieldBg {} }
                                StyledText { text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            const r = repos.slice()
                                            r[editIdx] = { name: editName, path: editPath, remote: editRemote, desc: editDesc }
                                            requestUpdate(r); editIdx = -1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    visible: adding; width: parent.width; spacing: Appearance.spacing.small
                    RowLayout {
                        width: parent.width; spacing: Appearance.spacing.small
                        TextField { id: rAddName; placeholderText: "name"; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: newName = text; background: FieldBg {} }
                        TextField { id: rAddPath; placeholderText: "path"; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: newPath = text; background: FieldBg {} }
                    }
                    RowLayout {
                        width: parent.width; spacing: Appearance.spacing.small
                        TextField { id: rAddRemote; placeholderText: "remote URL"; Layout.fillWidth: true; font.family: Appearance.font.family.mono; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: newRemote = text; background: FieldBg {} }
                        TextField { id: rAddDesc; placeholderText: "description"; Layout.fillWidth: true; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3onSurface; onTextEdited: newDesc = text; background: FieldBg {} }
                        StyledText { text: "check"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3primary
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!newName) return
                                    const r = repos.slice(); r.push({ name: newName, path: newPath, remote: newRemote, desc: newDesc }); requestUpdate(r)
                                    adding = false; rAddName.text = ""; rAddPath.text = ""; rAddRemote.text = ""; rAddDesc.text = ""
                                }
                            }
                        }
                        StyledText { text: "close"; font.family: Appearance.font.family.material; font.pointSize: Appearance.font.size.normal; color: Colours.palette.m3onSurfaceVariant
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: adding = false }
                        }
                    }
                }

                StyledText { visible: !adding; text: "+ add repo"; font.pointSize: Appearance.font.size.small; color: Colours.palette.m3primary
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: adding = true }
                }
            }
        }
    }
}
