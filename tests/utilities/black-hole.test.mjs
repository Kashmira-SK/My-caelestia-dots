import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import vm from "node:vm";

const source = readFileSync(new URL("../../modules/sidebar/BlackHoleField.js", import.meta.url), "utf8").replace(/^\.pragma library\s*/, "");
const field = vm.runInNewContext(`${source}\n({ count, horizon, point })`);
let moving = 0;
for (const phase of [0, 0.5, 3, 10, 1000]) {
    let visible = 0;
    for (let index = 0; index < field.count; index++) {
        const dot = field.point(index, phase);
        if (!dot) continue;
        visible++;
        assert.ok(Number.isFinite(dot.x) && Number.isFinite(dot.y));
        assert.ok(Math.abs(dot.x) < 150 && Math.abs(dot.y) < 95, "Dots must remain inside the frame");
        assert.ok(Math.hypot(dot.x, dot.y) >= field.horizon - 1e-8, "Event horizon must remain clear");
        assert.ok(dot.alpha > 0 && dot.alpha <= 1);
        const next = field.point(index, phase + 0.035);
        if (next && Math.hypot(next.x - dot.x, next.y - dot.y) > 0.01) moving++;
    }
    assert.ok(visible > 800, "Keep the ring and disc readable throughout the loop");
}
assert.ok(moving > 3000, "The field must move, not just blink");
console.log("Black-hole checks passed: bounds, clear center, density, and movement.");
