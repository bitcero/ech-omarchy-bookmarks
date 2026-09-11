# Bookmarks
Saved filtered views of any web app, one keystroke away.
GitHub has no saved filters for pull requests, Linear hides its custom
views behind conditions, and every other tool solves this its own way or
not at all. This plugin keeps the URLs — a filter is a URL — and gives
them a name, a search box and a keybinding.
## Install
```bash
git clone https://github.com/bitcero/ech-omarchy-bookmarks.git \
  ~/.config/omarchy/plugins/ech.bookmarks
omarchy-restart-shell
```
Then bind a key in `~/.config/hypr/bindings.lua`:
```lua
o.bind("SUPER + SHIFT + V", "Bookmarks", "omarchy-shell shell toggle ech.bookmarks")
```
## Use
| Key | Action |
|---|---|
| type | filter by name or url |
| `↑` `↓` | move |
| `⏎` | open in the browser |
| `ctrl+⏎` | save a new bookmark |
| `F2` | edit the selected one |
| `alt+c` | copy its url |
| `shift+supr` | delete it |
| `ctrl+,` | change where bookmarks are stored |
| `esc` | clear the filter, then close |
The list is ordered by how often you open each bookmark.
## Where bookmarks live
`~/.local/state/omarchy/ech-bookmarks.json` by default. Change it with
`ctrl+,` — the file moves to the new path. If bookmarks already exist at
the destination, those win and the current file stays where it is, so
pointing several machines at one synced directory does the right thing.
## Tests
```bash
node --test tests/store.test.js
```
## License
MIT
