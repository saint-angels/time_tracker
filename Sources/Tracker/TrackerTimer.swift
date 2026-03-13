import Foundation
import Combine

class TrackerTimer: ObservableObject {
    @Published var mode: TimerMode?
    @Published var isRunning: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var dailyWorkTotal: Int = 0
    @Published var displayMinutes: String = "0m"
    @Published var displayFull: String = "0:00"

    private var startDate: Date?
    private var ticker: Timer?
    private var cancellables = Set<AnyCancellable>()

    init() {
        $elapsedSeconds
            .map { seconds in
                "\(seconds / 60)m"
            }
            .assign(to: &$displayMinutes)

        $elapsedSeconds
            .map { seconds in
                let m = seconds / 60
                let s = seconds % 60
                return String(format: "%d:%02d", m, s)
            }
            .assign(to: &$displayFull)
    }

    func startWork() {
        if mode == .work && isRunning { return }
        if mode == .break && isRunning {
            bankTime()
        }
        mode = .work
        elapsedSeconds = 0
        startDate = Date()
        isRunning = true
        startTicker()
    }

    func startBreak() {
        if mode == .break && isRunning { return }
        if mode == .work && isRunning {
            bankTime()
        }
        mode = .break
        elapsedSeconds = 0
        startDate = Date()
        isRunning = true
        startTicker()
    }

    func reset() {
        ticker?.invalidate()
        ticker = nil
        startDate = nil
        isRunning = false
        elapsedSeconds = 0
    }

    private func bankTime() {
        if mode == .work {
            dailyWorkTotal += elapsedSeconds
        }
    }

    private func startTicker() {
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard let start = startDate else { return }
        elapsedSeconds = Int(Date().timeIntervalSince(start))
    }
}
