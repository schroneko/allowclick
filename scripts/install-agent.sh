#!/bin/bash
set -euo pipefail
app_path="${1:?Usage: install-agent.sh /absolute/path/AllowClick.app}"
case "$app_path" in
    /*) ;;
    *) printf '%s\n' 'An absolute application path is required' >&2; exit 1 ;;
esac
binary="$app_path/Contents/MacOS/AllowClick"
test -x "$binary"
label=com.schroneko.allowclick
agent="$HOME/Library/LaunchAgents/$label.plist"
log_dir="$HOME/Library/Logs/AllowClick"
if [ -e "$agent" ]; then
    printf '%s\n' "LaunchAgent already exists: $agent" >&2
    exit 1
fi
mkdir -p "$HOME/Library/LaunchAgents" "$log_dir"
plutil -create xml1 "$agent"
plutil -insert Label -string "$label" "$agent"
plutil -insert ProgramArguments -json '[]' "$agent"
plutil -insert ProgramArguments.0 -string "$binary" "$agent"
plutil -insert RunAtLoad -bool true "$agent"
plutil -insert KeepAlive -json '{"SuccessfulExit":false}' "$agent"
plutil -insert StandardOutPath -string "$log_dir/output.log" "$agent"
plutil -insert StandardErrorPath -string "$log_dir/error.log" "$agent"
plutil -lint "$agent"
launchctl bootstrap "gui/$(id -u)" "$agent"
