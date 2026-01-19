import Foundation

enum ThemeValidator {
    static func loadTheme(at themeDir: URL) throws -> Theme {
        let folderName = themeDir.lastPathComponent
        let jsonURL = themeDir.appendingPathComponent("theme.json")

        guard FileManager.default.fileExists(atPath: jsonURL.path) else {
            throw ThemeError.missingThemeJSON
        }

        let data = try Data(contentsOf: jsonURL)
        let spec: ThemeSpec
        do {
            spec = try JSONDecoder().decode(ThemeSpec.self, from: data)
        } catch {
            throw ThemeError.invalidThemeJSON
        }

        guard spec.id == folderName else {
            throw ThemeError.idMismatch(expectedFolder: folderName, foundId: spec.id)
        }

        guard (4...10).contains(spec.frames) else {
            throw ThemeError.invalidFrames(spec.frames)
        }

        let fm = FileManager.default
        for i in 0..<spec.frames {
            let base = String(format: spec.resolvedPattern, i) // NOTE: no extension
            let png = themeDir.appendingPathComponent("\(base).png")
            let jpg = themeDir.appendingPathComponent("\(base).jpg")
            guard fm.fileExists(atPath: png.path) || fm.fileExists(atPath: jpg.path) else {
                throw ThemeError.missingFrame(
                    "\(base).png",
                    checkedPNG: png.path,
                    checkedJPG: jpg.path,
                    inFolder: themeDir.path
                )
            }
        }

        return Theme(
            id: spec.id,
            name: spec.name,
            frames: spec.frames,
            directory: themeDir,
            framePattern: spec.resolvedFramePattern
        )
    }
}
