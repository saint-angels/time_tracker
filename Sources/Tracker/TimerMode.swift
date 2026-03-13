import SwiftUI

enum TimerMode {
    case work
    case `break`

    var label: String {
        switch self {
        case .work: return "Work"
        case .break: return "Break"
        }
    }

    var color: Color {
        switch self {
        case .work: return .red
        case .break: return .green
        }
    }
}
