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

const ufo = vm.runInNewContext(`${source}\n({ count: ufoCount, point: ufoPoint, flight: ufoFlight })`);
assert.ok(ufo.count > 150 && ufo.count < 500);
for (const phase of [0, 1, 10, 1000]) {
    for (let i = 0; i < ufo.count; i++) {
        const dot = ufo.point(i, phase);
        assert.ok(Number.isFinite(dot.x) && Number.isFinite(dot.y));
        assert.ok(Math.abs(dot.x) < 24 && Math.abs(dot.y) < 14);
        assert.ok(dot.alpha > 0 && dot.alpha <= 1);
    }
}
assert.equal(ufo.flight(0, 360, 560), null);
assert.equal(ufo.flight(8, 360, 560), null);
assert.equal(ufo.flight(4.9, 200, 240), null);
for (const [width, height] of [[240, 380], [360, 560], [430, 760]]) {
    for (let cycle = 0; cycle < 6; cycle++) {
        const base = cycle * 16.8;
        const entry = ufo.flight(base + 2.8001, width, height);
        const exit = ufo.flight(base + 6.9999, width, height);
        assert.ok(cycle % 2 === 0 ? entry.x < -24 && exit.x > width + 24 : entry.x > width + 24 && exit.x < -24, "Enter and exit completely off-screen, alternating sides");
        let previous = entry.x;
        for (let time = 2.801; time < 6.999; time += 0.035) {
            const flight = ufo.flight(base + time, width, height);
            assert.ok(cycle % 2 === 0 ? flight.x >= previous : flight.x <= previous, "Keep crossing instead of parking or reversing");
            assert.ok(flight.y > height * 0.75 && flight.y < height * 0.9);
            previous = flight.x;
        }
        assert.equal(ufo.flight(base + 12, width, height), null, "Leave the scene empty between visits");
    }
}
console.log("UFO checks passed: saucer bounds, timed absence, off-screen entry/exit, and alternating crossings.");
