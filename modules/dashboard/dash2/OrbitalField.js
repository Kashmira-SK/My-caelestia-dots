.pragma library

function noise(n) {
    const value = Math.sin(n * 12.9898 + 78.233) * 43758.5453;
    return value - Math.floor(value);
}

function starCount(width, height) {
    return Math.max(80, Math.min(240, Math.floor(width * height / 1900)));
}

function star(index, phase, width, height) {
    if (width < 80 || height < 80)
        return null;

    const layer = index % 3;
    const margin = 12;
    const span = width - margin * 2;
    const drift = phase * (0.24 + layer * 0.11);
    const baseX = noise(index + 301) * span;
    const x = margin + ((baseX + drift) % span + span) % span;
    const y = margin + noise(index + 1301) * (height - margin * 2);
    const pulse = Math.sin(phase * (0.1 + layer * 0.025) + index * 0.73);

    return {
        x,
        y,
        alpha: 0.16 + noise(index + 2301) * 0.38 + pulse * 0.06,
        size: 0.65 + layer * 0.35,
        cross: index % 47 === 0
    };
}

function terrainPoint(index, phase, centreX, centreY, radius) {
    const angle = noise(index + 4101) * Math.PI * 2 + phase * 0.0025;
    const distance = Math.sqrt(noise(index + 5101)) * radius * 0.94;
    return {
        x: centreX + Math.cos(angle) * distance,
        y: centreY + Math.sin(angle) * distance,
        alpha: 0.06 + noise(index + 6101) * 0.16,
        size: 0.8 + noise(index + 7101) * 2.2
    };
}

function orbitPoint(angle, centreX, centreY, radiusX, radiusY, rotation) {
    const x = Math.cos(angle) * radiusX;
    const y = Math.sin(angle) * radiusY;
    return {
        x: centreX + x * Math.cos(rotation) - y * Math.sin(rotation),
        y: centreY + x * Math.sin(rotation) + y * Math.cos(rotation)
    };
}

function craft(phase, centreX, centreY, radiusX, radiusY) {
    const angle = phase * 0.14 + Math.PI * 1.13;
    return {
        x: centreX + Math.cos(angle) * radiusX,
        y: centreY + Math.sin(angle) * radiusY,
        rotation: Math.atan2(Math.cos(angle) * radiusY, -Math.sin(angle) * radiusX)
    };
}

function dayMarker(progress, centreX, centreY, radiusX, radiusY, rotation) {
    const bounded = Math.max(0, Math.min(1, progress));
    const start = Math.PI * 1.04;
    const end = Math.PI * 1.96;
    return orbitPoint(start + (end - start) * bounded, centreX, centreY, radiusX, radiusY, rotation);
}

function meteor(phase, width, height) {
    const cycleLength = 28;
    const local = phase % cycleLength;
    const start = 7;
    const duration = 1.5;
    if (local < start || local > start + duration)
        return null;

    const progress = (local - start) / duration;
    return {
        x: width * (0.9 - progress * 0.34),
        y: height * (0.12 + progress * 0.22),
        dx: width * 0.16,
        dy: -height * 0.1,
        alpha: Math.sin(progress * Math.PI) * 0.72
    };
}
