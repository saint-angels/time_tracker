# CYCLE

A macOS menubar timer that counts up, not down. When you've been WORKing too long, it nudges you - gently at first, then harder.

## How It Works

- **Work mode** -- tracks elapsed time with a bright yellow indicator
- **Rest mode** -- dark, calm interface with a slowly rotating 3D horse
- **Idle detection** -- notices when you step away and adjusts accordingly
- **Break reminders** -- start at 25 minutes, repeat every 5
- **Overheat** -- screen shake intensifies as you approach 90 minutes of continuous work
- **Session log** -- daily totals and recent sessions persist across launches

You switch into rest manually. When you start moving again, it notices and switches back to work. The timer just makes your time visible so you can make better decisions about it.

## Install

1. Download `Cycle.zip` from [Releases](../../releases/latest) and unzip
2. Drag `Cycle.app` to `/Applications`
3. Open it -- macOS will say the app "can't be opened" or "is damaged"
4. Go to **System Settings > Privacy & Security**, scroll down, and click **Open Anyway** next to the Cycle message
5. Confirm in the dialog that appears

You only need to do this once.

## Build from source

Swift, AppKit + SwiftUI, zero dependencies. Requires macOS 14+.

```
swift build
.build/debug/Tracker
```
