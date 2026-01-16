import Foundation

private struct GitHubIssue: Decodable {
    let closed_at: Date?
}

enum GitHubClientError: Error {
    case unauthorized
    case notFound
    case rateLimited(resetAt: Date?)
    case http(status: Int, message: String?)
    case invalidResponse
}

final class GitHubClient {
    private let session: URLSession = .init(configuration: .default)

    func fetchClosedIssues(repo: String, label: String, since: Date, token: String) async throws -> Int {
    // Build URL safely (label encoding, etc.)
    let parts = repo.split(separator: "/", omittingEmptySubsequences: true)
    guard parts.count == 2 else { throw GitHubClientError.invalidResponse }
    let owner = String(parts[0])
    let name = String(parts[1])

    var c = URLComponents()
    c.scheme = "https"
    c.host = "api.github.com"
    c.path = "/repos/\(owner)/\(name)/issues"
    c.queryItems = [
        .init(name: "state", value: "closed"),
        .init(name: "labels", value: label),
        .init(name: "per_page", value: "100")
    ]
    guard let url = c.url else { throw GitHubClientError.invalidResponse }

    var req = URLRequest(url: url)
    req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    req.setValue("application/vnd.githubjson", forHTTPHeaderField: "Accept")

    let (data, response) = try await session.data(for: req)
    guard let http = response as? HTTPURLResponse else { throw GitHubClientError.invalidResponse }

    if http.statusCode == 401 { throw GitHubClientError.unauthorized }
    if http.statusCode == 404 { throw GitHubClientError.notFound }
    if http.statusCode == 403 {
        // Rate-limit (best-effort). GitHub uses unix timestamp.
        let resetHeader = http.value(forHTTPHeaderField: "X-RateLimit-Reset")
        if let resetHeader, let ts = TimeInterval(resetHeader) {
            throw GitHubClientError.rateLimited(resetAt: Date(timeIntervalSince1970: ts))
        } else {
            throw GitHubClientError.rateLimited(resetAt: nil)
        }
    }
    guard (200..<300).contains(http.statusCode) else {
        let msg = String(data: data, encoding: .utf8)
        throw GitHubClientError.http(status: http.statusCode, message: msg)
    }
        // Decode response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let issues = try decoder.decode([GitHubIssue].self, from: data)
        return issues.filter { issue in
            guard let closedAt = issue.closed_at else { return false }
            return closedAt >= since
        }.count
    }
}
