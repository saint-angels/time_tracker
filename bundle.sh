#!/bin/bash
set -e

APP="Cycle.app"
rm -rf "$APP"

swift build -c release

mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp .build/release/Tracker "$APP/Contents/MacOS/"
cp Info.plist "$APP/Contents/"
cp Sources/Tracker/Resources/AppIcon.icns "$APP/Contents/Resources/"

# Copy bundled resources
RESOURCES=".build/release/Tracker_Tracker.bundle"
if [ -d "$RESOURCES" ]; then
    cp -R "$RESOURCES" "$APP/Contents/Resources/"
fi

# Ad-hoc sign to prevent "damaged" error on downloaded builds
codesign --force --deep -s - "$APP"

echo "Built $APP"
