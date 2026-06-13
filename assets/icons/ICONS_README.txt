Place the following icon files in this directory before building:

  icon_dark.png   — 1024×1024 PNG, white icon on dark/transparent background
  icon_light.png  — 1024×1024 PNG, dark icon on white/transparent background

These are used by flutter_launcher_icons (if added) or Codemagic for app icon generation.
The codemagic.yaml pre-build script downloads them automatically if you set the
ICON_DARK_URL and ICON_LIGHT_URL environment variables in Codemagic.
