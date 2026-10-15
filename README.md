# Rebar

Omarchy bar plugin: set the bar's background and foreground colors, and add a resizable gap exactly in the center.

It adds a palette icon to the bar. Its panel lets you:

- set the bar's **background** and **foreground** colors (hex), or reset them to the theme
- turn on a **gap exactly in the center** of the bar and set its width

## Requirements

Omarchy 4.x (the Quickshell-based `omarchy-shell`; this does not apply to Waybar-based installs) and `jq`.

## How it works

- Colors are written to the `[bar]` section of `~/.config/omarchy/shell.toml` (`background`, `text`).
  That file is the user layer over the active theme: it is hot-reloaded and survives theme switches.
- The center gap is an `omarchy.spacer` that becomes the bar's `centerAnchor` (the one widget the bar
  pins to the exact middle), inserted just before the previous anchor. Turning it off removes it and
  restores the previous anchor. Width is the spacer's `size`.
- All edits go through the bundled `bar-colors` script, which you can also run directly (`bar-colors --help`).

## Caveats

- In **transparent** bar mode (`omarchy bar transparent true`) the bar ignores both colors; the panel says so
  and offers "Make the bar opaque".
- Only hex colors are accepted (`#rgb` / `#rrggbb`).

## Install

    omarchy plugin add https://github.com/csfh/rebar.git --enable

Updates: `omarchy plugin update dev.csfh.rebar`.

### Development

Work on a copy instead: copy this directory to `~/.config/omarchy/plugins/dev.csfh.rebar/`, then

    omarchy-shell shell rescanPlugins
    omarchy plugin enable dev.csfh.rebar

The repo directory is the source; the installed directory is a copy, so re-copy after every change.
The shell caches QML files and each plugin directory's file listing, so a QML edit (or a new file)
only takes effect after `omarchy restart shell`. (`bar-colors` is run fresh each time, so edits to it apply immediately.)

## License

MIT. See [LICENSE](LICENSE). Copyright (c) 2026 Christoffer Hallas.

If you send a pull request or other contribution, you agree to the [CLA](CLA.md).
