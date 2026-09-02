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

float band(float distanceFromRing, float width)
{
    return 1.0 - smoothstep(
        width,
        width + 0.018,
        abs(distanceFromRing)
    );
}

float softBell(float x, float width)
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

    vec2 tangent =
        vec2(-radial.y, radial.x);

    float maxRadius =
        length(vec2(
            0.5 * aspectRatio,
            0.5
        ));

    // Travel far enough that even the third echo
    // completely exits the screen.
    float front =
        progress * (maxRadius + 0.52);

    // Much larger spacing than before.
    float pos0 = front;
    float pos1 = front - 0.17;
    float pos2 = front - 0.34;

    // Narrow visible bands so they don't blend together.
    float b0 = band(dist - pos0, 0.026);
    float b1 = band(dist - pos1, 0.025);
    float b2 = band(dist - pos2, 0.024);

    // Slightly wider envelopes only for the distortion.
    float d0 = softBell(dist - pos0, 0.055);
    float d1 = softBell(dist - pos1, 0.052);
    float d2 = softBell(dist - pos2, 0.048);

    float settle =
        1.0 - smoothstep(
            0.82,
            1.0,
            progress
        );

    // Push / pull / push.
    // Deliberately strong enough to read on a desktop.
    float radialWarp =
          d0 * 0.125
        - d1 * 0.085
        + d2 * 0.060;

    // Tiny rotational component stops it looking like
    // three simple circular magnifying glasses.
    float tangentWarp =
          d0 * 0.018
        - d1 * 0.012
        + d2 * 0.008;

    vec2 warpedP =
        p
        - radial * radialWarp * settle
        + tangent * tangentWarp * settle;

    warpedP.x /= aspectRatio;

    vec2 warped =
        clamp(
            warpedP + vec2(0.5),
            vec2(0.003),
            vec2(0.997)
        );

    vec4 colour =
        texture(source, warped);

    // Three independently visible highlights.
    float flash =
          b0 * 0.32
        + b1 * 0.22
        + b2 * 0.14;

    colour.rgb += vec3(flash * settle);

    // Each ripple band exposes the new wallpaper.
    // All three are kept strong enough to actually see.
    float rippleReveal =
        max(
            b0,
            max(
                b1 * 0.95,
                b2 * 0.90
            )
        );

    // Very faint wake only. We specifically don't want
    // another radial-filled circle.
    float wake =
        (
            1.0
            - smoothstep(
                front - 0.42,
                front - 0.36,
                dist
            )
        ) * 0.08;

    // Final settle happens late, after the echo rings
    // have had time to cross most of the screen.
    float finalFill =
        smoothstep(
            0.74,
            0.98,
            progress
        );

    float reveal =
        max(
            rippleReveal,
            max(
                wake,
                finalFill
            )
        );

    fragColor =
        vec4(
            colour.rgb,
            colour.a * reveal
        )
        * qt_Opacity;
}
