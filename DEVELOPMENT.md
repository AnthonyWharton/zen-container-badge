# Development notes

Notes for working on the Container Badge mod for [Zen Browser](https://zen-browser.app).
The user-facing description that ships with the mod is [README.md](README.md);
the files below are what gets submitted to the
[theme store](https://github.com/zen-browser/theme-store).

```
chrome.css        the mod itself
preferences.json  options shown under Settings → Mods
theme.json        store metadata (id, version, URLs)
README.md         store readme
image.png         store preview image (add a screenshot before submitting)
scripts/          sideload / remove the mod in a local profile for testing
```

## Why this works

Firefox renders the container indicator in the URL bar as
`#userContext-icons` (an icon plus a `#userContext-label` holding the
container name). Zen hides the whole indicator unless
`zen.urlbar.show-contextual-id` is set, and additionally hides the label when
the URL bar is under 350px wide, which it always is in the sidebar. The mod
overrides both rules and restyles the indicator as a badge. Zen is CSS-only
for mods, so the name can only appear where Firefox already puts it in the
DOM; that is why the badge lives in the URL bar rather than on each tab.

## Local development

Zen reads mods from `<profile>/chrome/zen-themes/<id>/` and the list of
installed mods from `<profile>/zen-themes.json`. The install script copies the
mod into your profile and registers it:

```sh
scripts/install-dev.sh            # auto-detects the profile Zen is using
scripts/install-dev.sh "/path/to/profile"
```

Then restart Zen. After editing `chrome.css`, run the script again and
restart Zen to reload it. Zen rebuilds its combined `chrome/zen-themes.css`
from every mod's `chrome.css` whenever a mod setting changes, so changing any
option in the mod's settings dialog (the cog in **Settings → Mods**) and
changing it back also reloads the CSS without a restart. The on/off toggle is
meant to do the same but has not reliably done so in testing. Remove the mod
with `scripts/uninstall-dev.sh`.

The version shown in Settings → Mods is `theme.json`'s version with a `-dev`
suffix, so you can tell a sideloaded copy from a store install.

Preferences are read by Zen like this:

- `checkbox` → test in CSS with `@media -moz-pref("<property>") { … }`
- `dropdown` → an attribute on a hidden `#theme-Container-Badge` element, so
  `:root:has(#theme-Container-Badge[<property-with-dashes>="value"])`
- `string` → a CSS variable `--<property-with-dashes>` on `:root`

## Preference UI limits

Zen's mod settings dialog renders `preferences.json` as a flat list. There is
no way to hide, grey out or make one option depend on another, and the only
conditional field is `disabledOn` (a list of operating systems). So options
that only make sense in some configurations say so in their label, and the
CSS makes the irrelevant combination a harmless no-op instead.

## Cascade gotcha

Zen loads the combined mods stylesheet with the **user** origin, not author.
Normal (non-`!important`) declarations in a mod therefore lose to *any*
Firefox or Zen rule for the same property, regardless of specificity. Any
declaration that competes with an existing rule needs `!important`; only
properties nothing else sets can go without.

## Submitting to the store

Open an issue on
[zen-browser/theme-store](https://github.com/zen-browser/theme-store/issues/new?template=create-theme.yml)
with the contents of `chrome.css`, `readme.md`, `preferences.json`, a preview
image, and the name/description from `theme.json`. Note that themes in the
store are licensed CC BY-NC-SA 4.0 by the store; this repository is MIT.

## Compatibility

Written against Zen 1.24 (Firefox 159). Selectors are Firefox's own
(`#userContext-icons`, `#userContext-label`, `#userContext-indicator`) plus
Zen's `#urlbar > .urlbar-input-container`, so it should survive most Zen updates.
