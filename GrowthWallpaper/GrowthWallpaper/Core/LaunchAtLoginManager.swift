import Foundation
import ServiceManagement

enum LaunchAtLoginManager {
  static func isEnabled() -> Bool {
      if #available(macOS 13.0, *) {
          return SMAppService.mainApp.status == .enabled
      } else {
          return false
      }
  }

  static func setEnabled(_ enabled: Bool) throws {
      guard #available(macOS 13.0, *) else { return }
      if enabled {
          try SMAppService.mainApp.register()
      } else {
          try SMAppService.mainApp.unregister()
      }
  }
}