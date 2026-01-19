//
//  PreferencesView.swift
//  GrowthWallpaper
//
//  Created by Julien Avezou on 12/01/2026.
//

import SwiftUI
import ServiceManagement
import AppKit

struct PreferencesView: View {
    @State private var config = ConfigStore.shared.loadConfig()
    @State private var token = KeychainStore.shared.loadToken() ?? ""
    @State private var status = ""
    @State private var themes: [Theme] = []

    var body: some View {
        Form {
            Section("Themes") {
                themePickerRow
                importThemeRow
            }

            Section("GitHub") {
                TextField("Repo (owner/name)", text: $config.repoFullName)
                TextField("Issue label", text: $config.issueLabel)
                SecureField("Personal Access Token", text: $token)
            }

            Section("Growth") {
                Stepper("Steps: \(config.totalSteps)", value: $config.totalSteps, in: 4...10)
                Picker("Reset cadence", selection: $config.resetCadence) {
                    Text("Daily").tag(ResetCadence.daily)
                    Text("Weekly").tag(ResetCadence.weekly)
                }
                .pickerStyle(.segmented)
            }

            Section("Refresh") {
                Picker("Poll interval", selection: $config.pollMinutes) {
                    #if DEBUG
                    Text("1 min").tag(1)
                    #endif
                    Text("15 min").tag(15)
                    Text("30 min").tag(30)
                    Text("60 min").tag(60)
                }
                .pickerStyle(.segmented)
                .onChange(of: config.pollMinutes) { _, _ in
                    do {
                        try ConfigStore.shared.saveConfig(config)
                        NotificationCenter.default.post(name: .configDidChange, object: nil)
                    } catch {}
                }

                Text("Changes apply after saving.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Startup") {
                Toggle("Launch at login", isOn: $config.launchAtLogin)
                    .onChange(of: config.launchAtLogin) { _, newValue in
                        do {
                            try LaunchAtLoginManager.setEnabled(newValue)
                        } catch {
                            // Revert the toggle if the system call fails
                            config.launchAtLogin.toggle()
                            status = "Could not update Launch at Login"
                        }
                    }
            }

            Button("Save") { save() }

            if !status.isEmpty {
                Text(status).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(width: 420)
        .onAppear {
            ThemeManager.shared.bootstrapAndLoadThemes()
            themes = ThemeManager.shared.availableThemes

            // IMPORTANT: avoid SwiftUI Picker crash when selection has no matching tag
            if themes.isEmpty {
                if !config.selectedThemeId.isEmpty {
                    config.selectedThemeId = ""
                }
            } else if !themes.contains(where: { $0.id == config.selectedThemeId }) {
                config.selectedThemeId = themes[0].id
            }
        }
    }


    private var themePickerRow: some View {
        Group {
            if themes.isEmpty {
                HStack {
                    Text("Theme")
                    Spacer()
                    Text("No themes installed")
                        .foregroundStyle(.secondary)
                }
            } else {
                Picker("Theme", selection: $config.selectedThemeId) {
                    ForEach(themes, id: \.id) { theme in
                        Text(theme.name).tag(theme.id)
                    }
                }
            }
        }
    }

    private var importThemeRow: some View {
        HStack {
            Button("Import Theme…") { importTheme() }
            Spacer()
            Text("Install from .zip or folder")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func importTheme() {
        let panel = NSOpenPanel()
        panel.title = "Import Theme"
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [] // allow any; we validate zip/folder

        if panel.runModal() != .OK { return }
        guard let picked = panel.url else { return }

        do {
            let result = try ThemeInstaller.importTheme(from: picked)
            ThemeManager.shared.bootstrapAndLoadThemes()
            themes = ThemeManager.shared.availableThemes

            switch result {
            case .installed(let theme):
                // Auto-select imported theme
                config.selectedThemeId = theme.id
                status = "Imported theme: \(theme.name) ✅"
            }
        } catch {
            status = "Theme import failed: \(error.localizedDescription)"
        }
    }

    private func save() {
        do {
            try ConfigStore.shared.saveConfig(config)
            try KeychainStore.shared.saveToken(token)
            // Ensure Launch at Login matches config (covers first save)
            try? LaunchAtLoginManager.setEnabled(config.launchAtLogin)
            NotificationCenter.default.post(name: .configDidChange, object: nil)
            status = "Saved ✅"
        } catch {
            status = "Error saving configuration"
        }
    }
}
