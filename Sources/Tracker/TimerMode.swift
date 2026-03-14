import SwiftUI

struct ColorScheme {
    let background: Color
    let foreground: Color
    let accent: Color
}

enum TimerMode {
    case idle
    case work
    case `break`

    var label: String {
        switch self {
        case .idle: return "Ready"
        case .work: return "Work"
        case .break: return "Break"
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
                accent: .black
            )
        case .break:
            return ColorScheme(
                background: Color(red: 0.92, green: 0.90, blue: 0.86),
                foreground: .black,
                accent: Color.black.opacity(0.5)
            )
        }
    }
}
