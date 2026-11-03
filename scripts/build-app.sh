#!/bin/bash
set -euo pipefail
project_dir="$(dirname "$(dirname "$(realpath "$0")")")"
app_path="${ALLOWCLICK_BUILD_DIR:-$project_dir/build}/AllowClick.app"
if [ -e "$app_path" ]; then
    printf '%s\n' "Build destination already exists: $app_path" >&2
    exit 1
fi
mkdir -p "$app_path/Contents/MacOS"
swiftc -O "$project_dir/Sources/main.swift" "$project_dir/Sources/AutomationWatcher.swift" "$project_dir/AllowRule.swift" -o "$app_path/Contents/MacOS/AllowClick"
cp "$project_dir/Resources/Info.plist" "$app_path/Contents/Info.plist"
codesign --force --sign "${ALLOWCLICK_SIGNING_IDENTITY:--}" --identifier com.schroneko.allowclick "$app_path"
codesign --verify --strict "$app_path"
printf '%s\n' "$app_path"
