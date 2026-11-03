#!/bin/bash
set -euo pipefail
label=com.schroneko.allowclick
agent="$HOME/Library/LaunchAgents/$label.plist"
if [ ! -f "$agent" ]; then
    printf '%s\n' "LaunchAgent not found: $agent" >&2
    exit 1
fi
launchctl bootout "gui/$(id -u)" "$agent"
rm "$agent"
