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

const planet = vm.runInNewContext(`${source}\n({ count: planetCount, point: planetPoint, ringCount, ringPoint })`);
for (const phase of [0, 1, 10, 1000]) {
    let litSide = 0, darkSide = 0, visible = 0;
    for (let i = 0; i < planet.count; i++) {
        const grain = planet.point(i, phase);
        if (!grain) continue;
        visible++;
        assert.ok(Math.hypot(grain.x, grain.y) <= 1);
        assert.ok(grain.alpha > 0 && grain.alpha <= 1);
        if (grain.x < 0) litSide += grain.alpha;
        else darkSide += grain.alpha;
    }
    assert.ok(visible > 250 && visible < 650);
    assert.ok(litSide > darkSide * 1.5, "The planet should have a readable light and shadow side");
    for (let i = 0; i < planet.ringCount; i++) {
        const grain = planet.ringPoint(i, phase);
        if (!grain) continue;
        assert.ok(Math.hypot(grain.x, grain.y) <= 2.15);
        assert.ok(grain.alpha >= 0.1 && grain.alpha <= 0.6);
    }
}
console.log("Planet checks passed: shaded hemisphere, stipple density, and soft ring bounds.");
