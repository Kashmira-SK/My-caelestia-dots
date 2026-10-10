import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

const read = name => readFileSync(new URL(`../../modules/controlcenter/${name}.qml`, import.meta.url), 'utf8');
function method(source, name) {
    const match = source.match(new RegExp(`    function ${name}\\(([^)]*)\\)\\s*: [^{]+\\{([\\s\\S]*?)\\n    \\}`));
    assert.ok(match, `QML method ${name} exists`);
    return `function ${name}(${match[1].replace(/: [\w<>]+/g, '')}) {${match[2]}\n}`;
}
const registry = read('PaneRegistry');
const search = vm.createContext({});
vm.runInContext(method(registry, 'matches'), search);
const pages = [...registry.matchAll(/readonly property string id: "([^"]+)"\s+readonly property string keywords: qsTr\("([^"]+)"\)\s+readonly property string label: qsTr\("([^"]+)"\)/g)]
    .map(([, id, keywords, label]) => ({ id, keywords, label }));
assert.equal(pages.length, 9);
const results = query => pages.filter(page => search.matches(page, query)).map(page => page.id);
assert.equal(results('  ').length, 9);
assert.deepEqual(results('FONT SIZE'), ['appearance']);
assert.deepEqual(results('clock position'), ['desktop']);
assert.deepEqual(results('microphone'), ['audio']);
assert.deepEqual(results('Wi-Fi'), ['network']);
assert.deepEqual(results('not-a-setting'), []);

// Header search retains page results and adds direct Bar subsection routes.
search.panes = pages;
search.qsTr = text => text;
search.barSections = vm.runInContext(registry.match(/readonly property var barSections: (\[[\s\S]*?\n    \])/)[1], search);
search.pageSections = vm.runInContext(registry.match(/readonly property var pageSections: (\(\{[\s\S]*?\n    \}\))/)[1], search);
vm.runInContext(method(registry, 'sectionsFor') + '\n' + method(registry, 'search'), search);
assert.equal(search.search(' ').length, 0);
assert.ok(search.search('occupied').some(r => r.page === 'taskbar' && r.section === 'workspaces'));
assert.ok(search.search('mouse').some(r => r.page === 'taskbar' && r.section === 'interaction'));
assert.ok(search.search('tray').some(r => r.page === 'taskbar' && r.section === 'general'));
assert.ok(search.search('microphone').some(r => r.page === 'taskbar' && r.section === 'indicators'));
assert.ok(search.search('microphone').some(r => r.page === 'audio'));
assert.ok(search.search('opacity').some(r => r.page === 'appearance' && r.section === 'surfaces'));
assert.ok(search.search('shadow').some(r => r.page === 'desktop' && r.section === 'clock'));
for (const page of pages) assert.ok(search.sectionsFor(page.id).length > 0, page.id + ' has direct subsections');

let now = 1000;
let saves = 0;
const history = vm.createContext({ visualHistory: [], active: 'appearance', Date: { now: () => now }, Config: { save: () => saves++ } });
const source = read('Session');
history.sections = { appearance: 'text' };
history.barSection = 'workspaces';
history.PaneRegistry = search;
history.network = { active: null }; history.ethernet = { active: null }; history.bt = { active: null };
vm.runInContext(method(source, 'sectionFor') + '\n' + method(source, 'setSection'), history);
// Evaluate the actual QML binding expressions, including the conflict guard.
for (const name of ['lastVisualEdit', 'canUndoVisual']) {
    const expression = source.match(new RegExp(`readonly property (?:var|bool) ${name}: (.+)`))[1];
    Object.defineProperty(history, name, { get: () => vm.runInContext(expression, history) });
}
vm.runInContext(method(source, 'changeVisual') + '\n' + method(source, 'undoVisual'), history);
const target = { scale: 1, font: 'Original' };
history.changeVisual(target, 'scale', 1);
assert.equal(saves, 0, 'No-op edits do not write config');
history.changeVisual(target, 'scale', 1.1);
now += 100;
history.changeVisual(target, 'scale', 1.2);
assert.equal(history.visualHistory.length, 1, 'A continuous slider drag is one undo step');
history.undoVisual();
assert.equal(target.scale, 1);
assert.equal(history.visualHistory.length, 0);
history.changeVisual(target, 'scale', 1.1);
now += 1000;
history.changeVisual(target, 'scale', 1.2);
assert.equal(history.visualHistory.length, 2, 'A later adjustment is independently undoable');
history.undoVisual();
assert.equal(target.scale, 1.1);
history.undoVisual();
assert.equal(target.scale, 1);
history.changeVisual(target, 'font', 'New font');
target.scale = 2;
history.active = 'network';
history.sections = { appearance: 'colors' };
history.undoVisual();
assert.equal(target.font, 'Original');
assert.equal(target.scale, 2, 'Undo preserves unrelated edits');
assert.equal(history.active, 'appearance', 'Undo returns to the edited page');
assert.equal(history.sectionFor('appearance'), 'text', 'Undo returns to the edited subsection');
history.changeVisual(target, 'scale', 3);
target.scale = 4;
const beforeConflict = saves;
assert.equal(history.canUndoVisual, false);
history.undoVisual();
assert.equal(target.scale, 4, 'An external edit is never overwritten');
assert.equal(saves, beforeConflict);
for (let i = 5; i < 45; i++) {
    now += 1000;
    history.changeVisual(target, 'scale', i);
}
assert.equal(history.visualHistory.length, 30, 'History is bounded');
console.log('PASS: settings keyword search, slider undo grouping, restoration, external-edit protection, and history limit');
