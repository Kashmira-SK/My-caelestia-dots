import QtQuick

Item {
    id: root

    property real pairSpacing: 20
    property real centerMargin: 14
    property alias upperContent: upperGroup.data
    property alias lowerContent: lowerGroup.data
    property alias centerContent: centerArea.data

    Column {
        id: upperGroup
        objectName: "upperPowerGroup"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: root.pairSpacing
    }

    Column {
        id: lowerGroup
        objectName: "lowerPowerGroup"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: root.pairSpacing
    }

    Item {
        id: centerArea
        objectName: "powerRailCenter"
        anchors.top: upperGroup.bottom
        anchors.bottom: lowerGroup.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: root.centerMargin
        anchors.bottomMargin: root.centerMargin
        clip: true
    }
}
