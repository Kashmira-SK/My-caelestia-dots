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

// A broad saucer and raised canopy: no rocket nose, wings, or exhaust.
function makeUfo() {
    const dots = [];
    for (let row = 0; row < 17; row++) {
        for (let col = 0; col < 37; col++) {
            const x = (col - 18) * 1.2;
            const y = -12 + row * 1.2;
            const body = x * x / (22 * 22) + (y - 1) * (y - 1) / (5.3 * 5.3) < 1;
            const dome = y < -2 && x * x / 100 + (y + 2) * (y + 2) / 100 < 1;
            if (!body && !dome)
                continue;
            if (dome && Math.abs(x) < 5 && y > -8 && y < -4)
                continue;
            const grain = noise(row * 37 + col + 16001);
            if (grain < 0.18)
                continue;
            const rim = body && Math.abs(y) < 1.5;
            dots.push({ x: x, y: y, alpha: (rim ? 0.58 : 0.3) + grain * 0.25, size: 0.95 });
        }
    }
    return dots;
}

var ufoDots = makeUfo();
var ufoCount = ufoDots.length + 4;

function ufoPoint(index, phase) {
    const lamp = index >= ufoDots.length;
    const dot = lamp ? {
        x: -12 + (index - ufoDots.length) * 8,
        y: 5.6,
        alpha: 0.65 + Math.sin(phase * 1.4 + index) * 0.15,
        size: 1.6
    } : ufoDots[index];
    const bank = Math.sin(phase * 0.9) * 0.055;
    return {
        x: dot.x * Math.cos(bank) - dot.y * Math.sin(bank),
        y: dot.x * Math.sin(bank) + dot.y * Math.cos(bank),
        alpha: dot.alpha,
        size: dot.size
    };
}

// At 0.7 phase units/second: first visit after four seconds, a six-second
// crossing, then eighteen seconds absent. Subsequent visits alternate sides.
function ufoFlight(phase, width, height) {
    if (!showDetails(width, height))
        return null;
    const cycle = Math.floor(phase / 16.8);
    const local = phase - cycle * 16.8;
    if (local < 2.8 || local > 7)
        return null;
    const progress = (local - 2.8) / 4.2;
    const reverse = cycle % 2 !== 0;
    return {
        x: -32 + (width + 64) * (reverse ? 1 - progress : progress),
        y: height * (0.81 + noise(cycle + 17001) * 0.04) + Math.sin(progress * Math.PI * 2) * 5,
        scale: Math.min(1, width / 360)
    };
}
