.pragma library

function noise(n) {
    const value = Math.sin(n * 12.9898 + 78.233) * 43758.5453;
    return value - Math.floor(value);
}

function starCount(width, height) {
    return Math.max(45, Math.min(220, Math.floor(width * height / 1500)));
}

function star(index, phase, width, height) {
    if (width < 40 || height < 40)
        return null;
    const x = 16 + noise(index + 901) * (width - 32);
    const y = 16 + noise(index + 1901) * (height - 32);
    const clearRadius = Math.min(65, width * 0.2, height * 0.2);
    if (Math.hypot(x - width / 2, y - height / 2) < clearRadius)
        return null;
    const seed = noise(index + 2901);
    return {
        x: x + Math.sin(phase * 0.03 + index) * 0.6,
        y: y + Math.cos(phase * 0.025 + index) * 0.6,
        alpha: 0.2 + seed * 0.36 + Math.sin(phase * 0.15 + index) * 0.08,
        cross: index % 31 === 0
    };
}

// One short meteor every ~14 seconds. It stays in the upper part of the box,
// so its trail does not run through the black hole's transparent center.
function meteor(phase, width, height) {
    const progress = ((phase % 10) - 2) / 0.6;
    if (progress <= 0 || progress >= 1 || width < 100 || height < 200)
        return null;
    return {
        x: width * (0.82 - progress * 0.5),
        y: height * 0.08 + progress * Math.min(85, height * 0.17),
        alpha: Math.sin(progress * Math.PI) * 0.85,
        dx: width * 0.5,
        dy: -Math.min(85, height * 0.17)
    };
}

function showDetails(width, height) {
    return width >= 240 && height >= 380;
}

// Project a lit sphere into a stippled surface, rather than tracing its edge.
// The fixed sample positions avoid shimmer; only the faint cloud bands turn.
var planetCount = 760;
var ringCount = 460;

function planetPoint(index, phase) {
    const r = Math.sqrt((index + 0.5) / planetCount);
    const angle = index * 2.399963;
    const x = Math.cos(angle) * r;
    const y = Math.sin(angle) * r;
    const z = Math.sqrt(Math.max(0, 1 - r * r));
    const light = Math.max(0, -x * 0.55 - y * 0.35 + z * 0.75);
    const bands = 0.8 + Math.sin(y * 22 + Math.sin(Math.atan2(x, z) * 3 + phase * 0.07)) * 0.2;
    if (noise(index + 8201) > light * 0.92)
        return null;
    return { x: x, y: y, alpha: (0.12 + light * 0.72) * bands, size: 0.9 };
}

function ringPoint(index, phase) {
    const seed = noise(index + 9201);
    const radius = 1.4 + seed * 0.75;
    const angle = noise(index + 10201) * Math.PI * 2 + phase * 0.035;
    const x = Math.cos(angle) * radius;
    const y = Math.sin(angle) * radius * 0.28;
    if (y < 0 && Math.hypot(x, y) < 1.03)
        return null;
    const tilt = -0.34;
    const density = Math.max(0, 1 - Math.abs(radius - 1.75) / 0.4);
    return {
        x: x * Math.cos(tilt) - y * Math.sin(tilt),
        y: x * Math.sin(tilt) + y * Math.cos(tilt),
        alpha: 0.1 + density * (0.25 + noise(index + 11201) * 0.25),
        size: 0.8
    };
}
