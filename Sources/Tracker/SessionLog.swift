import Foundation

class SessionLog {
    private let fileURL: URL
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    private var lastDay: String = ""

    init() {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".local/share/tracker", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("log.md")
    }

    func log(mode: TimerMode, duration: Int) {
        let now = Date()
        let today = dayFormatter.string(from: now)
        let time = dateFormatter.string(from: now)
        let durationText = formatDuration(duration)

        var lines: [String] = []

        if today != lastDay {
            if lastDay != "" {
                lines.append("")
            }
            lines.append("# \(today)")
            lines.append("")
            lastDay = today
        }

        lines.append("- \(time) \(mode.label) (\(durationText))")

        let text = lines.joined(separator: "\n") + "\n"
        append(text)
    }

    func logDailyTotal(_ totalSeconds: Int) {
        let text = "\n**Total: \(formatDuration(totalSeconds))**\n"
        append(text)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 {
            return "\(h)h \(m)m"
        }
        return "\(m)m"
    }

    private func append(_ text: String) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                handle.write(text.data(using: .utf8)!)
                handle.closeFile()
            }
        } else {
            try? text.data(using: .utf8)?.write(to: fileURL)
        }
    }

    func loadLastDay() {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { return }
        let today = dayFormatter.string(from: Date())
        if content.contains("# \(today)") {
            lastDay = today
        }
    }

    func loadTodayWorkTotal() -> Int {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { return 0 }
        let today = dayFormatter.string(from: Date())
        let header = "# \(today)"
        guard let headerRange = content.range(of: header) else { return 0 }

        let todayContent = String(content[headerRange.lowerBound...])
        var total = 0

        for line in todayContent.split(separator: "\n") {
            guard line.hasPrefix("- "), line.contains("Work (") else { continue }
            if let open = line.range(of: "("), let close = line.range(of: ")") {
                let dur = String(line[open.upperBound..<close.lowerBound])
                total += parseDuration(dur)
            }
        }
        return total
    }

    private func parseDuration(_ text: String) -> Int {
        var total = 0
        let parts = text.split(separator: " ")
        for part in parts {
            if part.hasSuffix("h"), let n = Int(part.dropLast()) {
                total += n * 3600
            } else if part.hasSuffix("m"), let n = Int(part.dropLast()) {
                total += n * 60
            }
        }
        return total
    }
}
