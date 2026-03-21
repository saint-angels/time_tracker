# CYCLE

A pomodoro-like timer for macOS that nudges you to take REST.

https://github.com/user-attachments/assets/5ce38046-592f-4392-af3d-c722cd18c1ed

Tracks your WORK time and starts nudging you to REST after 25 minutes, escalating over time.
In REST mode the app stays visible, asking you to step away. It automatically switches back to WORK once the minimum rest time passes, and it detects any input.

## Install

1. Download `Cycle.zip` from [Releases](../../releases/latest) and unzip
2. Drag `Cycle.app` to `/Applications`
3. Open it -- macOS will say the app "can't be opened" or "is damaged"
4. Go to **System Settings > Privacy & Security**, scroll down, and click **Open Anyway** next to the Cycle message
5. Confirm in the dialog that appears
You only need to do this once. (I don't have the Apple Developer account, so the app isn't signed - sorry about the extra steps.)

Note: Requires macOS 14+ (Sonoma).

### From source
```
swift build && .build/debug/Tracker
```

Timer structure inspired by [Tom's Timer](https://www.pentadact.com/2023-08-06-toms-timer-5/). Design inspired by the work of [The Designers Republic](https://thedesignersrepublic.com).

Built by [@teeth2i4](https://twitter.com/teeth2i4).
