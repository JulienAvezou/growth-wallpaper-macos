# Growth Wallpaper (macOS)

### Install. Paste a GitHub token. Your desktop grows as you ship.

#### Menubar app that grows your desktop wallpaper as you close GitHub issues during a daily/weekly cycle.

#### We don’t store anything about you. Everything runs on your local machine.

## How it works

- Connect a GitHub repo
- Choose a goal (4–10 steps)
- Close issues with a label
- Your wallpaper grows

## Setup

1. Download and open the app.
2. Create a GitHub Personal Access Token (PAT).
3. Open Preferences:
   - Repo: `owner/repo`
   - Label: `wallpaper-goal` (or your label)
   - Poll interval: 15/30/60 minutes
   - Theme: Forest
4. Click “Save & Apply”.

## Development

- SwiftUI lifecycle + AppDelegate bridge
- No backend
- GitHub REST API

## Privacy

- GitHub access tokens are stored securely in the macOS Keychain and never written to disk in plain text.
- The app only communicates with the GitHub API to fetch issue counts for the repositories you configure.
- No data is sent to any third-party servers and there is no backend operated by this app.
- The app collects no analytics, no telemetry, and no usage tracking of any kind.

## macOS Security Notice (Unsigned App)

This app is currently unsigned (no Apple Developer certificate yet).
On first launch, macOS may block it.

How to open it safely:

- Download and unzip GrowthWallpaper-macos.zip
- Move GrowthWallpaper.app to /Applications (⚠️ Running the app from Downloads may cause macOS to block saving settings)
- Right-click the app → Open
- Click Open again in the dialog

Alternatively:

- System Settings → Privacy & Security → “Open Anyway”

This is a standard macOS protection mechanism.
The app is open source — you can inspect the code before running it.

This app is unsigned to keep the MVP simple.
Code signing and notarization will be added once the project stabilizes.

## Troubleshooting

- `Repo not found`: ensure repo is `owner/repo` (not a full URL)
- `Token invalid/expired`: recreate token and save again
- `Rate limit`: wait until the time shown in the status line

⚠️ This project is in early development. APIs, config, and theme formats may evolve
⚠️ For the PAT, please use the smallest scope needed and suggest using fine-grained PAT limited to a single repo if possible
⚠️ If the polling or refresh of wallpaper frames are not working, explicitly press the save button from preferences again
⚠️ Make sure you only have one copy of GrowthWallpaper installed
