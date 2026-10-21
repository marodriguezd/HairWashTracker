<div align="center">
  <img src="HairWashTracker/assets/icon.png" alt="Hair-Wash-Tracker-Logo" height="96" />
</div>

# Hair Wash Tracker

[![Lizenz: GPL-3.0-only](https://img.shields.io/badge/Lizenz-GPL--3.0--only-blue.svg)](LICENSE)

[English version](README.md) · [Versión en español](README_ES.md) · Deutsche Version · [Version française](README_FR.md) · [Versione italiana](README_IT.md) · [中文版](README_ZH.md)

Lokale Flutter-Anwendung zur Dokumentation der Haarwaschroutine. Waschtage
im Kalender eintragen, wöchentliche und monatliche Statistiken einsehen und
eine adaptive Empfehlung für die nächste Haarwäsche erhalten. Kein Konto,
keine Cloud: Die Daten bleiben auf dem Gerät.

<p align="center">
  <img src="HairWashTracker/assets/readme_home_light.png" width="45%" alt="Startbildschirm, helles Design">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_home_dark.png" width="45%" alt="Startbildschirm, dunkles Design">
</p>

## Funktionen

- Interaktiver Monatskalender; einen Tag antippen, um eine Wäsche einzutragen oder zu entfernen
- Prognostizierte Waschtage auf Grundlage des gespeicherten Verlaufs
- Wöchentliches Balkendiagramm und Monatszähler
- Adaptive Schätzung der nächsten Wäsche (EWMA-Intervall, Trend, Wochentag-Affinität)
- Helles, dunkles und System-Design; vier Seed-Presets (Warm Coral, Lavender
  Mist, Sage Mist, Ocean Blue) plus dynamische Android-Farben auf unterstützten Geräten
- Adaptive Navigation (untere Leiste auf Telefonen, seitliche Leiste auf großen Bildschirmen)
- Lokale Speicherung; versionierte JSON-Sicherung exportieren und wiederherstellen über den System-Teilen-Dialog (CSV-Sicherungen aus 1.0.x lassen sich weiterhin einlesen)

## Statistiken

<p align="center">
  <img src="HairWashTracker/assets/readme_stats_light.png" width="45%" alt="Statistikbildschirm, helles Design">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_stats_dark.png" width="45%" alt="Statistikbildschirm, dunkles Design">
</p>

## Technologie-Stack

- Flutter / Dart, Material 3
- `provider` für das State-Management
- `table_calendar` für die Kalenderansicht
- `shared_preferences` für die lokale Speicherung
- `dynamic_color` für dynamisches Android-Theming

## Erste Schritte

```bash
git clone https://github.com/marodriguezd/HairWashTracker.git
cd HairWashTracker/HairWashTracker
flutter pub get
flutter run
```

Qualitätssicherung:

```bash
flutter analyze
flutter test
```

## Kompatibilität

- Android (minSdk 24, targetSdk 36)
- Adaptive und monochrome Launcher-Icons enthalten
