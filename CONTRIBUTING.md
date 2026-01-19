# Contributing to GrowthWallpaper

Thanks for your interest in contributing to **GrowthWallpaper** 🎉
This project aims to stay lightweight, transparent, and developer-friendly.

## Ways to Contribute

You can contribute in several ways:

- 🐞 Bug reports & fixes
- ✨ Small feature improvements
- 🎨 Theme creation (art assets)
- 📚 Documentation improvements

Before starting, please read the guidelines below.

---

## Project Principles

- **No backend** — everything runs locally
- **No telemetry** — no tracking or analytics
- **Privacy first** — GitHub tokens stay in the macOS Keychain
- **Simple over clever** — MVP-level complexity only
- **Developer-friendly** — readable code, explicit behavior

If a contribution adds significant complexity, it should be discussed first.

---

## Development Setup

### Requirements

- macOS 13+
- Xcode 15+
- Swift 5.9+

### Run locally

1. Clone the repo
2. Open `GrowthWallpaper.xcodeproj`
3. Run the app from Xcode
4. The menu bar icon 🌱 will appear

> Note: Running from Xcode uses a sandboxed container path.

---

## Code Contributions

### Guidelines

- Keep changes **small and focused**
- Avoid adding new dependencies unless absolutely necessary
- Prefer clarity over abstraction
- Match existing code style
- Add comments where behavior is non-obvious

### What to avoid

- Background services / daemons
- Network calls beyond GitHub API
- Telemetry, analytics, tracking
- Auto-updates or installers

---

## Theme Contributions 🎨

Themes are **not bundled** with the app and live on disk.

### Theme directory structure

forest/
├── theme.json
├── frame_00.png
├── frame_01.png
├── ...
└── frame_09.png

### `theme.json` spec

```json
{
  "id": "forest",
  "name": "Forest",
  "version": "1.0.0",
  "frames": 10,
  "framePattern": "frame_%02d"
}
```

### Rules

Theme format:

- frames must be between 4 and 10
- framePattern must NOT include an extension
- Images must be named sequentially (frame_00.png, etc.)
- PNG or JPG only

Themes can be shared:

- via GitHub releases
- via external links
- as ZIP files for import

Art assets are owned by their creators unless stated otherwise.

## Submitting Changes

- Fork the repository
- Create a feature branch
- Make your changes
- Ensure the app builds and runs
- Open a Pull Request with:
  - what changed
  - why it’s needed
  - screenshots if UI-related
- Draft PRs are welcome.

## Licensing

Code contributions are licensed under the project’s license
Theme assets remain the property of their authors unless explicitly licensed otherwise

## Questions / Ideas

If you’re unsure whether a contribution fits:

- Open an issue
- Start a discussion
- Ask before implementing large changes

Thanks for helping improve GrowthWallpaper 🌱
