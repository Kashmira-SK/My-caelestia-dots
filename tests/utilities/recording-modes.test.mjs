import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import vm from "node:vm";

// Check the actual QML mappings without loading desktop services or recording.
const source = readFileSync(new URL("../../modules/utilities/cards/Record.qml", import.meta.url), "utf8");
const modesSource = source.match(/readonly property var recordingModes: (\[[\s\S]*?\n    \])/)[1];
const modeIndexSource = source.match(/readonly property int modeIndex: (.+)/)[1];
const selectSource = source.match(/function selectMode\(region: bool, audio: bool\): void \{([\s\S]*?)\n    \}/)[1];
const context = vm.createContext({ qsTr: text => text, root: { props: { recordingMode: "" } } });
context.recordingModes = vm.runInContext(modesSource, context);

const expected = [
    [false, false, "fullscreenRecord fullscreen", []],
    [true, false, "screenshot_regionRecord region", ["-r"]],
    [false, true, "select_to_speakRecord fullscreen with sound", ["-s"]],
    [true, true, "volume_upRecord region with sound", ["-sr"]]
];

for (const [index, [region, audio, key, flags]] of expected.entries()) {
    context.region = region;
    context.audio = audio;
    vm.runInContext(selectSource, context);
    assert.equal(context.root.props.recordingMode, key, "Preserve the saved mode key");
    assert.equal(vm.runInContext(modeIndexSource, context), index);
    assert.deepEqual(Array.from(context.recordingModes[index].flags), flags);
}

for (const key of ["", "obsolete-mode"]) {
    context.root.props.recordingMode = key;
    assert.equal(vm.runInContext(modeIndexSource, context), 0, "Unknown saved modes default to fullscreen without sound");
}
console.log("Recorder mode checks passed: four saved modes, flags, and fallback.");

// Exercise the two independent setup controls repeatedly. Changing the capture
// area must retain audio, and changing audio must retain the capture area.
context.region = false;
context.audio = false;
for (let pass = 0; pass < 20; pass++) {
    context.region = !context.region;
    vm.runInContext(selectSource, context);
    assert.equal(vm.runInContext(modeIndexSource, context), (context.audio ? 2 : 0) + (context.region ? 1 : 0));
    context.audio = !context.audio;
    vm.runInContext(selectSource, context);
    assert.equal(vm.runInContext(modeIndexSource, context), (context.audio ? 2 : 0) + (context.region ? 1 : 0));
}

const librarySource = readFileSync(new URL("../../modules/utilities/cards/RecordingList.qml", import.meta.url), "utf8");
const dateBody = librarySource.match(/readonly property var recordedAt: \{([\s\S]*?)\n            \}/)[1];
for (const [baseName, expected] of [
    ["recording_20260912_14-30-05", [2026, 8, 12, 14, 30, 5]],
    ["recording_20240229_00-00-00", [2024, 1, 29, 0, 0, 0]],
    ["renamed-recording", null]
]) {
    const recordedAt = vm.runInNewContext(`(() => { ${dateBody} })()`, { baseName });
    if (expected === null)
        assert.equal(recordedAt, null);
    else
        assert.deepEqual([recordedAt.getFullYear(), recordedAt.getMonth(), recordedAt.getDate(), recordedAt.getHours(), recordedAt.getMinutes(), recordedAt.getSeconds()], expected);
}
console.log("Recorder interaction and library checks passed: repeated area/audio changes and filename dates.");
