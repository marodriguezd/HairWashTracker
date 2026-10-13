<div align="center">
  <img src="HairWashTracker/assets/icon.png" alt="logotipo de Hair Wash Tracker" height="96" />
</div>

# Hair Wash Tracker

[![Licencia: GPL-3.0-only](https://img.shields.io/badge/Licencia-GPL--3.0--only-blue.svg)](LICENSE)

[English version](README.md) · Versión en español · [Deutsche Version](README_DE.md) · [Version française](README_FR.md) · [Versione italiana](README_IT.md) · [中文版](README_ZH.md)

Aplicación Flutter local para llevar el registro de lavados de cabello. Marca
los días de lavado en un calendario, consulta estadísticas semanales y
mensuales, y recibe una predicción adaptativa del próximo lavado recomendado.
Sin cuentas ni nube: los datos permanecen en el dispositivo.

<p align="center">
  <img src="HairWashTracker/assets/readme_home_light.png" width="45%" alt="Pantalla principal, tema claro">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_home_dark.png" width="45%" alt="Pantalla principal, tema oscuro">
</p>

## Características

- Calendario mensual interactivo; toca un día para registrar o quitar un lavado
- Fechas de lavado previstas a partir del historial registrado
- Gráfico de barras semanal y contadores mensuales
- Estimación adaptativa del próximo lavado (intervalo EWMA, tendencia y
  afinidad por día de la semana)
- Temas claro, oscuro y automático; cuatro presets (Warm Coral, Lavender
  Mist, Sage Mist, Ocean Blue) más color dinámico de Android en dispositivos
  compatibles
- Navegación adaptativa (barra inferior en móviles, rail lateral en pantallas
  grandes)
- Persistencia local; importación y exportación CSV y JSON, con envío de
  exportaciones mediante el diálogo de compartir del sistema

## Estadísticas

<p align="center">
  <img src="HairWashTracker/assets/readme_stats_light.png" width="45%" alt="Pantalla de estadísticas, tema claro">
  &nbsp;&nbsp;
  <img src="HairWashTracker/assets/readme_stats_dark.png" width="45%" alt="Pantalla de estadísticas, tema oscuro">
</p>

## Tecnologías

- Flutter / Dart, Material 3
- `provider` para la gestión del estado
- `table_calendar` para la vista del calendario
- `shared_preferences` para el almacenamiento local
- `dynamic_color` para el color dinámico de Android

## Empezando

```bash
git clone https://github.com/marodriguezd/HairWashTracker.git
cd HairWashTracker/HairWashTracker
flutter pub get
flutter run
```

Controles de calidad:

```bash
flutter analyze
flutter test
```

## Compatibilidad

- Android (minSdk 24, targetSdk 36)
- Iconos adaptativos y monocromáticos incluidos
