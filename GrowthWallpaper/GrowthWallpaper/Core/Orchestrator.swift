import Foundation

@MainActor
final class Orchestrator {
    var onStatusUpdate: ((String) -> Void)?

    private let github = GitHubClient()
    private let engine = ProgressEngine()
    private var pollTimer: DispatchSourceTimer?
    private var pollInterval: TimeInterval = 15 * 60
    private var isRefreshing = false
    private var pendingManualRefresh = false
    private var didApplyWallpaperThisSession = false
    private var lastManualRefresh: Date?
    private let manualCooldown: TimeInterval = 15 // seconds
    private var lastRefreshedAt: Date?

    func start() {
        let config = ConfigStore.shared.loadConfig()
        applyConfig(config)
        refreshNow(manual: false)
        startPolling()
    }

    func refreshNow(manual: Bool = false) {
        if manual {
            let now = Date()
            if let last = lastManualRefresh, now.timeIntervalSince(last) < manualCooldown {
                let remaining = Int(ceil(manualCooldown - now.timeIntervalSince(last)))
                onStatusUpdate?("Please wait \(remaining)s before refreshing again")
                return
            }
            lastManualRefresh = now
        }

        if isRefreshing {
            if manual { pendingManualRefresh = true }
            onStatusUpdate?("Refreshing…")
            return
        }

        isRefreshing = true
        Task { [weak self] in
            guard let self else { return }
            defer {
                self.isRefreshing = false
                if self.pendingManualRefresh {
                    self.pendingManualRefresh = false
                    self.refreshNow(manual: true)
                }
            }
            await self.refresh()
        }
    }

    private func refresh() async {
        let config = ConfigStore.shared.loadConfig()
        guard let token = KeychainStore.shared.loadToken() else {
            onStatusUpdate?("Set GitHub token")
            return
        }

        let cycleStart = CycleManager.cycleStart(cadence: config.resetCadence)
        let iso = CycleManager.iso(cycleStart)

        var cycle = ConfigStore.shared.loadCycle()
        if cycle.cycleStartISO != iso {
            cycle = CycleState(cycleStartISO: iso, lastImageIndex: -1)
            try? ConfigStore.shared.saveCycle(cycle)
            didApplyWallpaperThisSession = false
        }

        do {
            let closed = try await github.fetchClosedIssues(
                repo: config.repoFullName,
                label: config.issueLabel,
                since: cycleStart,
                token: token
            )

            let capped = min(closed, config.totalSteps)
            let snap = engine.compute(completed: capped, steps: config.totalSteps)

            if let url = ThemeManager.shared.frameURL(
                themeId: config.selectedThemeId,
                index: snap.imageIndex
            ) {
                // Apply if index changed OR we haven't applied since launch
                if snap.imageIndex != cycle.lastImageIndex || !didApplyWallpaperThisSession {
                    try WallpaperSetter.set(url)
                    didApplyWallpaperThisSession = true

                    cycle.lastImageIndex = snap.imageIndex
                    try? ConfigStore.shared.saveCycle(cycle)
                }

                if let url = ThemeManager.shared.frameURL(
                themeId: config.selectedThemeId,
                index: snap.imageIndex
            ) {
                // Apply if index changed; always safe to re-apply, but keep it minimal
                if snap.imageIndex != cycle.lastImageIndex {
                    try WallpaperSetter.set(url)
                    cycle.lastImageIndex = snap.imageIndex
                    try? ConfigStore.shared.saveCycle(cycle)
                }
            }
            }

            lastRefreshedAt = Date()
            onStatusUpdate?(statusText(completed: capped, total: config.totalSteps))
        } catch {
            onStatusUpdate?(mapErrorToStatus(error))
        }
    }

    private func statusText(completed: Int, total: Int) -> String {
        if let lastRefreshedAt {
            let df = DateFormatter()
            df.timeStyle = .short
            return "🌱 \(completed)/\(total) • \(df.string(from: lastRefreshedAt))"
        }
        return "🌱 \(completed)/\(total)"
    }

    private func mapErrorToStatus(_ error: Error) -> String {
        if let e = error as? GitHubClientError {
            switch e {
            case .unauthorized:
                return "Token invalid/expired"
            case .notFound:
                return "Repo not found (use owner/repo)"
            case .rateLimited(let resetAt):
                if let resetAt {
                    let df = DateFormatter()
                    df.timeStyle = .short
                    return "Rate limit, try again at \(df.string(from: resetAt))"
                }
                return "Rate limit, try again later"
            case .http(let status, _):
                return "GitHub error (\(status))"
            case .invalidResponse:
                return "GitHub error"
            }
        }
        return "GitHub error"
    }

    private func startPolling() {
        pollTimer?.cancel()
        pollTimer = nil

        let timer = DispatchSource.makeTimerSource(
            queue: DispatchQueue.global(qos: .background)
        )

        timer.schedule(
            deadline: .now() + pollInterval,
            repeating: pollInterval,
            leeway: .seconds(10)
        )

        timer.setEventHandler { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.refreshNow()
                self.refreshNow(manual: false)
            }
        }


        pollTimer = timer
        timer.resume()
    }

    func applyConfig(_ config: AppConfig) {
        updatePollingInterval(minutes: config.pollMinutes)
    }

    func updatePollingInterval(minutes: Int) {
        #if DEBUG
        let clamped = max(1, min(60, minutes))
        #else
        let clamped = max(15, min(60, minutes))
        #endif

        let newInterval = TimeInterval(clamped * 60)
        guard newInterval != pollInterval else { return }

        pollInterval = newInterval
        startPolling()
    }

    func stop() {
        pollTimer?.cancel()
        pollTimer = nil
    }
}
