#!/usr/bin/env bash
# Sideload this mod into a Zen profile for local testing.
# Usage: scripts/install-dev.sh [profile-dir]
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
ID="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["id"])' "$HERE/theme.json")"

detect_profile() {
  # Prefer the profile of a running Zen instance, else the most recently used one.
  local p
  p="$(pgrep -fl 'Zen.app.*-profile' 2>/dev/null | sed -n 's/.*-profile \(.*\) org\.mozilla\.machname.*/\1/p' | head -1 || true)"
  if [ -n "$p" ] && [ -d "$p" ]; then echo "$p"; return; fi
  ls -td "$HOME/Library/Application Support/zen/Profiles"/*/ 2>/dev/null | head -1
}

PROFILE="${1:-$(detect_profile)}"
[ -d "$PROFILE" ] || { echo "Profile not found: $PROFILE" >&2; exit 1; }

DEST="$PROFILE/chrome/zen-themes/$ID"
mkdir -p "$DEST"
cp "$HERE/chrome.css" "$HERE/preferences.json" "$DEST/"
cp "$HERE/README.md" "$DEST/readme.md"   # Zen expects a lower-case readme.md in the mod folder

python3 - "$PROFILE/zen-themes.json" "$HERE/theme.json" <<'PY'
import json, sys, os
data_path, theme_path = sys.argv[1], sys.argv[2]
theme = json.load(open(theme_path))
mods = {}
if os.path.exists(data_path):
    with open(data_path) as f:
        mods = json.load(f) or {}
entry = dict(theme)
entry["enabled"] = mods.get(theme["id"], {}).get("enabled", True)
# Point the store URLs at nothing resolvable so Zen's updater leaves the local copy alone.
for k in ("style", "readme", "preferences", "image"):
    entry[k] = "http://127.0.0.1/zen-container-badge-dev/" + k
entry["version"] = theme["version"] + "-dev"
mods[theme["id"]] = entry
with open(data_path, "w") as f:
    json.dump(mods, f, indent=2)
print(f"Registered {theme['name']} ({theme['id']}) in {data_path}")
PY

echo "Installed to $DEST"
echo "Restart Zen (or toggle the mod in Settings -> Mods) to load it."
