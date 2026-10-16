#!/bin/bash
# Installs adobe-reaper to ~/.local/bin and registers a launchd agent that runs it every 60s.
set -euo pipefail

LABEL="com.user.adobe-reaper"
BIN_DIR="$HOME/.local/bin"
SCRIPT="$BIN_DIR/adobe-reaper.sh"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
INTERVAL="${INTERVAL:-60}"

cd "$(dirname "$0")"

mkdir -p "$BIN_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
install -m 755 adobe-reaper.sh "$SCRIPT"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>$SCRIPT</string></array>
  <key>StartInterval</key><integer>$INTERVAL</integer>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
EOF

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo "Installed. adobe-reaper runs every ${INTERVAL}s."
echo "Log: ~/Library/Logs/adobe-reaper.log"
