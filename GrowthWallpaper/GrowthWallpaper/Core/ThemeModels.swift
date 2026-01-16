import Foundation

struct Theme: Codable {
    let id: String
    let name: String
    let version: Int
    let frameCount: Int
    let author: String
    let description: String
    let preview: String
}
