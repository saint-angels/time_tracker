import SwiftUI

struct PopoverContentView: View {
    @ObservedObject var timer: TrackerTimer

    private var scheme: ColorScheme {
        timer.mode.scheme
    }

    private var dailyTotalText: String {
        let total = timer.dailyWorkTotal + (timer.mode == .work ? timer.elapsedSeconds : 0)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 {
            return "TOTAL \(h)H \(m)M"
        }
        return "TOTAL \(m)M"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Mode label / timer
            if timer.mode == .idle {
                Text("READY")
                    .font(.system(size: 52, weight: .heavy, design: .monospaced))
                    .foregroundColor(scheme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2)
            } else {
                Text(timer.mode.label.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .tracking(4)
                    .foregroundColor(scheme.accent)
                    .padding(.bottom, 2)

                rule
                Text(timer.displayFull)
                    .font(.system(size: timer.mode == .work && timer.elapsedSeconds < 60 ? 36 : 52, weight: .heavy, design: .monospaced))
                    .foregroundColor(scheme.foreground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                afkRule
            }

            // Daily total - micro annotation (work mode only)
            if timer.mode == .work {
                Text(dailyTotalText)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(3)
                    .foregroundColor(scheme.foreground.opacity(0.35))
                    .padding(.top, 4)
                    .padding(.bottom, 10)
            } else {
                Spacer().frame(height: 14)
            }

            // Buttons
            HStack(spacing: 6) {
                timerButton("QUIT", bg: .clear, fg: scheme.foreground.opacity(0.3)) { NSApp.terminate(nil) }
                if timer.mode == .work {
                    timerButton("BREAK", bg: .clear, fg: scheme.foreground) { timer.startBreak() }
                } else {
                    timerButton("WORK", bg: .clear, fg: scheme.foreground) { timer.startWork() }
                }
                Spacer()
            }
        }
        .padding(12)
        .frame(width: 240)
        .background(scheme.background)
    }

    private var rule: some View {
        Rectangle()
            .fill(scheme.foreground.opacity(0.2))
            .frame(height: 0.5)
    }

    private var afkRule: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(scheme.foreground.opacity(0.2))
                    .frame(height: 0.5)
                if timer.afkProgress > 0 {
                    Rectangle()
                        .fill(scheme.foreground)
                        .frame(width: geo.size.width * timer.afkProgress, height: 1.5)
                }
            }
        }
        .frame(height: 1.5)
    }

    private func timerButton(_ label: String, bg: Color, fg: Color, bordered: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                .tracking(1)
                .foregroundColor(fg)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(bg)
                .overlay(bordered ? Rectangle().stroke(fg, lineWidth: 1) : nil)
        }
        .buttonStyle(.plain)
    }
}
