import QtQuick

ShaderEffect {
    id: root

    required property Item source

    property real progress: 0
    property real aspectRatio: 1

    readonly property url shaderUrl:
        Qt.resolvedUrl("../../assets/shaders/ripple-v2.frag.qsb")

    fragmentShader: shaderUrl

    Component.onCompleted:
        console.log("[ripple] shader:", shaderUrl)
}
