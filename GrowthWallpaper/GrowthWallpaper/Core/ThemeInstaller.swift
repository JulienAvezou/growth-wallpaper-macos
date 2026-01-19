import Foundation

enum ThemeInstallResult {
    case installed(Theme)
}

enum ThemeInstaller {
    /// Import a theme from a folder or a .zip.
    /// - If folder: it must contain theme.json at the root.
    /// - If zip: zip root must contain theme.json (or a single top folder that contains theme.json).
    static func importTheme(from url: URL) throws -> ThemeInstallResult {
        try ThemePaths.ensureThemesDir()

        if url.pathExtension.lowercased() == "zip" {
            return try importFromZip(url)
        } else {
            return try importFromFolder(url)
        }
    }

    private static func importFromFolder(_ folderURL: URL) throws -> ThemeInstallResult {
        // Determine the actual theme folder: either folderURL itself contains theme.json,
        // or it contains exactly one child folder that contains theme.json.
        let themeFolder = try resolveThemeFolder(from: folderURL)
        let theme = try ThemeValidator.loadTheme(at: themeFolder)

        let dest = ThemePaths.themesDir.appendingPathComponent(theme.id, isDirectory: true)
        try replaceDirectory(at: dest)
        try FileManager.default.copyItem(at: themeFolder, to: dest)

        let installed = try ThemeValidator.loadTheme(at: dest)
        return .installed(installed)
    }

    private static func importFromZip(_ zipURL: URL) throws -> ThemeInstallResult {
        let fm = FileManager.default
        let temp = fm.temporaryDirectory.appendingPathComponent("GrowthWallpaperThemeImport-\(UUID().uuidString)", isDirectory: true)
        try fm.createDirectory(at: temp, withIntermediateDirectories: true)

        // Use system unzip to avoid additional deps.
        let unzip = Process()
        unzip.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        unzip.arguments = ["-q", zipURL.path, "-d", temp.path]
        try unzip.run()
        unzip.waitUntilExit()
        guard unzip.terminationStatus == 0 else {
            throw NSError(domain: "ThemeInstaller", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to unzip theme"])
        }

        let result = try importFromFolder(temp)
        // Best-effort cleanup
        try? fm.removeItem(at: temp)
        return result
    }

    private static func resolveThemeFolder(from folderURL: URL) throws -> URL {
        let json = folderURL.appendingPathComponent("theme.json")
        if FileManager.default.fileExists(atPath: json.path) {
            return folderURL
        }

        let children = try FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        let dirs = children.filter { url in
            (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }

        if dirs.count == 1 {
            let candidate = dirs[0]
            let candidateJSON = candidate.appendingPathComponent("theme.json")
            if FileManager.default.fileExists(atPath: candidateJSON.path) {
                return candidate
            }
        }

        throw ThemeError.missingThemeJSON
    }

    private static func replaceDirectory(at url: URL) throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
    }
}