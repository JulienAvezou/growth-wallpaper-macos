# Creating Themes for GrowthWallpaper 🎨

GrowthWallpaper themes visually represent progress toward a goal.
Themes are **art-first**, lightweight, and fully local — no uploads, no accounts.

This guide explains how to create a valid theme.

---

## Theme Structure

A theme is a folder with the following structure:

my-theme/
├── theme.json
├── frame_00.png
├── frame_01.png
├── frame_02.png
├── ...
└── frame_09.png

You can use **PNG or JPG** images.

---

## Theme Rules (Important)

To be accepted by the app, a theme must follow these rules:

- **4–10 frames only**
- Frames must be sequential (no gaps)
- Filenames must match the pattern defined in `theme.json`
- `theme.json` must be at the **root** of the theme folder
- Folder name must match the theme `id`

If any rule fails, the theme will not import.

---

## `theme.json` Specification

Minimal example:

```json
{
  "id": "forest",
  "name": "Forest",
  "frames": 10,
  "framePattern": "frame_%02d"
}
```

#### Fields

- Field Required Description
- id ✅ Unique identifier. Must match folder name
- name ✅ Display name
- frames ✅ Number of frames (4–10)
- framePattern ❌ Default: frame\_%02d (no extension)

⚠️ framePattern must NOT include .png or .jpg

## Visual Guidelines (Recommended)

These are guidelines, not requirements:

- Use a consistent camera angle
- Avoid sudden lighting changes
- Keep transitions subtle
- Avoid UI text or overlays
- Match macOS wallpaper aspect ratios (16:9 or wider)

Popular styles:

- Lo-fi / anime
- Painterly / renaissance
- Minimal / atmospheric
- Nature growth metaphors

## Testing Your Theme

- Zip the theme folder or Import the folder via Preferences → Import Theme
- Select the theme
- Trigger progress updates (or wait for polling)
- If a theme fails to import, the app will show exact missing files.

## Sharing Themes

Themes can be shared:

- As .zip files
- Via GitHub Releases
- Via personal websites

Themes are not uploaded automatically.

## Licensing & Ownership

- You retain full ownership of your art
- You choose the license
- If sharing publicly, include license info in the README or description

Thank you for contributing to the GrowthWallpaper ecosystem 🌱
