#!/bin/bash
# adobe-reaper — closes Adobe Creative Cloud background processes when no Adobe app is open.
# Installed by install.sh and run every 60s by a launchd agent.
#
# Usage:
#   adobe-reaper.sh            kill leftover Adobe background processes
#   adobe-reaper.sh --dry-run  just list what would be killed

LOG="$HOME/Library/Logs/adobe-reaper.log"
PATTERN='/Library/Application Support/Adobe/|/Applications/Utilities/Adobe |/Applications/Adobe Creative Cloud/'

DRY_RUN=0
[ "$1" = "--dry-run" ] && DRY_RUN=1

# A real Adobe app is open (Photoshop, Illustrator, etc.) — leave everything alone.
if pgrep -f "^/Applications/Adobe [^/]*/Adobe [^/]*\.app/Contents/MacOS/" | grep -q .; then
  [ $DRY_RUN -eq 1 ] && echo "An Adobe app is running — nothing would be killed."
  exit 0
fi

# Only touch processes owned by the current user.
PIDS=$(pgrep -U "$(id -u)" -f "$PATTERN")
if [ -z "$PIDS" ]; then
  [ $DRY_RUN -eq 1 ] && echo "No Adobe background processes running."
  exit 0
fi

NAMES=$(ps -o comm= -p "$(echo $PIDS | tr ' ' ',')" | sed 's#.*/##' | sort -u | paste -sd ',' -)

if [ $DRY_RUN -eq 1 ]; then
  echo "Would close: $NAMES"
  exit 0
fi

echo "$(date '+%F %T') closing: $NAMES" >> "$LOG"

# Ask nicely, then insist.
kill $PIDS 2>/dev/null
sleep 5
LEFT=$(pgrep -U "$(id -u)" -f "$PATTERN")
[ -n "$LEFT" ] && kill -9 $LEFT 2>/dev/null
exit 0
