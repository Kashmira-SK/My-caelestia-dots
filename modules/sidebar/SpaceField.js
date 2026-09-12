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
