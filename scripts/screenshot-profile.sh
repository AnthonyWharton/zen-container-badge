#!/usr/bin/env bash
# Launch Zen with a throwaway profile for taking screenshots: no personal
# history, bookmarks or container names. The profile is seeded with a few
# made-up client containers (several sharing a colour, which is the problem
# this mod solves) and has the mod preinstalled.
#
# Usage: scripts/screenshot-profile.sh [profile-dir]
#   Default profile dir: ${TMPDIR:-/tmp}/zen-container-badge-demo
#   Re-running reuses the directory; delete it to start fresh.
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
ZEN="${ZEN_BIN:-/Applications/Zen.app/Contents/MacOS/zen}"
DIR="${1:-${TMPDIR:-/tmp}/zen-container-badge-demo}"
[ -x "$ZEN" ] || { echo "Zen not found at $ZEN (set ZEN_BIN)" >&2; exit 1; }

if [ ! -d "$DIR" ]; then
  mkdir -p "$DIR"

  # Made-up containers. Three blues on purpose.
  python3 - "$DIR/containers.json" <<'PY'
import json, sys
demo = [
    ("Acme Ltd",        "blue",      "briefcase"),
    ("Globex",          "blue",      "briefcase"),
    ("Initech",         "blue",      "briefcase"),
    ("Umbrella Corp",   "red",       "fingerprint"),
    ("Wayne Industries","purple",    "briefcase"),
    ("Personal",        "green",     "circle"),
]
ids = [{"userContextId": i, "public": True, "icon": icon, "color": color,
        "name": name, "accessKey": ""} for i, (name, color, icon) in enumerate(demo, 1)]
ids += [
    {"userContextId": 4294967294, "public": False, "icon": "", "color": "",
     "name": "userContextIdInternal.thumbnail", "accessKey": ""},
    {"userContextId": 4294967295, "public": False, "icon": "", "color": "",
     "name": "userContextIdInternal.webextStorageLocal", "accessKey": ""},
]
json.dump({"version": 8, "lastUserContextId": len(demo), "identities": ids,
           "siteAssociations": {}}, open(sys.argv[1], "w"), indent=2)
PY

  # Skip first-run noise.
  cat > "$DIR/user.js" <<'JS'
user_pref("zen.welcome-screen.seen", true);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
user_pref("app.update.auto", false);
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);
JS

  "$HERE/scripts/install-dev.sh" "$DIR"
fi

echo "Launching Zen with throwaway profile: $DIR"
echo "Right-click the new-tab button (or use the container menu) to open tabs in the demo containers."
echo "When done, quit it with Cmd+Q (closing the window is not enough): macOS runs one Zen.app at a time,"
echo "so while this instance lives the Dock icon brings it forward instead of opening your real profile."
exec "$ZEN" --profile "$DIR" --no-remote "$@" >/dev/null 2>&1 &
