import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import vm from "node:vm";

const source = readFileSync(new URL("../../modules/sidebar/SpaceField.js", import.meta.url), "utf8").replace(/^\.pragma library\s*/, "");
const field = vm.runInNewContext(`${source}\n({ starCount, star, meteor, showDetails })`);

for (const [width, height] of [[200, 240], [260, 400], [360, 560], [430, 760]]) {
    const bands = [0, 0, 0];
    for (const phase of [0, 10, 1000]) {
        for (let i = 0; i < field.starCount(width, height); i++) {
            const star = field.star(i, phase, width, height);
            if (!star) continue;
            assert.ok(star.x > 12 && star.x < width - 12);
            assert.ok(star.y > 12 && star.y < height - 12);
            assert.ok(star.alpha > 0 && star.alpha < 0.65);
            assert.ok(Math.hypot(star.x - width / 2, star.y - height / 2) >= Math.min(65, width * 0.2, height * 0.2) - 1);
            bands[Math.min(2, Math.floor(star.y / height * 3))]++;
        }
    }
    assert.ok(bands.every(count => count >= 15), "Stars should fill every vertical third, not just the center");
}

assert.equal(field.showDetails(200, 240), false);
assert.equal(field.showDetails(360, 560), true);
let visibleFrames = 0;
for (let phase = 0; phase < 20; phase += 0.035) {
    const meteor = field.meteor(phase, 360, 560);
    if (!meteor) continue;
    visibleFrames++;
    assert.ok(meteor.x > 0 && meteor.x < 360);
    assert.ok(meteor.y < 560 * 0.3, "Meteor stays above the central black hole");
    assert.ok(meteor.alpha > 0 && meteor.alpha <= 0.85);
}
assert.ok(visibleFrames >= 30 && visibleFrames <= 40, "Meteors should be occasional, not continuous");
console.log("Space-field checks passed: responsive coverage, clear center, subtle stars, and occasional meteors.");

const ship = vm.runInNewContext(`${source}\n({ count: spacecraftCount, bodyCount: spacecraftDots.length, point: spacecraftPoint })`);
assert.ok(ship.bodyCount > 150 && ship.bodyCount < 500, "Keep a readable but compact shuttle silhouette");
let moving = 0;
for (const phase of [0, 1, 10, 1000]) {
    for (let i = 0; i < ship.count; i++) {
        const grain = ship.point(i, phase);
        assert.ok(Number.isFinite(grain.x) && Number.isFinite(grain.y));
        assert.ok(Math.abs(grain.x) < 42 && Math.abs(grain.y) < 42, "Craft and exhaust stay inside their corner");
        assert.ok(grain.alpha >= 0 && grain.alpha <= 1);
        const next = ship.point(i, phase + 0.5);
        if (Math.hypot(next.x - grain.x, next.y - grain.y) > 0.01) moving++;
    }
}
assert.ok(moving > ship.count, "The spacecraft drifts and its exhaust moves");
console.log("Spacecraft checks passed: silhouette density, bounds, drift, and exhaust.");
