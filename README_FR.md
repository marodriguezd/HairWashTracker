<div align="center">
  <img src="HairWashTracker/assets/icon.png" alt="logo Hair Wash Tracker" height="96" />
</div>

# Hair Wash Tracker

[![Licence : GPL-3.0-only](https://img.shields.io/badge/Licence-GPL--3.0--only-blue.svg)](LICENSE)

[English version](README.md) · [Versión en español](README_ES.md) · [Deutsche Version](README_DE.md) · Version française · [Versione italiana](README_IT.md) · [中文版](README_ZH.md)

Application Flutter locale pour suivre sa routine de shampoings. Notez les
jours de lavage sur un calendrier, consultez des statistiques hebdomadaires
et mensuelles, et recevez une prévision adaptative du prochain lavage
recommandé. Ni compte, ni cloud : les données restent sur l'appareil.

<p align="center">
  <img src="HairWashTracker/assets/readme_home_light.png" width="45%" alt="Écran d'accueil, thème clair">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_home_dark.png" width="45%" alt="Écran d'accueil, thème sombre">
</p>

## Fonctionnalités

- Calendrier mensuel interactif ; touchez un jour pour enregistrer ou retirer un lavage
- Dates de lavage prévues à partir de l'historique enregistré
- Graphique hebdomadaire en barres et compteurs mensuels
- Estimation adaptative du prochain lavage (intervalle EWMA, tendance, affinité par jour de semaine)
- Thèmes clair, sombre et système ; quatre préréglages (Warm Coral, Lavender
  Mist, Sage Mist, Ocean Blue) plus couleur dynamique Android sur les appareils compatibles
- Navigation adaptative (barre inférieure sur téléphone, rail latéral sur grand écran)
- Persistance locale ; import/export CSV et JSON, partage des exports via la feuille de partage système

## Statistiques

<p align="center">
  <img src="HairWashTracker/assets/readme_stats_light.png" width="45%" alt="Écran de statistiques, thème clair">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_stats_dark.png" width="45%" alt="Écran de statistiques, thème sombre">
</p>

## Pile technologique

- Flutter / Dart, Material 3
- `provider` pour la gestion d'état
- `table_calendar` pour la vue calendrier
- `shared_preferences` pour le stockage local
- `dynamic_color` pour le thème dynamique Android

## Démarrage

```bash
git clone https://github.com/marodriguezd/HairWashTracker.git
cd HairWashTracker/HairWashTracker
flutter pub get
flutter run
```

Contrôles qualité :

```bash
flutter analyze
flutter test
```

## Compatibilité

- Android (minSdk 24, targetSdk 36)
- Icônes de lancement adaptatives et monochromes incluses
