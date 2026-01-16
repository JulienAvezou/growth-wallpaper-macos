import Foundation

enum ResetCadence: String, Codable {
    case daily
    case weekly
}

struct AppConfig: Codable {
    var repoFullName: String
    var issueLabel: String
    var totalSteps: Int
    var resetCadence: ResetCadence
    var pollMinutes: Int
    var selectedThemeId: String
    var launchAtLogin: Bool
}

struct CycleState: Codable {
    var cycleStartISO: String
    var lastImageIndex: Int
}

struct ProgressSnapshot {
    let completedIssues: Int
    let ratio: Double
    let imageIndex: Int
}
