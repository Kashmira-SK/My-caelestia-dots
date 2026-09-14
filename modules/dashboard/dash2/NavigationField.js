.pragma library

function noise(n) {
    const value = Math.sin(n * 12.9898 + 78.233) * 43758.5453;
    return value - Math.floor(value);
}

function starCount(width, height) {
    return Math.max(48, Math.min(120, Math.floor(width * height / 4200)));
}

function star(index, phase, width, height) {
    const x = 12 + noise(index + 101) * (width - 24);
    const y = 12 + noise(index + 1101) * (height - 24);
    return {
        x: x + Math.sin(phase * 0.018 + index) * 1.2,
        y: y + Math.cos(phase * 0.014 + index) * 0.8,
        alpha: 0.07 + noise(index + 2101) * 0.16,
        size: index % 29 === 0 ? 1.5 : 0.8
    };
}

function ringPoint(progress, centreX, centreY, radius) {
    const bounded = Math.max(0, Math.min(1, progress));
    const angle = -Math.PI / 2 + bounded * Math.PI * 2;
    return {
        x: centreX + Math.cos(angle) * radius,
        y: centreY + Math.sin(angle) * radius,
        angle
    };
}

function signalPoint(phase, offset, fromX, fromY, toX, toY) {
    const progress = ((phase * 0.12 + offset) % 1 + 1) % 1;
    const eased = progress * progress * (3 - 2 * progress);
    return {
        x: fromX + (toX - fromX) * eased,
        y: fromY + (toY - fromY) * eased,
        alpha: Math.sin(progress * Math.PI)
    };
}
