#!/bin/bash
# Removes the adobe-reaper launchd agent and script. Leaves the log file in place.
set -euo pipefail

LABEL="com.user.adobe-reaper"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl unload "$PLIST" 2>/dev/null || true
rm -f "$PLIST" "$HOME/.local/bin/adobe-reaper.sh"

echo "Uninstalled. Log left at ~/Library/Logs/adobe-reaper.log"
