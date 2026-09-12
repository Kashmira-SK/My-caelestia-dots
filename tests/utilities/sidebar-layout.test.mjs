import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import vm from "node:vm";

// Evaluate the actual wrapper binding without opening panels or power actions.
// This checks silhouette geometry, not the appearance of the rendered UI.
const wrapper = readFileSync(new URL("../../modules/session/Wrapper.qml", import.meta.url), "utf8");
const expression = wrapper.match(/^    implicitHeight: (.+)$/m)[1];
for (const contentHeight of [0, 220, 350, 500]) {
    for (const sliderHeight of [0, 178, 338, 498]) {
        for (const rounding of [0, 20, 40]) {
            const height = vm.runInNewContext(expression, {
                content: { implicitHeight: contentHeight },
                root: { panels: { osd: { implicitHeight: sliderHeight } } },
                Config: { border: { rounding }, session: { sizes: { button: 80 } } }
            });
            assert.ok(height >= contentHeight, "Power controls must fit inside their panel");
            assert.ok((height - sliderHeight) / 2 >= rounding, "Slider joins must fit inside the power rail at both ends");
            assert.ok((height - sliderHeight) / 2 >= 60, "Leave visible breathing room above and below the sliders");
        }
    }
}
console.log("Sidebar geometry checks passed: 48 content/slider/rounding combinations.");

const session = readFileSync(new URL("../../modules/session/Content.qml", import.meta.url), "utf8");
const railWidthExpression = session.match(/readonly property real railWidth: (.+)/)[1];
for (const button of [64, 80, 96]) {
    const railWidth = vm.runInNewContext(railWidthExpression, { Config: { session: { sizes: { button } } } });
    assert.ok(railWidth >= 44, "Keep a usable click target at supported sizes");
    assert.ok(railWidth < button, "The new rail must stay narrower than the old rail");
}
console.log("Compact power-rail checks passed at three configured sizes.");

const gestureSource = readFileSync(new URL("../../modules/drawers/RightPanelGesture.js", import.meta.url), "utf8").replace(/^\.pragma library\s*/, "");
const gesture = vm.runInNewContext(`${gestureSource}\nactions`);
for (let pass = 0; pass < 20; pass++) {
    for (const [distance, session, sidebar] of [[0, null, null], [-31, true, null], [-81, true, true], [-160, true, true], [0, null, null], [31, false, null], [81, false, false]]) {
        const result = gesture(distance, true, 30, 80);
        assert.equal(result.session, session);
        assert.equal(result.sidebar, sidebar);
    }
}
assert.equal(gesture(-81, false, 30, 80).session, null);
assert.equal(gesture(-81, false, 30, 80).sidebar, true);
console.log("Right-rail gesture checks passed: slow/fast opens, reversals, repeats, and outside the power band.");
