import Foundation

/// theme.json spec stored inside each theme folder (e.g. Themes/forest/theme.json)
struct ThemeSpec: Codable {
    /// Stable identifier used internally (folder name should match)
    let id: String
    let name: String
    /// Total number of frames available on disk (min 4, max 10 for MVP)
    let frames: Int
    /// Optional filename pattern; defaults to "frame_%02d"
    let framePattern: String?

    var resolvedPattern: String {
        // base name only; ThemeValidator/ThemeManager append .png/.jpg
        let raw = framePattern ?? "frame_%02d"
        if raw.hasSuffix(".png") { return String(raw.dropLast(4)) }
        if raw.hasSuffix(".jpg") { return String(raw.dropLast(4)) }
        return raw
    }

    var resolvedFramePattern: String {
        resolvedPattern
    }
}

struct Theme: Equatable, Identifiable {
    let id: String
    let name: String
    let frames: Int
    let directory: URL
    let framePattern: String
}

enum ThemeError: Error, LocalizedError {
    case missingThemeJSON
    case invalidThemeJSON
    case idMismatch(expectedFolder: String, foundId: String)
    case invalidFrames(Int)
    case missingFrame(String, checkedPNG: String, checkedJPG: String, inFolder: String)

    var errorDescription: String? {
        switch self {
        case .missingThemeJSON: return "Missing theme.json"
        case .invalidThemeJSON: return "Invalid theme.json"
        case .idMismatch(let expected, let found): return "theme.json id '\(found)' must match folder '\(expected)'"
        case .invalidFrames(let n): return "Invalid frames count \(n) (must be 4–10)"
        case .missingFrame(let name, let png, let jpg, let folder):
            return "Missing frame file \(name) in \(folder)\nChecked:\n- \(png)\n- \(jpg)"
        }
    }
}