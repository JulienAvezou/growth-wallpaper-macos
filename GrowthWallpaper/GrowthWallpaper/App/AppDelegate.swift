import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        ThemeManager.shared.bootstrapAndLoadThemes()
        menuBarController = MenuBarController()
        menuBarController?.start()
    }
}
