import Cocoa

final class MenuBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let orchestrator = Orchestrator()

    private let statusLine = NSMenuItem(title: "Loading…", action: nil, keyEquivalent: "")

    func start() {
        statusItem.button?.title = "🌱"

        // React to saved config (poll interval, etc.)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onConfigDidChange),
            name: .configDidChange,
            object: nil
        )

        let menu = NSMenu()

        statusLine.isEnabled = false
        menu.addItem(statusLine)
        menu.addItem(.separator())

        let updateNow = NSMenuItem(title: "Update now", action: #selector(update), keyEquivalent: "u")
        updateNow.target = self
        menu.addItem(updateNow)

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

