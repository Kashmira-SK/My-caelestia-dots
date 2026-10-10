import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

const source = readFileSync(new URL('../../modules/drawers/Panels.qml', import.meta.url), 'utf8');
const binding = source.match(/        y: \{([\s\S]*?)\n        \}/)[1];
function position(floating, center, detached = false) {
    return vm.runInNewContext(`(function () { ${binding} })()`, {
        isDetached: detached, currentCenter: center, nonAnimHeight: 400,
        root: {height: 1076, bar: {floating, edgeGap: floating ? 9 : 0}},
        Config: {border: {thickness: 2, rounding: 5}}
    });
}
assert.equal(position(false, 1050), 676, 'Attached panels still reach the bottom');
assert.equal(position(false, 0), 0, 'Attached panels still reach the top');
assert.equal(position(true, 1050) + 400 + 5 + 2, 1080 - 9, 'Bottom connecting curve retains the rail inset');
assert.equal(position(true, 0) - 5 + 2, 9, 'Top connecting curve retains the rail inset');
assert.equal(position(true, 500), 307, 'Middle panels remain centered on their icon');
assert.equal(position(true, 1050, true), 338, 'Detached dialogs remain screen-centered');
console.log('PASS: attached, floating, centered, and edge-clamped popout placement');
