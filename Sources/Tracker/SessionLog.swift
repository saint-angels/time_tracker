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
        let s = seconds % 60
        if h > 0 {
            return s > 0 ? "\(h)h \(m)m \(s)s" : "\(h)h \(m)m"
        }
        return s > 0 ? "\(m)m \(s)s" : "\(m)m"
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

    func recentEntries(limit: Int = 3) -> (entries: [(time: String, label: String, duration: String)], remaining: Int) {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { return ([], 0) }
        let today = dayFormatter.string(from: Date())
        let header = "# \(today)"
        guard let headerRange = content.range(of: header) else { return ([], 0) }
        let todayContent = String(content[headerRange.lowerBound...])
        let lines = todayContent.split(separator: "\n").reversed()
        var entries: [(time: String, label: String, duration: String)] = []
        var totalCount = 0
        for line in lines {
            guard line.hasPrefix("- ") else { continue }
            totalCount += 1
            guard entries.count < limit else { continue }
            let trimmed = line.dropFirst(2)
            let parts = trimmed.split(separator: " ", maxSplits: 2)
            guard parts.count >= 2 else { totalCount -= 1; continue }
            let time = String(parts[0])
            let modeLabel = String(parts[1])
            let label: String
            switch modeLabel {
            case "Work": label = "WORKED"
            case "Rest": label = "RESTED"
            default: label = modeLabel.uppercased()
            }
            var startTime = time
            var durMinutes = ""
            if let open = line.range(of: "("), let close = line.range(of: ")") {
                let durText = String(line[open.upperBound..<close.lowerBound])
                let durSeconds = parseDuration(durText)
                let totalMin = max(1, (durSeconds + 30) / 60)
                let h = totalMin / 60
                let m = totalMin % 60
                durMinutes = h > 0 ? "+\(h)H\(m)M" : "+\(m)M"
                if let endDate = dateFormatter.date(from: time) {
                    let start = endDate.addingTimeInterval(Double(-durSeconds))
                    startTime = dateFormatter.string(from: start)
                }
            }
            entries.append((time: startTime, label: label, duration: durMinutes))
        }
        return (entries, max(0, totalCount - entries.count))
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
