pragma Singleton

import qs.config
import qs.utils
import Caelestia
import Quickshell

Searcher {
    id: root

    function launch(entry: DesktopEntry): void {
        appDb.incrementFrequency(entry.id);

        if (entry.runInTerminal)
            Quickshell.execDetached({
                command: ["app2unit", "--", ...Config.general.apps.terminal, `${Quickshell.shellDir}/assets/wrap_term_launch.sh`, ...entry.command],
                workingDirectory: entry.workingDirectory
            });
        else
            Quickshell.execDetached({
                command: ["app2unit", "--", ...entry.command],
                workingDirectory: entry.workingDirectory
            });
    }

    function search(search: string): list<var> {
        const prefix = Config.launcher.specialPrefix;

        if (search.startsWith(`${prefix}i `)) {
            keys = ["id", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}c `)) {
            keys = ["categories", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}d `)) {
            keys = ["comment", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}e `)) {
            keys = ["execString", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}w `)) {
            keys = ["startupClass", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}g `)) {
            keys = ["genericName", "name"];
            weights = [0.9, 0.1];
        } else if (search.startsWith(`${prefix}k `)) {
            keys = ["keywords", "name"];
            weights = [0.9, 0.1];
        } else {
            keys = ["name"];
            weights = [1];

            if (!search.startsWith(`${prefix}t `))
                return rankedResults(query(search), search);
        }

        const term = search.slice(prefix.length + 2);
        let results = query(term);
        if (search.startsWith(`${prefix}t `))
            results = results.filter(a => a.entry.runInTerminal);
        return rankedResults(results, term);
    }

    function rankedResults(results: list<var>, term: string): list<var> {
        const needle = term.trim().toLocaleLowerCase();
        // Keep AppEntry wrappers until sorting is done: they hold persisted usage.
        return [...results].sort((a, b) => {
            const aName = a.name.trim().toLocaleLowerCase();
            const bName = b.name.trim().toLocaleLowerCase();

            if (needle) {
                const aExact = aName === needle;
                const bExact = bName === needle;
                if (aExact !== bExact)
                    return aExact ? -1 : 1;
            } else {
                const aFavourite = Strings.testRegexList(Config.launcher.favouriteApps, a.id);
                const bFavourite = Strings.testRegexList(Config.launcher.favouriteApps, b.id);
                if (aFavourite !== bFavourite)
                    return aFavourite ? -1 : 1;

                if (!aFavourite) {
                    const letterOrder = aName.charAt(0).localeCompare(bName.charAt(0));
                    if (letterOrder)
                        return letterOrder;
                }
            }

            return b.frequency - a.frequency || aName.localeCompare(bName) || a.id.localeCompare(b.id);
        }).map(a => a.entry);
    }

    function selector(item: var): string {
        return keys.map(k => item[k]).join(" ");
    }

    list: appDb.apps
    useFuzzy: Config.launcher.useFuzzy.apps

    AppDb {
        id: appDb

        path: `${Paths.state}/apps.sqlite`
        favouriteApps: Config.launcher.favouriteApps
        entries: DesktopEntries.applications.values.filter(a => !Strings.testRegexList(Config.launcher.hiddenApps, a.id))
    }
}
