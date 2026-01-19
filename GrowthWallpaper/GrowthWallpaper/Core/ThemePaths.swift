import Foundation

enum ThemePaths {
    static let appSupportDirName = "GrowthWallpaper"

    static var baseDir: URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(appSupportDirName, isDirectory: true)
    }

    static var themesDir: URL {
        baseDir.appendingPathComponent("Themes", isDirectory: true)
    }

    static func ensureThemesDir() throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: themesDir.path) {
            try fm.createDirectory(at: themesDir, withIntermediateDirectories: true)
        }
    }
}