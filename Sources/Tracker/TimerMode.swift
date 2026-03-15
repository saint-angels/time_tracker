import SwiftUI

struct ColorScheme {
    let background: Color
    let foreground: Color
    let accent: Color
}

enum TimerMode {
    case idle
    case work
    case rest

    var label: String {
        switch self {
        case .idle: return "Standby"
        case .work: return "Work"
        case .rest: return "Rest"
        }
    }

    var scheme: ColorScheme {
        switch self {
        case .idle:
            return ColorScheme(
                background: Color(red: 0.92, green: 0.90, blue: 0.86),
                foreground: .black,
                accent: Color.black.opacity(0.5)
            )
        case .work:
            return ColorScheme(
                background: Color(red: 1.0, green: 0.95, blue: 0.0),
                foreground: .black,
                accent: Color.black.opacity(0.5)
            )
        case .rest:
            return ColorScheme(
                background: Color(red: 0.12, green: 0.12, blue: 0.13),
                foreground: Color(red: 0.85, green: 0.83, blue: 0.80),
                accent: Color.white.opacity(0.4)
            )
        }
    }
}
