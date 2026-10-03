import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import vm from "node:vm";

const read = path => readFileSync(new URL(path, import.meta.url), "utf8");
const apps = read("../../modules/launcher/services/Apps.qml");
const searcher = read("../../utils/Searcher.qml");
function method(source, name) {
    const match = source.match(new RegExp(`    function ${name}\\(([^)]*)\\): [^{]+\\{([\\s\\S]*?)\\n    \\}`));
    assert.ok(match, `QML method ${name} exists`);
    return `function ${name}(${match[1].replace(/: [\w<>]+/g, "")}) {${match[2]}\n}`;
}
function library(path) {
    const context = vm.createContext({});
    vm.runInContext(read(path).replace(/^\.pragma library\s*/, ""), context);
    if (path.endsWith("fzf.js")) context.Finder = vm.runInContext("Finder", context);
    return context;
}
const context = vm.createContext({
    Config: { launcher: { specialPrefix: "@", favouriteApps: ["^fav-.*$"] } },
    Strings: {},
    Fzf: library("../../utils/scripts/fzf.js"),
    Fuzzy: library("../../utils/scripts/fuzzysort.js"),
    keys: ["name"], weights: [1], extraOpts: {}, list: [], useFuzzy: false
});
context.Strings.testRegexList = vm.runInContext(`(${method(read("../../utils/Strings.qml"), "testRegexList")})`, context);
for (const name of ["rankedResults", "search", "selector"])
    vm.runInContext(method(apps, name), context);
for (const name of ["query", "transformSearch"])
    vm.runInContext(method(searcher, name), context);
// Recreate Searcher's reactive properties against its actual bundled matchers.
Object.defineProperty(context, "fzf", { get: () => new context.Fzf.Finder(context.list, { selector: context.selector }) });
Object.defineProperty(context, "fuzzyPrepped", { get: () => context.list.map(e => {
    const result = { _item: e };
    for (const key of context.keys) result[key] = context.Fuzzy.prepare(e[key]);
    return result;
}) });
const app = (id, name, frequency, terminal = false) => ({
    id, name, frequency, categories: "Utility", comment: "Tool", execString: id,
    startupClass: id, genericName: "Utility", keywords: "Tool",
    entry: { id, name, runInTerminal: terminal }
});
context.list = [
    app("alpha", "Alpha", 0), app("atom", "atom", 7, true),
    app("beta", "Beta", 100), app("bravo", "Bravo", 0),
    app("fav-a", "A Favorite", 1), app("fav-z", "Z Favorite", 4),
    app("term", "Terminal", 0, true), app("term-plus", "Terminal Plus", 20, true),
    app("term-gui", "Terminal GUI", 30)
];
const ids = term => Array.from(context.search(term), e => e.id);
const expectedBrowse = ["fav-z", "fav-a", "atom", "alpha", "beta", "bravo", "term-gui", "term-plus", "term"];
for (const fuzzy of [false, true]) {
    context.useFuzzy = fuzzy;
    assert.deepEqual(ids(""), expectedBrowse, "Favorites lead; nonfavorites remain in letter groups");
    assert.deepEqual(ids("terminal"), ["term", "term-gui", "term-plus"], "Exact name beats higher usage");
    assert.deepEqual(ids("termi"), ["term-gui", "term-plus", "term"], "Partial matches rank by usage");
    assert.deepEqual(ids("@t termi"), ["term-plus", "term"], "Terminal filter excludes GUI apps before ranking");
    assert.deepEqual(ids("@t "), ["atom", "term-plus", "term"], "Empty terminal filter keeps letter groups");
    assert.deepEqual(ids("not-an-installed-app"), []);
    for (const [prefix, term] of [["i", "term"], ["c", "Utility"], ["d", "Tool"], ["e", "term"], ["w", "term"], ["g", "Utility"], ["k", "Tool"]]) {
        const results = ids(`@${prefix} ${term}`);
        assert.ok(results.includes("term-plus"), `Special filter ${prefix} still finds matches`);
        assert.ok(results.indexOf("term-gui") < results.indexOf("term-plus"), `Special filter ${prefix} ranks usage`);
    }
}
context.Config.launcher.favouriteApps = [];
context.list = [app("z", "Azure", 0), app("a", "Alpha", 0), app("b", "Beta", 99)];
assert.deepEqual(ids(""), ["a", "z", "b"], "Unused apps break ties alphabetically");
context.list[0].frequency++;
assert.deepEqual(ids(""), ["z", "a", "b"], "New launch counts change order within a letter");
assert.deepEqual(context.list.map(e => e.id), ["z", "a", "b"], "Ranking does not mutate the source model");
console.log("Launcher ranking passed: browsing, favorites, usage updates, ties, exact matches, both matchers, and all special filters.");
