import SwiftUI

struct ModeScheme {
    let background: Color
    let foreground: Color
    let accent: Color
    let hover: Color
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

    var scheme: ModeScheme {
        switch self {
        case .idle:
            return ModeScheme(
                background: Color(red: 0.92, green: 0.90, blue: 0.86),
                foreground: .black,
                accent: Color.black.opacity(0.5),
                hover: .black
            )
        case .work:
            return ModeScheme(
                background: Color(red: 1.0, green: 0.95, blue: 0.0),
                foreground: .black,
                accent: Color.black.opacity(0.5),
                hover: .black
            )
        case .rest:
            return ModeScheme(
                background: Color(red: 0.12, green: 0.12, blue: 0.13),
                foreground: Color(red: 0.85, green: 0.83, blue: 0.80),
                accent: Color.white.opacity(0.4),
                hover: .white
            )
        }
    }
}
