.pragma library

// A tilted accretion disc with its far side lensed over the event horizon.
// Coordinates are deliberately independent of palette and output resolution.
var count = 1400;
var horizon = 35;
var surroundingCount = 100;

function noise(n) {
    const value = Math.sin(n * 12.9898 + 78.233) * 43758.5453;
    return value - Math.floor(value);
}

// Distant dust occupies the empty space around the accepted central animation.
// Keep a broad clear zone so it never fills the hole or muddies the bright disc.
function surroundingPoint(index, phase) {
    const seed = noise(index + 5101);
    const x = (noise(index + 6101) - 0.5) * 280;
    const y = (noise(index + 7101) - 0.5) * 280;
    if (Math.hypot(x, y) < 86)
        return null;
    return {
        x: x + Math.sin(phase * 0.05 + seed * 6.28) * 1.5,
        y: y + Math.cos(phase * 0.04 + seed * 6.28) * 1.5,
        alpha: 0.25 + seed * 0.3 + Math.sin(phase * 0.2 + index) * 0.08,
        size: seed > 0.9 ? 1.4 : 0.9,
        star: index % 19 === 0
    };
}

function point(index, phase) {
    const seed = noise(index + 1);
    const detail = noise(index + 1701);
    let x, y, alpha, size;

    if (index < 1100) {
        const radius = 45 + Math.pow(seed, 1.65) * 97;
        const angle = detail * Math.PI * 2 + phase * Math.pow(48 / radius, 1.5);
        x = Math.cos(angle) * radius;
        y = Math.sin(angle) * radius * 0.19;
        // Gravitational lensing lifts the rear half of the disc into an arch.
        if (Math.sin(angle) < 0 && Math.abs(x) < 51)
            y -= Math.sqrt(1 - x * x / (51 * 51)) * 34;
        y += (noise(index + 3201) - 0.5) * 5;
        alpha = (0.45 + detail * 0.55) * (1 - (radius - 45) / 180);
        size = detail > 0.84 ? 1.55 : 1;
    } else {
        const angle = (index - 1100) / 300 * Math.PI * 2 + phase * 0.12;
        const radius = 37 + seed * 4;
        x = Math.cos(angle) * radius;
        y = Math.sin(angle) * radius;
        alpha = 0.4 + 0.6 * (0.5 - Math.sin(angle) * 0.5);
        size = 1;
    }

    // The center stays genuinely empty, not a painted black circle.
    if (x * x + y * y < horizon * horizon)
        return null;

    const tilt = -0.42;
    return {
        x: x * Math.cos(tilt) - y * Math.sin(tilt),
        y: x * Math.sin(tilt) + y * Math.cos(tilt),
        alpha: alpha,
        size: size
    };
}
