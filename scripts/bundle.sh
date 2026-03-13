#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

swift build -c release 2>&1

APP_DIR="build/Tracker.app/Contents/MacOS"
mkdir -p "$APP_DIR"

cp .build/release/Tracker "$APP_DIR/Tracker"

cat > "build/Tracker.app/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Tracker</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.tracker</string>
    <key>CFBundleName</key>
    <string>Tracker</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

echo "Built: build/Tracker.app"
