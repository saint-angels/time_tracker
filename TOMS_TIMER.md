# Tom's Timer - Design Understanding

## Philosophy

A non-enforcing awareness tool. The timer doesn't tell you what to do or punish you for not doing it. It just makes time visible. The psychological trick: seeing time accumulate provides a reward signal for working and a gentle nudge when procrastinating. Designed around ADHD - the brain needs external reward signals when internal motivation is insufficient.

## Core Behavior

- You click **Work** or **Break** to start tracking. The timer counts up from 0.
- The taskbar shows elapsed minutes only (no seconds) to stay subtle.
- Opening the window shows full detail including seconds.
- You switch modes manually. Nothing auto-advances.
- There is no "done" state. You work until you decide to stop.

## Modes

Two modes: **Work** and **Break**. That's it. No short break vs long break distinction. You're either working or you're not.

## Running Totals

Each work session's duration accumulates into a daily total. When you switch from Work to Break or close the app, the work time is preserved. At the end of the day you can see how much you actually worked. The total growing is part of the reward loop.

## Session Logging

Every mode switch is timestamped in a persistent log. This lets you look back at your day and understand your patterns - when you started, how long your breaks were, when you hit your stride.

## Idle Detection

Mouse and keyboard activity are monitored. If idle for 5+ minutes, the app logs the idle duration when you return. It does NOT auto-pause, subtract time, or change modes. It's informational only - you decide what that idle time means.

## Stretch Reminders

After 1 hour of continuous work, a reminder to stretch/move. If you've been idle for 30+ minutes, the reminder is suppressed (you're already away from the desk).

## What It Doesn't Do

- No countdowns
- No enforced durations
- No sounds when "time is up" (there is no "up")
- No auto-pause on idle
- No penalties or judgments
- No complex mode sequences (no pomodoro cycles)

## Menu Bar Display

Minutes only. Not ticking seconds. The number should be visible but not demanding attention. The point is peripheral awareness, not a distraction.
