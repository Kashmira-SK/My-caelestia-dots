#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    float progress;
    float amplitude;
    float speed;
};

layout(binding = 1) uniform sampler2D fromSource;
layout(binding = 2) uniform sampler2D toSource;

void main()
{
    vec2 uv = qt_TexCoord0;

    vec2 dir = uv - vec2(0.5);
    float dist = length(dir);

    vec2 offset =
        dir
        * (
            sin(
                progress * dist * amplitude
                - progress * speed
            )
            + 0.5
        )
        / 30.0
        * progress;

    vec2 displacedUv =
        clamp(
            uv + offset,
            vec2(0.001),
            vec2(0.999)
        );

    vec4 oldColour =
        texture(fromSource, displacedUv);

    vec4 newColour =
        texture(toSource, uv);

    float blend =
        smoothstep(
            0.2,
            1.0,
            progress
        );

    fragColor =
        mix(
            oldColour,
            newColour,
            blend
        )
        * qt_Opacity;
}
