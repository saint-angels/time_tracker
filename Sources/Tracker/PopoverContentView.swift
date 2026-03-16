import SwiftUI

struct PopoverContentView: View {
    @ObservedObject var timer: TrackerTimer
    @State private var flashOpacity: Double = 0
    @State private var restWarningOpacity: Double = 0
    @State private var restToWorkOpacity: Double = 0

    private var scheme: ColorScheme {
        timer.mode.scheme
    }

    private var dailyTotalText: String {
        let total = timer.dailyWorkTotal + (timer.mode == .work ? timer.elapsedSeconds : 0)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 {
            return "DAY \(h)H \(m)M"
        }
        return "DAY \(m)M"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Mode label / timer
            Text(timer.mode.label.uppercased())
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .tracking(4)
                .foregroundColor(scheme.accent)
                .padding(.bottom, 2)

            rule
            Text(timer.mode == .idle ? "READY" : timer.displayFull)
                .font(.system(size: 36, weight: .heavy, design: .monospaced))
                .foregroundColor(timer.mode == .idle ? scheme.accent : scheme.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topTrailing) {
                    logEntries.offset(y: 30)
                }
                .overlay {
                    if let word = timer.flashWord {
                        Text(word)
                            .font(.system(size: 80, weight: .heavy))
                            .foregroundColor(scheme.foreground.opacity(0.15 * flashOpacity))
                            .allowsHitTesting(false)
                    }
                }
            afkRule

            Spacer()

            // Buttons
            HStack(spacing: 6) {
                if timer.mode == .idle {
                    timerButton("QUIT", bg: .clear, fg: scheme.foreground.opacity(0.3)) { NSApp.terminate(nil) }
                } else {
                    timerButton("STOP", bg: .clear, fg: scheme.foreground.opacity(0.3)) { timer.stop() }
                }
                if timer.mode == .work {
                    timerButton("REST", bg: .clear, fg: scheme.foreground) { timer.startBreak() }
                } else {
                    timerButton("WORK", bg: .clear, fg: scheme.foreground) { timer.startWork() }
                }
                Spacer()
            }
        }
        .padding(12)
        .frame(width: 240, height: 160)
        .background(
            ZStack {
                scheme.background
                Color.white.opacity(restWarningOpacity)
                TimerMode.work.scheme.background.opacity(restToWorkOpacity)
            }
        )
        .onChange(of: timer.flashWord) {
            flashOpacity = 1
            withAnimation(.easeOut(duration: 1.5)) {
                flashOpacity = 0
            }
        }
        .onChange(of: timer.flashRestWarning) {
            if timer.flashRestWarning {
                restWarningOpacity = 1
                withAnimation(.easeOut(duration: 0.3)) {
                    restWarningOpacity = 0
                }
                timer.flashRestWarning = false
            }
        }
        .onChange(of: timer.flashRestToWork) {
            if timer.flashRestToWork {
                restToWorkOpacity = 1
                withAnimation(.easeOut(duration: 0.4)) {
                    restToWorkOpacity = 0
                }
            }
        }
    }

    private var rule: some View {
        Rectangle()
            .fill(scheme.foreground.opacity(0.2))
            .frame(height: 0.5)
    }

    @ViewBuilder
    private var logEntries: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(dailyTotalText)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(scheme.foreground.opacity(0.35))
            ForEach(Array(timer.recentEntries.enumerated()), id: \.offset) { _, entry in
                Text("\(entry.time) \(entry.label) \(entry.duration)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(scheme.foreground.opacity(0.35))
            }
            if timer.moreEntriesCount > 0 {
                Text("+\(timer.moreEntriesCount)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(scheme.foreground.opacity(0.35))
            }
        }
    }

    @ViewBuilder
    private var afkRule: some View {
        if timer.mode == .work {
            Text("AFK")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(scheme.foreground.opacity(0.35))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        GeometryReader { geo in
            if timer.mode == .work, timer.afkProgress > 0 {
                Rectangle()
                    .fill(scheme.foreground)
                    .frame(width: geo.size.width * timer.afkProgress, height: 1.5)
            }
        }
        .frame(height: 1.5)
    }

    private func timerButton(_ label: String, bg: Color, fg: Color, bordered: Bool = true, action: @escaping () -> Void) -> some View {
        PressableButton(action: action) { isPressed in
            Text(label)
                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                .tracking(1)
                .foregroundColor(isPressed ? scheme.background : fg)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isPressed ? fg : bg)
                .overlay(bordered ? Rectangle().stroke(fg, lineWidth: 1) : nil)
        }
    }
}

struct PressableButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: (Bool) -> Content
    @State private var isPressed = false

    var body: some View {
        content(isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
            .simultaneousGesture(TapGesture().onEnded { action() })
    }
}
