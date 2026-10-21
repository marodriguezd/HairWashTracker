# HairWashTracker — Agent Instructions

Canonical, permanent agent instructions. This is the **only** versioned agent
contract in the repo. Temporal agent work (prompts, reports, audits, scratch)
lives in `.agents/` (git-ignored, never committed).

## 1. Project purpose

Hair Wash Tracker is a local-first Flutter application to track a hair-wash
routine: tap calendar days to log washes, review weekly/monthly statistics,
and receive adaptive next-wash predictions. No account, no cloud, no network
calls; all data stays on the device (`SharedPreferences` + a versioned JSON
backup in and out through the system share sheet, with CSV still accepted on
import so a 1.0.x copy can be restored).

## 2. Repository structure

- `README.md` (English), `README_ES.md` (Spanish, kept intentionally) plus
  `README_DE.md`, `README_FR.md`, `README_IT.md`, `README_ZH.md` — product docs
  for the six UI languages, versioned in place.
- `ABOUT.md` — industry-standard project overview.
- `LICENSE` — GNU GPL v3.0 only, full text.
- `HairWashTracker/` — the Flutter project itself:
  - `lib/main.dart` — entry point (`SystemUiMode.edgeToEdge`,
    `DynamicColorBuilder` + `ChangeNotifierProvider(AppController)`).
  - `lib/providers/app_controller.dart` — single `ChangeNotifier`:
    event state, theme mode/preset, month navigation, import/export/clear.
  - `lib/services/` — `data_repository.dart` (`SharedPreferences` JSON
    store), `file_operations_service.dart` (versioned JSON backup export,
    content-sniffed JSON/CSV import, `share_plus` temp-file sharing).
  - `lib/models/` — `wash_event.dart` (dates normalized to local noon,
    equality by `isSameDay`), `prediction_result.dart`,
    `theme_preference.dart` (`SharedPreferences` keys `theme_mode`,
    `theme_preset`, `use_dynamic_color`), `language_preference.dart`
    (`app_language`, `'auto'` follows the OS locale).
  - `lib/l10n/app_localizations.dart` — the single six-language string
    catalogue (`en`, `es`, `de`, `fr`, `it`, `zh`) with an English fallback.
  - `lib/utils/` — `wash_predictive_model.dart` (EWMA), 
    `statistics_calculator.dart`, `app_theme.dart` (M3 tokens),
    `haptics.dart`.
  - `lib/ui/pages/` — `home_page.dart` (adaptive shell), `stats_page.dart`
    (`embed` mode for the shell, standalone `Scaffold` otherwise),
    `settings_page.dart` (language, theme mode, accent).
  - `lib/ui/widgets/` — calendar, month counter, data sheet, dialogs,
    theme and accent pickers, shared snackbar helper, `TonalCard`.
  - `test/` — `app_controller_test.dart`, `services_test.dart`,
    `localization_test.dart`, `theme_test.dart`, `ui_test.dart`,
    `statistics_calculator_test.dart`, `wash_predictive_model_test.dart`
    (111 tests total).
  - `android/` — Kotlin DSL Gradle (`app/build.gradle.kts`,
    `settings.gradle.kts`), `MainActivity` (plain `FlutterActivity`;
    edge-to-edge is driven from Dart), manifest with
    `android:enableOnBackInvokedCallback="true"` for predictive back.
  - `assets/` — icons, screenshots.
- `.github/workflows/` — `test.yml` (`flutter analyze` + `flutter test`),
  `build-debug.yml` (push/PR on `main`), `build-release.yml` (tags `v*` plus
  manual dispatch; signs with the `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
  `KEY_ALIAS`, `KEY_PASSWORD` secrets, fails on a debug-signed APK, and gates
  the GitHub Release behind an emulator smoke test of the built artifact).
- `.agents/` — agent-only workspace (git-ignored).

## 3. Technology stack (verified)

- Flutter 3.47 / Dart 3.13 (`stable` channel in CI).
- Android toolchain: AGP 9.1.0 (new `android{}` + `kotlin{ compilerOptions }`
  DSL, no `kotlin-android` plugin id), KGP 2.4.0, Gradle wrapper 9.3.1,
  `ndkVersion = flutter.ndkVersion`, Java 17, `compileSdk`/`targetSdk =
  flutter defaults` (36), `minSdk = flutter default` (24).
- Local JDK override (dev machines only): 
  `flutter config --jdk-dir <jdk-21-path>`.
- Pub dependencies (`HairWashTracker/pubspec.yaml`): `provider`,
  `shared_preferences` (with `shared_preferences_android` pinned below 2.5.0:
  its Pigeon JNI lookups break under R8 and every preference read/write fails
  in release builds),  `table_calendar`, `intl`, `file_picker`, `share_plus`,
  `dynamic_color`, `flutter_localizations` (SDK; supplies Material/Cupertino
  localizations for the six UI languages). `pubspec.lock` is versioned: it is
  what makes a release build reproducible, including the pin below.
- `pubspec.yaml` `version:` (`1.0.1+2`) is the single source of the
  project version.

## 4. Behavioral invariants

Preserve these (tests pin the prediction/statistics side):

- One `WashEvent` per day; toggling a wash day adds/removes it and persists
  immediately; `focusedDay` drives the visible month.
- Prediction (`WashPredictiveModel.predict`): EWMA (`alpha = 0.3`,
  `prior = 3.0`) over day-intervals + trend slope over the last ≤5
  intervals + weekday affinity (≥30% of washes on one weekday and ≥5
  events); interval clamped to 1–90 days; at most 12 predicted dates
  within 90 days after the last wash.
- Statistics: week counts run Monday–Sunday; month counts match the
  focused month; average/median return `0.0` with fewer than 2 events and
  count calendar days (UTC civil-date arithmetic), so a DST shift cannot turn
  a one-day interval into zero.
- Import/export: export writes a versioned JSON envelope (`format`,
  `version`, `exportedAt`, `events`); import dispatches on content, so the
  envelope, the 1.0.x bare JSON list and the 1.0.x `Date`/`yyyy-MM-dd` CSV
  all restore; dates normalize to local noon; files whose `format` marker is
  missing or whose `version` is newer than this build are refused; an import
  that yields no dates fails instead of erasing history; importing replaces
  the current event list; `clearAllData` wipes store + state.
- Theme: `useMaterial3: true` always; `ColorScheme.fromSeed` per preset,
  overridden by system dynamic color on Android 12+ when available;
  `ThemeMode.system/light/dark` + 4 seed presets persisted.

## 5. UI / Material 3 rules

- Tonal surfaces (`surfaceContainer*`) via `TonalCard`, never dual
  light/dark hard shadows — do not reintroduce neumorphic styling or
  `BoxShadow`-based elevation.
- Shape tokens: cards `12dp`, dialogs `28dp`, buttons/chips pill (`full`);
  dividers use `outlineVariant`.
- Real M3 components only: `AlertDialog`, `FilledButton`/`TextButton`,
  `SegmentedButton`, `NavigationBar`/`NavigationRail`, `SnackBar`
  (`inverseSurface`), `Card`.
- Motion: durations ≤500 ms, `easeOut`-family curves; no `elasticOut`,
  no looping shimmer/counter animations over 500 ms.
- Never hardcode brand colors in widgets; always read
  `Theme.of(context).colorScheme` so dynamic color and contrast modes work.
- Adaptive layout: `NavigationBar` below 600 dp, `NavigationRail` at/above
  600 dp, content constrained to `maxWidth: 840`; touch targets ≥48 dp;
  respect `SafeArea`/`WindowInsets` (edge-to-edge is mandatory).
- Haptics go through `Haptics.*` (`light` taps, `selectionClick` selects,
  `medium`/`success` confirms, `heavy`/`error` destructive paths).

## 6. Code language rules

- Comments, docstrings (`///`), and section headers are strictly
  professional English and explain **why**, never redundant **what**.
  Single-word layout markers (`// Bar`, `// Header`, …) are prohibited —
  delete them instead of writing them.
- Never touch: runtime UI strings, `debugPrint`/log texts, test assertion
  messages, version literals, `README_ES.md`.
- Application identity is `io.github.marodriguezd.hairwashtracker` on every
  platform (Android `namespace`/`applicationId`, iOS/macOS bundle ids, Linux
  `APPLICATION_ID`). Changing it would break upgrades of installed copies.

## 7. Agent workflow

1. inspect (read code, never assume) → 2. understand → 3. plan (todo list
   for 3+ step work) → 4. implement (minimal diff) → 5. `flutter analyze`
   → 6. `flutter test` → 7. review diff (`git status/diff`, no secrets) →
   8. report (facts + evidence, no marketing).

```bash
cd HairWashTracker
flutter pub get
flutter analyze              # must be clean
flutter test                 # 111 tests, must pass
flutter build apk --debug    # before declaring device-visible changes done
flutter build apk --release  # for changes that can differ under R8
```

## 8. Git rules

- Never commit or push unless explicitly requested. Never `reset --hard`,
  rebase destructively, or rewrite history.
- Never delete other agents' work. Review `git diff` before finishing.
- Never `git add -A` blindly: `build/`, `.dart_tool/`, `.gradle/`,
  `local.properties`, keystores (`.jks`), and `.agents/` are ignored or
  private — stage only intended files.
- **Agents must NOT create, modify, delete, or retag releases or tags
  unless the user explicitly requests it.**

## 9. Definition of done

- [ ] Focused change, no unrelated refactors or reformatting
- [ ] `flutter analyze` clean, `flutter test` green (no weakened tests)
- [ ] Device-visible changes verified with a debug APK on hardware
       (`install -r`, launch, screencaps, no FATAL for the app package)
- [ ] README/ABOUT updated if behavior, build, or release contracts changed
- [ ] `git status` shows only intended files; no secrets or generated output

## 10. CI coverage and manual checks

Automated on every push/PR to `main` (`test.yml`, `build-debug.yml`) and on
every `v*` tag (`build-release.yml`): analyze, 111 tests, debug build, signed
release build, signature and checksum verification, install and launch of the
release APK on an API 34 emulator, and a log assertion that persistence did
not fail at startup. The GitHub Release is only published after that smoke
job passes.

Deliberately manual, because CI cannot do it:

- Physical-device behaviour: real hardware, dynamic color from the Android 12+
  wallpaper, haptics, predictive back, share sheet and file picker.
- Keystore custody: CI can prove the signature of the built APK but cannot
  read the secret back, and a lost keystore ends update compatibility.
- Store delivery: no Play Store upload, listing or staged rollout exists yet.
- Non-Android targets: iOS/macOS/Windows/Linux/web builds are untested; only
  Android is validated end to end.
- Device locales: all six UI languages are exercised through the in-app
  selector by hand; CI covers them through unit and widget tests only.
- `dart format`: not enforced, because the existing tree is not fully
  formatted and a gate would force an unrelated repo-wide reformat.
