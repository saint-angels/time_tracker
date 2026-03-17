import Foundation
import Combine
import CoreGraphics

class TrackerTimer: ObservableObject {
    @Published var mode: TimerMode = .idle
    @Published var elapsedSeconds: Int = 0
    @Published var dailyWorkTotal: Int = 0
    @Published var displayMinutes: String = "0m"
    @Published var displayFull: String = "0:00"
    @Published var flashBreakReminder: Bool = false
    @Published var afkProgress: Double = 0
    @Published var breakProgress: Double = 0
    @Published var recentEntries: [(time: String, label: String, duration: String)] = []
    @Published var moreEntriesCount: Int = 0
    @Published var flashWord: String?
    @Published var flashRestWarning: Bool = false
    @Published var flashRestToWork: Bool = false

    static let afkTimeout = 3 * 60
    private static let breakReminderAt = 25 * 60
    private static let breakReminderRepeat = 5 * 60
    private static let maxRestDuration = 5 * 60
    private var lastFlashMinute: Int = -1
    private var lastRestWarning: Date = .distantPast
    private var startDate: Date?
    private var ticker: Timer?
    private var cancellables = Set<AnyCancellable>()
    let log = SessionLog()

    init() {
        log.loadLastDay()
        dailyWorkTotal = log.loadTodayWorkTotal()
        let recent = log.recentEntries(limit: 3)
        recentEntries = recent.entries
        moreEntriesCount = recent.remaining
        $elapsedSeconds
            .map { seconds in
                "\(seconds / 60)m"
            }
            .assign(to: &$displayMinutes)
    }

    func stop() {
        if mode == .idle { return }
        logCurrentSession()
        bankTime()
        ticker?.invalidate()
        ticker = nil
        mode = .idle
        elapsedSeconds = 0
        afkProgress = 0
        startDate = nil
    }

    func startWork() {
        if mode == .work { return }
        if mode != .idle { logCurrentSession() }
        mode = .work
        flashWord = nil
        flashWord = ["冲", "LOS", "AUF"].randomElement()
        elapsedSeconds = 0
        displayFull = "00.00"
        lastFlashMinute = -1
        startDate = Date()
        startTicker(fast: true)
    }

    func startRest(offset: TimeInterval = 0) {
        if mode == .rest { return }
        logCurrentSession()
        bankTime()
        flashWord = nil
        flashWord = ["休", "RUH", "HALT", "ШШШ"].randomElement()
        lastRestWarning = Date()
        mode = .rest
        elapsedSeconds = Int(offset)
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        displayFull = String(format: "%d:%02d", m, s)
        lastFlashMinute = -1
        startDate = Date().addingTimeInterval(-offset)
        startTicker()
    }

    private func logCurrentSession() {
        guard elapsedSeconds >= 60 else { return }
        log.log(mode: mode, duration: elapsedSeconds)
        let recent = log.recentEntries(limit: 3)
        recentEntries = recent.entries
        moreEntriesCount = recent.remaining
    }

    private func bankTime() {
        if mode == .work {
            dailyWorkTotal += elapsedSeconds
        }
    }

    private func startTicker(fast: Bool = false) {
        ticker?.invalidate()
        let interval: TimeInterval = fast ? 1.0 / 30.0 : 0.5
        ticker = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard let startDate = startDate else { return }
        let elapsed = Date().timeIntervalSince(startDate)
        elapsedSeconds = Int(elapsed)
        if mode == .work {
            let m = Int(elapsed) / 60
            let s = Int(elapsed) % 60
            if elapsed < 60 {
                let cs = Int((elapsed - elapsed.rounded(.towardZero)) * 100)
                displayFull = String(format: "%02d.%02d", s, cs)
            } else {
                displayFull = String(format: "%d:%02d", m, s)
                startTicker()
            }
        } else {
            let m = Int(elapsed) / 60
            let s = Int(elapsed) % 60
            displayFull = String(format: "%d:%02d", m, s)
        }
        if mode == .work {
            breakProgress = min(1.0, Double(elapsedSeconds) / Double(Self.breakReminderAt))
        } else {
            breakProgress = 0
        }
        checkBreakReminder()
        checkIdle()
        checkRestInput()
    }

    private func checkIdle() {
        guard mode == .work else {
            afkProgress = 0
            return
        }
        let eventTypes: [CGEventType] = [.mouseMoved, .keyDown, .leftMouseDown, .scrollWheel]
        let idleSeconds = eventTypes.map {
            CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: $0)
        }.min() ?? 0
        afkProgress = min(1.0, idleSeconds / Double(Self.afkTimeout))
        if idleSeconds >= Double(Self.afkTimeout) {
            let idleInt = Int(idleSeconds)
            elapsedSeconds = max(0, elapsedSeconds - idleInt)
            startRest(offset: Double(Self.afkTimeout))
        }
    }

    private func checkRestInput() {
        guard mode == .rest, !flashRestToWork else { return }
        let eventTypes: [CGEventType] = [.mouseMoved, .keyDown, .leftMouseDown, .scrollWheel]
        let idleSeconds = eventTypes.map {
            CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: $0)
        }.min() ?? .infinity
        guard idleSeconds < 2 else { return }
        if elapsedSeconds >= Self.maxRestDuration {
            flashRestToWork = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.flashRestToWork = false
                self?.startWork()
            }
            return
        }
        let now = Date()
        guard now.timeIntervalSince(lastRestWarning) >= 10 else { return }
        lastRestWarning = now
        flashRestWarning = true
    }

    private func checkBreakReminder() {
        guard mode == .work, elapsedSeconds >= Self.breakReminderAt else { return }
        let pastThreshold = elapsedSeconds - Self.breakReminderAt
        let reminderMinute = pastThreshold / Self.breakReminderRepeat
        if reminderMinute != lastFlashMinute {
            lastFlashMinute = reminderMinute
            flashBreakReminder = true
        }
    }
}
