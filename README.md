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
- Local persistence; CSV and JSON import/export, sharing exports through the system share sheet

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
