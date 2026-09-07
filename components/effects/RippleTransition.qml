import QtQuick

ShaderEffect {
    required property Item fromSource
    required property Item toSource

    property real progress: 0
    property real amplitude: 100
    property real speed: 50

    fragmentShader:
        Qt.resolvedUrl(
            "../../assets/shaders/ripple-v2.frag.qsb"
        )
}
