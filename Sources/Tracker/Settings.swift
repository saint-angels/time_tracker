import Foundation

class Settings: ObservableObject {
    static let shared = Settings()

    @Published var breakReminderMinutes: Int {
        didSet { UserDefaults.standard.set(breakReminderMinutes, forKey: "breakReminderMinutes") }
    }
    @Published var afkTimeoutMinutes: Int {
        didSet { UserDefaults.standard.set(afkTimeoutMinutes, forKey: "afkTimeoutMinutes") }
    }
    @Published var restDurationMinutes: Int {
        didSet { UserDefaults.standard.set(restDurationMinutes, forKey: "restDurationMinutes") }
    }

    private init() {
        let d = UserDefaults.standard
        breakReminderMinutes = d.object(forKey: "breakReminderMinutes") as? Int ?? 25
        afkTimeoutMinutes = d.object(forKey: "afkTimeoutMinutes") as? Int ?? 3
        restDurationMinutes = d.object(forKey: "restDurationMinutes") as? Int ?? 5
    }

    var breakReminderAt: Int { breakReminderMinutes * 60 }
    var afkTimeout: Int { afkTimeoutMinutes * 60 }
    var maxRestDuration: Int { restDurationMinutes * 60 }
}
