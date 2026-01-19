import Foundation

final class ThemeManager {
    static let shared = ThemeManager()
    private init() {}

    private let fm = FileManager.default
    private let decoder = JSONDecoder()

    // MARK: - Disk paths

    private var appSupportDir: URL {
        fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("GrowthWallpaper") // keep deterministic for MVP
    }

    private var themesDir: URL {
        appSupportDir.appendingPathComponent("Themes")
    }

    // MARK: - Public

    private(set) var availableThemes: [Theme] = []

    /// Call on app launch (and optionally on Preferences open)
    func bootstrapAndLoadThemes() {
        do {
            try fm.createDirectory(at: themesDir, withIntermediateDirectories: true)

            loadThemesFromDisk()
        } catch {
            availableThemes = []
        }
    }

    var themes: [Theme] { availableThemes }

    func frameURL(themeId: String, index: Int) -> URL? {
        guard let theme = availableThemes.first(where: { $0.id == themeId }) else { return nil }
        guard index >= 0 && index < theme.frames else { return nil }

        let filename = String(format: theme.framePattern, index)
        let png = theme.directory.appendingPathComponent("\(filename).png")
        if fm.fileExists(atPath: png.path) { return png }

        let jpg = theme.directory.appendingPathComponent("\(filename).jpg")
        if fm.fileExists(atPath: jpg.path) { return jpg }

        return nil
    }

    // MARK: - Disk scanning

    private func loadThemesFromDisk() {
        let folders = (try? fm.contentsOfDirectory(at: themesDir, includingPropertiesForKeys: nil)) ?? []

                availableThemes = folders.compactMap { folder -> Theme? in
            guard (try? folder.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
                return nil
            }

            let jsonURL = folder.appendingPathComponent("theme.json")
            guard
                let data = try? Data(contentsOf: jsonURL),
                let spec = try? decoder.decode(ThemeSpec.self, from: data)
            else { return nil }

            // Enforce MVP constraints
            guard (4...10).contains(spec.frames) else { return nil }
            guard spec.id == folder.lastPathComponent else { return nil }

            // Validate frames exist
            for i in 0..<spec.frames {
                let base = String(format: spec.resolvedPattern, i)
                let png = folder.appendingPathComponent("\(base).png")
                let jpg = folder.appendingPathComponent("\(base).jpg")
                guard fm.fileExists(atPath: png.path) || fm.fileExists(atPath: jpg.path) else {
                    return nil
                }
            }

            return Theme(
                id: spec.id,
                name: spec.name,
                frames: spec.frames,
                directory: folder,
                framePattern: spec.resolvedPattern
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

