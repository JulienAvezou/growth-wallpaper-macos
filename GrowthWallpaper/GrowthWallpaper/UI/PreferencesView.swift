//
//  PreferencesView.swift
//  GrowthWallpaper
//
//  Created by Julien Avezou on 12/01/2026.
//

import SwiftUI
import ServiceManagement

struct PreferencesView: View {
    @State private var config = ConfigStore.shared.loadConfig()
    @State private var token = KeychainStore.shared.loadToken() ?? ""
    @State private var status = ""

    var body: some View {
        Form {
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

            Section("Theme") {
                Picker("Theme", selection: $config.selectedThemeId) {
                    ForEach(ThemeManager.shared.availableThemes, id: \.id) {
                        Text($0.name).tag($0.id)
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
