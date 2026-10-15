# Rebar: notes for contributors and coding agents

Rebar is an Omarchy 4.x bar widget plugin: `manifest.json`, `Widget.qml` (bar icon + panel),
`HexColorRow.qml` (one color row) and `bar-colors` (bash + jq/awk; all file edits go through it).

## Where things live

- Bar colors: `[bar]` in `~/.config/omarchy/shell.toml` (`background`, `text`). Hot-reloaded by the shell.
- Center gap: an `omarchy.spacer` entry in `~/.config/omarchy/shell.json` that is also `bar.centerAnchor`
  (only the anchor is pinned to the exact center). The previous anchor and chosen width are kept in
  `~/.local/state/dev.csfh.rebar/spacer.json`.
- In transparent bar mode the shell ignores the bar colors; the panel says so.

## Working on it

- Run `tests/run` (bash, awk and jq only; `tests/run <pattern>` runs a subset). It uses scratch copies and a
  stub `omarchy`, so it never touches the live config. Add a test for every change to `bar-colors`.
- Test `bar-colors` on copies, never the live files: set `BAR_COLORS_FILE`, `BAR_LAYOUT_FILE` and
  `BAR_COLORS_STATE` to scratch paths. When `BAR_LAYOUT_FILE` is set the script does not reload the shell.
- After editing `shell.json` for real, the script runs `omarchy-shell shell reloadConfig`. Without it the
  shell keeps a stale copy and writes it back over the edit the next time it persists.
- The repo directory is the source; install by copying to `~/.config/omarchy/plugins/dev.csfh.rebar/`.
  The shell caches QML files and the plugin directory listing, so QML edits and new files need
  `omarchy restart shell`. Watch errors with `journalctl --user -f | grep -i rebar`.
- Third-party plugins use scoped facades: stick to `qs.Commons` and `qs.Ui` components the existing
  third-party plugins already use.
