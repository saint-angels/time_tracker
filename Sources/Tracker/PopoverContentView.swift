import SwiftUI

struct PopoverContentView: View {
    @ObservedObject var timer: TrackerTimer

    private var dailyTotalText: String {
        let total = timer.dailyWorkTotal + (timer.mode == .work && timer.isRunning ? timer.elapsedSeconds : 0)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 {
            return "\(h)h \(m)m today"
        }
        return "\(m)m today"
    }

    var body: some View {
        VStack(spacing: 12) {
            if let mode = timer.mode {
                Text(mode.label)
                    .font(.headline)
                    .foregroundColor(mode.color)

                Text(timer.displayFull)
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
            } else {
                Text("Ready")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Text(dailyTotalText)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button("Work") { timer.startWork() }
                    .buttonStyle(.borderedProminent)
                    .tint(timer.mode == .work && timer.isRunning ? .red : .gray)

                Button("Break") { timer.startBreak() }
                    .buttonStyle(.borderedProminent)
                    .tint(timer.mode == .break && timer.isRunning ? .green : .gray)
            }

            Divider()

            Button("Quit") { NSApp.terminate(nil) }
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(width: 220)
    }
}
