#!/bin/fish
set state ~/.local/state/caelestia
set scheme_json $state/scheme.json

function update_theme
    mkdir -p $state/scheme
    jq -r '.colours | to_entries[] | "\(.key) \(.value)"' $scheme_json >$state/scheme/current.txt
    jq -r '.mode' $scheme_json >$state/scheme/current-mode.txt
    fish ~/git/gtk/monitor/update.fish
    fish ~/git/qt/monitor/update.fish
    python ~/.config/caelestia/apply_theme.py --startpage-only

    set primary (jq -r '.colours.primary // empty' $scheme_json)
    set starship_template ~/.config/quickshell/caelestia/dotfiles/starship.toml
    set starship_config ~/.config/starship.toml

    if test -n "$primary"; and test -f $starship_template
        set starship_tmp "$starship_config.tmp"

        sed -E "s|\\[kash\\]\\(bold [^)]+\\)|[kash](bold #$primary)|" \
            $starship_template >$starship_tmp

        mv $starship_tmp $starship_config
    end
end

update_theme

inotifywait -q -e close_write,moved_to,create -m (dirname $scheme_json) | while read dir events file
    test "$dir$file" = $scheme_json && update_theme
end
