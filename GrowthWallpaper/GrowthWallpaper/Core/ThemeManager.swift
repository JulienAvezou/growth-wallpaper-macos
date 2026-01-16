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

            // MVP: ensure forest exists on disk by copying from flat bundled resources
            try copyBundledForestIfMissing()

            loadThemesFromDisk()
        } catch {
            availableThemes = []
        }
    }

    func frameURL(themeId: String, index: Int) -> URL? {
        let folder = themesDir.appendingPathComponent(themeId)
        return frameURLInFolder(folder, index: index)
    }

    // MARK: - Disk scanning

    private func loadThemesFromDisk() {
        let folders = (try? fm.contentsOfDirectory(at: themesDir, includingPropertiesForKeys: nil)) ?? []

        availableThemes = folders.compactMap { folder in
            let jsonURL = folder.appendingPathComponent("theme.json")
            guard let data = try? Data(contentsOf: jsonURL),
                  let theme = try? decoder.decode(Theme.self, from: data)
            else { return nil }

            // MVP constraint
            guard theme.frameCount == 10 else { return nil }

            // Validate frames exist (png or jpg)
            for i in 0..<10 {
                guard frameURLInFolder(folder, index: i) != nil else { return nil }
            }

            return theme
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func frameURLInFolder(_ folder: URL, index: Int) -> URL? {
        let png = folder.appendingPathComponent(String(format: "frame_%02d.png", index))
        if fm.fileExists(atPath: png.path) { return png }

        let jpg = folder.appendingPathComponent(String(format: "frame_%02d.jpg", index))
        if fm.fileExists(atPath: jpg.path) { return jpg }

        return nil
    }

    // MARK: - Bundled forest (flat resources) → Disk copy

    private func copyBundledForestIfMissing() throws {
        let destFolder = themesDir.appendingPathComponent("forest")
        if fm.fileExists(atPath: destFolder.path) { return }

        try fm.createDirectory(at: destFolder, withIntermediateDirectories: true)

        // Copy theme.json (bundled at Resources root)
        if let themeJSON = Bundle.main.url(forResource: "theme", withExtension: "json") {
            try fm.copyItem(at: themeJSON, to: destFolder.appendingPathComponent("theme.json"))
        } else {
            // If theme.json isn't bundled, we can't proceed safely
            throw NSError(domain: "Theme", code: 1)
        }

        // Copy frames (png preferred, jpg fallback)
        for i in 0..<10 {
            let base = String(format: "frame_%02d", i)
            let src = Bundle.main.url(forResource: base, withExtension: "png")
                ?? Bundle.main.url(forResource: base, withExtension: "jpg")

            guard let src else {
                throw NSError(domain: "Theme", code: 2)
            }

            let dest = destFolder.appendingPathComponent("\(base).\(src.pathExtension)")
            try fm.copyItem(at: src, to: dest)
        }
    }
}

