<div align="center">
  <img src="HairWashTracker/assets/icon.png" alt="Hair Wash Tracker logo" height="96" />
</div>

# Hair Wash Tracker

[![License: GPL-3.0-only](https://img.shields.io/badge/License-GPL--3.0--only-blue.svg)](LICENSE)

English · [Versión en español](README_ES.md) · [Deutsche Version](README_DE.md) · [Version française](README_FR.md) · [Versione italiana](README_IT.md) · [中文版](README_ZH.md)

Local-first Flutter application for tracking a hair-wash routine. Log wash
days on a calendar, review weekly and monthly statistics, and get an adaptive
prediction for the next recommended wash. No account, no cloud: data stays on
the device.

<p align="center">
  <img src="HairWashTracker/assets/readme_home_light.png" width="45%" alt="Home screen, light theme">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_home_dark.png" width="45%" alt="Home screen, dark theme">
</p>

## Features

- Interactive month calendar; tap a day to log or remove a wash
- Predicted wash dates derived from logged history
- Weekly, monthly, and all-time wash counters
- Adaptive next-wash estimate (EWMA interval, trend, weekday affinity)
- Light, dark, and system themes; four seed presets (Warm Coral, Lavender
  Mist, Sage Mist, Ocean Blue) plus Android dynamic color on supported devices
- Adaptive navigation (bottom bar on phones, side rail on large screens)
- Local persistence; versioned JSON backup export and import, shared through the system share sheet (CSV backups from 1.0.x still restore)

## Backup format

Export writes `hair_wash_tracker_backup_YYYY-MM-DD.json` through the system
share sheet:

```json
{
  "format": "hair-wash-tracker",
  "version": 1,
  "exportedAt": "2026-10-21T12:32:00.000",
  "events": [
    { "date": "2026-10-14T12:00:00.000" }
  ]
}
```

Import reads that envelope and also restores the two shapes written by
1.0.0: a bare JSON array of `{"date": ...}` objects and a single-column CSV
with a `Date` header. The format is detected from the content, so a renamed
file still imports. A restore replaces the whole history; a file that yields
no dates, lacks the `format` marker, or declares a `version` newer than the
installed app is rejected instead of loading a partial history.

## Statistics

<p align="center">
  <img src="HairWashTracker/assets/readme_stats_light.png" width="45%" alt="Statistics screen, light theme">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_stats_dark.png" width="45%" alt="Statistics screen, dark theme">
</p>

## Tech stack

- Flutter / Dart, Material 3
- `provider` for state management
- `table_calendar` for the calendar view
- `shared_preferences` for local storage
- `dynamic_color` for Android dynamic theming

## Getting started

```bash
git clone https://github.com/marodriguezd/HairWashTracker.git
cd HairWashTracker/HairWashTracker
flutter pub get
flutter run
```

Quality gates:

```bash
flutter analyze
flutter test
```

## Compatibility

- Android (minSdk 24, targetSdk 36)
- Adaptive and monochrome launcher icons included
