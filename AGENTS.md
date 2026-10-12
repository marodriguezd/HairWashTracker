# HairWashTracker — Agent Instructions

Canonical, permanent agent instructions. This is the **only** versioned agent
contract in the repo. Temporal agent work (prompts, reports, audits, scratch)
lives in `.agents/` (git-ignored, never committed).

## 1. Project purpose

Hair Wash Tracker is a local-first Flutter application to track a hair-wash
routine: tap calendar days to log washes, review weekly/monthly statistics,
and receive adaptive next-wash predictions. No account, no cloud, no network
calls; all data stays on the device (`SharedPreferences` + local CSV/JSON
import/export via the system share sheet).

## 2. Repository structure

- `README.md` (English), `README_ES.md` (Spanish, kept intentionally) —
  product docs, versioned in place.
- `ABOUT.md` — industry-standard project overview.
- `LICENSE` — GNU GPL v3.0 only, full text.
- `Hairwashtracker.apk` — tracked build artifact of a published debug build.
- `HairWashTracker/` — the Flutter project itself:
  - `lib/main.dart` — entry point (`SystemUiMode.edgeToEdge`,
    `DynamicColorBuilder` + `ChangeNotifierProvider(AppController)`).
  - `lib/providers/app_controller.dart` — single `ChangeNotifier`:
    event state, theme mode/preset, month navigation, import/export/clear.
  - `lib/services/` — `data_repository.dart` (`SharedPreferences` JSON
    store), `file_operations_service.dart` (CSV/JSON import/export +
    `share_plus` temp-file sharing).
  - `lib/models/` — `wash_event.dart` (dates normalized to local noon,
    equality by `isSameDay`), `prediction_result.dart`,
    `theme_preference.dart` (`SharedPreferences` keys `theme_mode`,
    `theme_preset`).
  - `lib/utils/` — `wash_predictive_model.dart` (EWMA), 
    `statistics_calculator.dart`, `app_theme.dart` (M3 tokens),
    `animations.dart` (durations/curves), `haptics.dart`.
  - `lib/ui/pages/` — `home_page.dart` (adaptive shell), `stats_page.dart`
    (`embed` mode for the shell, standalone `Scaffold` otherwise).
  - `lib/ui/widgets/` — calendar, charts, progress, dialogs, drawer,
    shimmer/loading, counters.
  - `test/` — `app_controller_test.dart`,
    `statistics_calculator_test.dart`, `wash_predictive_model_test.dart`
    (51 tests total).
  - `android/` — Kotlin DSL Gradle (`app/build.gradle.kts`,
    `settings.gradle.kts`), `MainActivity` (plain `FlutterActivity`;
    edge-to-edge is driven from Dart), manifest with
    `android:enableOnBackInvokedCallback="true"` for predictive back.
  - `assets/` — icons, screenshots.
- `.github/workflows/` — `test.yml` (`flutter analyze --no-fatal-infos` +
  `flutter test`), `build-debug.yml` (push/PR on `main`), 
  `build-release.yml` (tags `v*` / `wash-tracker-*`, `contents: write`).
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
  `shared_preferences`, `table_calendar`, `intl`, `file_picker`,
  `share_plus`, `flutter_animate`, `dynamic_color`, `cupertino_icons`.
- `pubspec.yaml` `version:` (`26.08.10+2`) is the single source of the
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
  focused month; average/median return `0.0` with fewer than 2 events.
- Import/export: CSV has a single `Date` header with `yyyy-MM-dd` rows;
  dates parse to local noon to avoid DST shifts; import replaces the
  current event list; `clearAllData` wipes store + state.
- Theme: `useMaterial3: true` always; `ColorScheme.fromSeed` per preset,
  overridden by system dynamic color on Android 12+ when available;
  `ThemeMode.system/light/dark` + 4 seed presets persisted.

## 5. UI / Material 3 rules

- Tonal surfaces (`surfaceContainer*`), never dual light/dark hard shadows;
  the legacy `NeumorphicContainer`/`NeumorphicButton` names are kept only
  as API-compatible shims over M3 `Card`/`FilledButton` — do not reintroduce
  neumorphic styling or `BoxShadow`-based elevation.
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
- Known debt (do not "fix" opportunistically): private identifier
  `_buildNeumorphicStatCard`, `applicationId`
  `com.example.me_he_lavadado_el_pelo_app` (still the template placeholder).

## 7. Agent workflow

1. inspect (read code, never assume) → 2. understand → 3. plan (todo list
   for 3+ step work) → 4. implement (minimal diff) → 5. `flutter analyze`
   → 6. `flutter test` → 7. review diff (`git status/diff`, no secrets) →
   8. report (facts + evidence, no marketing).

```bash
cd HairWashTracker
flutter pub get
flutter analyze              # must be clean
flutter test                 # 51 tests, must pass
flutter build apk --debug    # before declaring device-visible changes done
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
