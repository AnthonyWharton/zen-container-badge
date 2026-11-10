#!/usr/bin/env bash
# Remove the sideloaded mod from a Zen profile.
# Usage: scripts/uninstall-dev.sh [profile-dir]
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
ID="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["id"])' "$HERE/theme.json")"
PROFILE="${1:-$(ls -td "$HOME/Library/Application Support/zen/Profiles"/*/ | head -1)}"

rm -rf "$PROFILE/chrome/zen-themes/$ID"
python3 - "$PROFILE/zen-themes.json" "$ID" <<'PY'
import json, sys, os
p, mod_id = sys.argv[1], sys.argv[2]
if os.path.exists(p):
    mods = json.load(open(p)) or {}
    mods.pop(mod_id, None)
    json.dump(mods, open(p, "w"), indent=2)
print("Removed", mod_id)
PY
echo "Restart Zen to apply."
