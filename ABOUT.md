# About — Hair Wash Tracker

## Overview

Hair Wash Tracker is a local-first mobile application for tracking a hair-wash
routine. Users tap calendar days to log washes, review weekly and monthly
statistics, and receive adaptive predictions for the next recommended wash.
There is no account, no cloud, and no network usage: all data lives on the
device with optional local CSV/JSON backup through the system share sheet.

- **Status:** in development (`main` branch)
- **Version:** `26.10.13+1` (single source: `HairWashTracker/pubspec.yaml`)
- **License:** GNU General Public License v3.0 only ([LICENSE](LICENSE))
- **Languages:** English UI ([README.md](README.md)); Spanish docs
  ([README_ES.md](README_ES.md))

## Features

- Interactive month calendar with wash-day marking and predicted-date hints
- Weekly bar charts and monthly counters with animated transitions
- Adaptive next-wash prediction (EWMA interval + trend + weekday affinity)
- Light/dark/system themes with four seed presets and Android dynamic color
- Adaptive navigation: bottom bar on phones, side rail on large screens
- CSV/JSON import, export, and full data wipe from the drawer

## Tech stack

| Area | Technology |
| --- | --- |
| Language / SDK | Dart / Flutter 3.47 (`stable`) |
| UI system | Material 3 (`useMaterial3`, tonal surfaces, dynamic color) |
| State | `provider` (`AppController`, single `ChangeNotifier`) |
| Storage | `shared_preferences` (JSON event store) |
| Calendar | `table_calendar` |
| Sharing / files | `share_plus`, `file_picker` |
| Motion | `flutter_animate` (≤500 ms, ease-out curves) |
| Android build | AGP 9.1.0, Kotlin 2.4.0, Gradle 9.3.1, NDK (Flutter default), Java 17 |
| Tests | `flutter_test` (51 tests) |

## Repository layout

```text
README.md / README_ES.md   Product documentation (EN / ES)
ABOUT.md                   This overview
AGENTS.md                  Agent working contract
LICENSE                    GPL-3.0-only, full text
HairWashTracker/           Flutter project (lib/, test/, android/, assets/)
.github/workflows/         test, build-debug, build-release pipelines
```

## Getting started

```bash
cd HairWashTracker
flutter pub get
flutter run                 # debug on a connected device
flutter build apk --debug   # debug APK
```

## Testing and quality gates

```bash
cd HairWashTracker
flutter analyze             # must report no issues
flutter test                # 51 tests, must all pass
```

Continuous integration (`.github/workflows/`):

- `test.yml` — `flutter analyze --no-fatal-infos` + `flutter test` on
  push/PR to `main`
- `build-debug.yml` — debug APK on push/PR to `main`
- `build-release.yml` — release APK on `v*` / `wash-tracker-*` tags
  (tag-driven releases only)

## Release process

Releases are cut by pushing a version tag; the release workflow builds and
publishes the APK. Tags and GitHub Releases are immutable and are never
created, moved, or deleted by automation without an explicit owner request.

## Contributing

- Follow [AGENTS.md](AGENTS.md): minimal diffs, English `why`-comments,
  Material 3 tokens (no hardcoded colors, no shadow-based elevation),
  tests updated alongside behavior changes.
- Do not commit generated output (`build/`, `.dart_tool/`, `.gradle/`),
  secrets, or keystores.
