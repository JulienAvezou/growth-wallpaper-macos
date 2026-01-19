import AppKit

enum WallpaperSetter {
    static func set(_ url: URL) throws {
        // Basic sanity
        guard url.isFileURL else {
            throw NSError(domain: "GrowthWallpaper", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Wallpaper URL is not a file URL"
            ])
        }
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(domain: "GrowthWallpaper", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Wallpaper file does not exist: \(url.path)"
            ])
        }

        let ws = NSWorkspace.shared
        for screen in NSScreen.screens {
            try ws.setDesktopImageURL(
                url,
                for: screen,
                options: [
                    .allowClipping: true,
                    .imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue
                ]
            )
        }
    }
}
