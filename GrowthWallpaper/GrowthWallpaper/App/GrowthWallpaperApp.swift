//
//  GrowthWallpaperApp.swift
//  GrowthWallpaper
//
//  Created by Julien Avezou on 14/01/2026.
//

import SwiftUI

@main
struct GrowthWallpaper: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            PreferencesView()
        }

        WindowGroup {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                SettingsLink {
                    Text("Preferences…")
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
