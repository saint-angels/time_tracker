# Pomodoro Menu Bar Timer - Implementation Plan

## Context

Build a macOS menu bar Pomodoro timer as a personal utility. The app shows a countdown in the menu bar, and clicking it opens a popover with controls. No Xcode IDE - built entirely with Swift Package Manager, edited in nvim. Future requirement (not in scope now): track mouse/keyboard input to detect idle breaks.

## Tech Stack

- **Swift + AppKit/SwiftUI hybrid** (no Xcode project, just SPM)
- `NSStatusItem` for menu bar text (updates every tick)
- `NSPopover` with SwiftUI content for the controls panel
- `Timer` + wall-clock `targetDate` for drift-free countdown
- Combine to pipe `@Published` timer state to the menu bar title
- Shell script to create `.app` bundle with `LSUIElement=true`

## File Structure

```
tracker/
├── Package.swift
├── Sources/Tracker/
│   ├── main.swift                # NSApplication bootstrap (4 lines)
│   ├── AppDelegate.swift         # NSStatusItem + NSPopover + Combine wiring
│   ├── PomodoroState.swift       # TimerMode, TimerStatus enums + extensions
│   ├── PomodoroTimer.swift       # ObservableObject state machine
│   ├── PopoverContentView.swift  # SwiftUI popover UI
│   └── Notifications.swift       # Sound playback via NSSound
├── scripts/
│   └── bundle.sh                 # Creates .app bundle from swift build output
└── .gitignore
```

## Implementation Steps

### Phase 1: Skeleton - get text in the menu bar

1. **Package.swift** - executableTarget, platform macOS 13+, no dependencies
2. **PomodoroState.swift** - `TimerMode` enum (work/shortBreak/longBreak) and `TimerStatus` enum (idle/running/paused), with computed `label` and `color` properties
3. **main.swift** - `NSApplication.shared` + delegate + `.run()`
4. **AppDelegate.swift** - create `NSStatusItem` showing static "25:00", wire button action to toggle an `NSPopover` with a placeholder SwiftUI view
5. **.gitignore** - `.build/`, `build/`, `.swiftpm/`
6. **Verify**: `swift build && .build/debug/Tracker` shows "25:00" in menu bar, click toggles popover

### Phase 2: Timer logic

7. **PomodoroTimer.swift** - `ObservableObject` with:
   - `@Published` properties: `mode`, `status`, `remainingSeconds`, `completedPomodoros`, `displayText`
   - Methods: `start()`, `pause()`, `resume()`, `reset()`, `skip()`
   - Internal: `targetDate` for drift-free counting, `Timer` firing every 0.5s
   - `periodComplete()` advances mode (work -> short/long break -> work), long break every 4 pomodoros
   - Durations: 25min work, 5min short break, 15min long break
8. **Wire in AppDelegate** - Combine sink on `timer.$displayText` to update `statusItem.button?.title`
9. **Verify**: run app, timer stays idle at "25:00" (no auto-start)

### Phase 3: Popover UI

10. **PopoverContentView.swift** - SwiftUI view with `@ObservedObject var timer`:
    - Mode label (colored)
    - Large monospaced countdown
    - Pomodoro count ("2 of 4")
    - Context-dependent buttons: Start (idle), Pause (running), Resume + Reset (paused), Skip (always)
    - Quit button at bottom
11. **Verify**: click start, watch countdown in both menu bar and popover

### Phase 4: Polish

12. **Notifications.swift** - play system sounds on period completion (Glass for work-end, Hero for break-end)
13. **bundle.sh** - builds release binary, creates `build/Tracker.app` with `Info.plist` (LSUIElement=true)
14. **Right-click quit** - support right-click on status item to show quit menu (set menu temporarily, trigger click, nil out menu)
15. **Verify full cycle**: work -> sound -> break -> sound -> work, through 4 pomodoros + long break

## Key Design Decisions

- **Timer uses `targetDate`** (wall clock), not just decrementing a counter. Survives sleep/wake correctly.
- **0.5s timer interval** to avoid display jitter at second boundaries
- **`@ObservedObject` not `@StateObject`** in popover - timer is owned by AppDelegate, popover just observes
- **Popover `.behavior = .transient`** - auto-closes on outside click, standard menu bar UX
- **`NSApp.activate(ignoringOtherApps: true)`** when showing popover - needed for LSUIElement apps to receive focus
- **No auto-start** after period ends - user must explicitly start next period

## Verification

1. `swift build` compiles without errors
2. `.build/debug/Tracker` shows timer in menu bar
3. Click shows popover, click outside dismisses it
4. Start/pause/resume/reset/skip all work
5. Timer counts down in both menu bar and popover simultaneously
6. Sound plays when period completes
7. Mode advances correctly: work -> short break -> work -> ... -> long break (every 4th)
8. `./scripts/bundle.sh` creates working `.app` bundle
9. `open build/Tracker.app` runs without dock icon
