import Foundation

final class ConfigStore {
    static let shared = ConfigStore()
    private init() {}

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func loadConfig() -> AppConfig {
        if let data = try? Data(contentsOf: configURL),
           let config = try? decoder.decode(AppConfig.self, from: data) {
            return config
        }

        return AppConfig(
            repoFullName: "",
            issueLabel: "wallpaper-goal",
            totalSteps: 6,
            resetCadence: .weekly,
            pollMinutes: 30,
            selectedThemeId: "forest",
            launchAtLogin: false
        )
    }

    func saveConfig(_ config: AppConfig) throws {
        try ensureDir()
        let data = try encoder.encode(config)
        try data.write(to: configURL, options: .atomic)
    }

    func loadCycle() -> CycleState {
        if let data = try? Data(contentsOf: cycleURL),
           let state = try? decoder.decode(CycleState.self, from: data) {
            return state
        }
        return CycleState(cycleStartISO: "", lastImageIndex: 0)
    }

    func saveCycle(_ state: CycleState) throws {
        try ensureDir()
        let data = try encoder.encode(state)
        try data.write(to: cycleURL, options: .atomic)
    }

    private func ensureDir() throws {
        if !FileManager.default.fileExists(atPath: baseDir.path) {
            try FileManager.default.createDirectory(at: baseDir, withIntermediateDirectories: true)
        }
    }

    private var baseDir: URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("GrowthWallpaper")
    }

    private var configURL: URL { baseDir.appendingPathComponent("config.json") }
    private var cycleURL: URL { baseDir.appendingPathComponent("cycle.json") }
}
