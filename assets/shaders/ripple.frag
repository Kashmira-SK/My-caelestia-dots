#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    float progress;
    float aspectRatio;
};

layout(binding = 1) uniform sampler2D source;

float bell(float x, float width)
{
    float n = x / width;
    return exp(-(n * n));
}

void main()
{
    vec2 uv = qt_TexCoord0;

    vec2 p = uv - vec2(0.5);
    p.x *= aspectRatio;

    float dist = length(p);

    vec2 radial =
        dist > 0.0001
            ? p / dist
            : vec2(0.0);

    float maxRadius =
        length(vec2(
            0.5 * aspectRatio,
            0.5
        ));

    // Main wave moves beyond the screen edge so the
    // distortion has time to disappear naturally.
    float front =
        progress * (maxRadius + 0.30);

    // Main ripple + one delayed aftershock.
    float mainPos = front;
    float echoPos = front - 0.16;

    float mainEnvelope =
        bell(dist - mainPos, 0.050);

    float echoEnvelope =
        bell(dist - echoPos, 0.060);

    // Actual water-like oscillation inside each wave.
    float mainWave =
        sin((dist - mainPos) * 86.0)
        * mainEnvelope;

    float echoWave =
        sin((dist - echoPos) * 72.0)
        * echoEnvelope;

    // Fade distortion only near the very end.
    float settle =
        1.0 - smoothstep(
            0.78,
            1.0,
            progress
        );

    // Strong main ripple, much weaker echo.
    // Radial movement only: no tangential/spiral warp.
    float displacement =
        (
              mainWave * 0.115
            + echoWave * 0.045
        )
        * settle;

    vec2 warpedP =
        p - radial * displacement;

    warpedP.x /= aspectRatio;

    vec2 warped =
        clamp(
            warpedP + vec2(0.5),
            vec2(0.003),
            vec2(0.997)
        );

    vec4 colour =
        texture(source, warped);

    // Small highlight on the wavefronts.
    // Main ripple is visible; echo is intentionally subtle.
    float highlight =
        (
              mainEnvelope * 0.12
            + echoEnvelope * 0.045
        )
        * settle;

    colour.rgb += vec3(highlight);

    // Reveal follows the main wave, but with a softer edge
    // so it doesn't look identical to the regular radial effect.
    float reveal =
        1.0 - smoothstep(
            front - 0.095,
            front + 0.025,
            dist
        );

    fragColor =
        vec4(
            colour.rgb,
            colour.a * reveal
        )
        * qt_Opacity;
}
