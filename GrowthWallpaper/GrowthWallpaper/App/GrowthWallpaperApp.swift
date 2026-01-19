//
//  GrowthWallpaperApp.swift
//  GrowthWallpaper
//
// © 2026 Julien Avezou

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
