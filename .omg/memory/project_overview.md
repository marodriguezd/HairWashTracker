# Project Overview: Hair Wash Tracker

## Tech Stack
- **Framework**: Flutter (Dart >=3.0.0 <4.0.0)
- **Key Dependencies**:
  - `shared_preferences` for local storage persistence.
  - `table_calendar` for displaying history/schedules.
  - `provider` for state management.
  - `flutter_animate` for UI animations.
  - `share_plus` for sharing wash reports (migrated from deprecated methods to `SharePlus.instance.share`).
  - `file_picker` for importing/exporting data.

## Project Structure
- `lib/models/`: Data models (e.g. `WashEvent`, `AppThemeMode`, `AppPresetTheme`).
- `lib/providers/`: State management providers (`AppController`).
- `lib/services/`: Services for storage/utilities (`IDataRepository`, `IFileOperations`).
- `lib/ui/`: Presentation layer, screens, widgets (featuring Material You theme presets selector).
- `lib/utils/`: Formatting and helper utilities (featuring dynamic theme/gradient generators in `AppTheme` and interval analytics in `StatisticsCalculator`).
