import Cocoa

final class MenuBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let orchestrator = Orchestrator()
    private let statusLine = NSMenuItem(title: "Loading…", action: nil, keyEquivalent: "")
    private let debugLine = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let fm = FileManager.default

    func start() {
        statusItem.button?.title = "🌱"

        let menu = NSMenu()

        statusLine.isEnabled = false
        menu.addItem(statusLine)

        debugLine.isEnabled = false
        debugLine.isHidden = true
        menu.addItem(debugLine)

        menu.addItem(.separator())

        let updateNow = NSMenuItem(title: "Update now", action: #selector(update), keyEquivalent: "u")
        updateNow.target = self
        menu.addItem(updateNow)

        #if DEBUG
        let reveal = NSMenuItem(title: "Debug: Show theme path", action: #selector(showThemePath), keyEquivalent: "p")
        reveal.target = self
        menu.addItem(reveal)
        #endif

        let prefs = NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
        prefs.target = self
        menu.addItem(prefs)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu

        orchestrator.onStatusUpdate = { [weak self] text in
            self?.statusLine.title = text
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onConfigDidChange),
            name: .configDidChange,
            object: nil
        )

        orchestrator.start()
    }

    @objc private func update() {
        orchestrator.refreshNow(manual: true)
    }

    #if DEBUG
    @objc private func showThemePath() {
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("GrowthWallpaper")
            .appendingPathComponent("Themes")
        debugLine.title = "Themes: \(base.path)"
        debugLine.isHidden = false
    }
    #endif

    @objc private func openPreferences() {
        PreferencesWindowController.shared.show()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    @objc private func onConfigDidChange() {
        let config = ConfigStore.shared.loadConfig()
        orchestrator.applyConfig(config)
    }
}

