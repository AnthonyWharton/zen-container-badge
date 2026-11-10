# Container Badge

Shows the **name** of the active tab's Firefox container as a coloured pill in
the URL bar.

Zen already colours container tabs, but if you run many containers (one per
client, say) you quickly run out of distinct colours. Firefox solves this by
printing the container name next to the address; Zen hides that label because
its sidebar URL bar is narrow. This mod brings it back as a compact,
truncating badge that fits the sidebar.

## Options

Open **Settings → Mods → Container Badge** to change:

| Option | What it does |
| --- | --- |
| Badge style | Filled pill (default), outline only, or plain coloured text |
| Badge placement | Inline in the URL bar (default), or on its own line directly under it so it never competes with the address or extension buttons. Own-line needs Zen's single-toolbar layout and falls back to inline in the other layouts |
| Alignment | Left, centre, right or full width, when the badge is on its own line |
| Maximum badge width | Any CSS length, e.g. `9em` or `120px`. Longer names are cut with an ellipsis |
| Hide the container icon | Show the name only |
| Hide the badge while the URL bar is focused | Gives the input its full width back while you type. Inline placement only; the own-line badge is always hidden while you type |

## Crowded URL bar?

In Zen's single-toolbar layout, pinned extension buttons share the URL bar
row with the badge. Three ways to make room, in order of preference:

1. Unpin extensions you rarely click: right-click the button → *Unpin from
   Toolbar*. They stay one click away in the extensions (puzzle) menu.
2. Set placement to **On its own line** so the badge sits under the URL bar
   instead of in it, then pick an alignment.

## Notes

- Works regardless of Zen's `zen.urlbar.show-contextual-id` setting; the mod
  forces the indicator on. Tabs in the default (no) container show nothing.
- Pairs well with [Container Halo](https://zen-browser.app/mods/cb5efa80-f1e1-43ce-8c0b-fece8462d225/),
  which colours the whole tab in the sidebar.
- Hovering a tab still shows the container name in the tooltip, as in Firefox.

## Development

Source, issues and local-testing instructions:
https://github.com/AnthonyWharton/zen-container-badge (see `DEVELOPMENT.md`).
