# Installing GrowthWallpaper (macOS)

## Requirements

- macOS 13+
- GitHub account
- GitHub Personal Access Token (classic or fine-grained)

## Download

1. Go to the **Releases** page
2. Download `GrowthWallpaper-macos.zip`

## Install

1. Unzip the file
2. Move `GrowthWallpaper.app` to `/Applications` (⚠️ Running the app from Downloads may cause macOS to block saving settings)
3. Right-click the app → **Open**
4. Click **Open** again when macOS asks

This is required because the app is currently unsigned.

The app is open source — you can inspect the code before running it.

This app is unsigned to keep the MVP simple.
Code signing and notarization will be added once the project stabilizes.

⚠️ Make sure you only have one copy of GrowthWallpaper installed.

## First Launch

- You’ll see a 🌱 icon in the macOS menu bar
- Open **Preferences** from the menu

## Configure GitHub

1. Repository: `owner/repo`
2. Issue label: e.g. `wallpaper-goal`
3. Poll interval: 15, 30, or 60 minutes
4. Paste your GitHub token
5. Click **Save & Apply**

## Install a Theme

Need to implement

## Privacy & Security

- Tokens are stored in the macOS Keychain
- No analytics or telemetry
- No servers or backend
- Only GitHub API calls

## Troubleshooting

- **Repo not found** → ensure format is `owner/repo`
- **Token invalid** → regenerate token and save again
- **Wallpaper not changing** → check theme path and restart app
