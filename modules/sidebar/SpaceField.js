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

// A small delta-wing shuttle, sampled into dots rather than solid icon paths.
function insideHull(x, y, hull) {
    let inside = false;
    for (let i = 0, j = hull.length - 1; i < hull.length; j = i++) {
        const a = hull[i], b = hull[j];
        if ((a[1] > y) !== (b[1] > y) && x < (b[0] - a[0]) * (y - a[1]) / (b[1] - a[1]) + a[0])
            inside = !inside;
    }
    return inside;
}

function makeSpacecraft() {
    const hull = [[0, -22], [4, -11], [5, -3], [18, 11], [18, 15], [5, 10], [5, 17], [-5, 17], [-5, 10], [-18, 15], [-18, 11], [-5, -3], [-4, -11]];
    const points = [];
    for (let row = 0; row < 32; row++) {
        for (let col = 0; col < 30; col++) {
            const x = (col - 14.5) * 1.25;
            const y = -22 + row * 1.25;
            if (!insideHull(x, y, hull))
                continue;
            // Leave a dark cockpit; vary the stipple density on the wing panels.
            if (Math.abs(x) < 2.8 && y > -10 && y < -5)
                continue;
            const wing = Math.abs(x) > 5;
            const grain = noise(row * 30 + col + 12001);
            if (grain < (wing ? 0.22 : 0.1))
                continue;
            points.push({ x: x, y: y, alpha: (wing ? 0.32 : 0.48) + grain * 0.3, size: 0.95 });
        }
    }
    return points;
}

var spacecraftDots = makeSpacecraft();
var spacecraftCount = spacecraftDots.length + 48;

function spacecraftPoint(index, phase) {
    let dot;
    if (index < spacecraftDots.length) {
        dot = spacecraftDots[index];
    } else {
        const seed = noise(index + 14001);
        const travel = (phase * 0.8 + seed) % 1;
        dot = {
            x: (index % 2 === 0 ? -3 : 3) + (noise(index + 15001) - 0.5) * (1 + travel * 3),
            y: 18 + travel * 18,
            alpha: Math.sin(travel * Math.PI) * (1 - travel) * 0.48,
            size: 0.8
        };
    }
    const angle = 0.45 + Math.sin(phase * 0.04) * 0.035;
    return {
        x: dot.x * Math.cos(angle) - dot.y * Math.sin(angle) + Math.sin(phase * 0.065) * 5,
        y: dot.x * Math.sin(angle) + dot.y * Math.cos(angle) + Math.cos(phase * 0.045) * 4,
        alpha: dot.alpha,
        size: dot.size
    };
}
