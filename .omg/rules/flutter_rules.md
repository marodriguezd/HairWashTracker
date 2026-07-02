---
description: Rules for Flutter/Dart development in this codebase
globs: "HairWashTracker/lib/**"
alwaysApply: true
---

# Flutter & Dart Guidelines

- **State Management**: Utilize `provider` packages where appropriate, keeping logic decoupled from the UI.
- **Linting**: Ensure code conforms to `flutter_lints` rules defined in `analysis_options.yaml`.
- **Animations**: Use `flutter_animate` for UI motion to keep interactions smooth and premium.
- **Resource Management**: Properly dispose of controllers, streams, and state listeners when widgets are destroyed.
