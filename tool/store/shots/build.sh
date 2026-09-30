#!/bin/bash
# Composes the framed Play screenshots from raw device captures.
#   ./build.sh <raw-dir> <out-dir>
# Captions are short and describe what is visible on that exact screen; the
# store rejects nothing for this, but a caption that promises something the
# screen does not show is the fastest way to look like everyone else.
set -e
RAW="${1:-$HOME/shots}"
OUT="${2:-docs/store/screenshots}"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$OUT"

shot () { # file, head, sub
  local src="$RAW/$1" name="${1%.png}"
  [ -f "$src" ] || { echo "missing $src"; return; }
  local url="file://$HERE/frame.html?img=file://$src"
  url="$url&head=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$2")"
  url="$url&sub=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$3")"
  "$CHROME" --headless=new --screenshot="$OUT/$name.png" --window-size=1080,1920 \
    --hide-scrollbars --force-device-scale-factor=1 --virtual-time-budget=4000 \
    "$url" >/dev/null 2>&1
  echo "  $OUT/$name.png"
}

shot 01_home.png            "More than a merge board"      "A daily trial, four modes, eighteen challenges"
shot 02_trials.png          "18 built challenges"          "Three chapters, each with its own constraint"
shot 03_trial_complete.png  "Objectives, not endless play" "Move budgets, blocked cells, no undo"
shot 04_trial_play.png      "A new trial every day"        "The same board for every player, worldwide"
shot 05_hardcore.png        "Four modes that really differ" "Hardcore: 5x5, heavy spawns, no help"
shot 06_achievements.png    "Climb the Path of the Titans" "Fifteen achievements. No currency, nothing to buy"
echo "done"
