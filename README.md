# HairWashTracker

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev/)

A simple and elegant Flutter application to help you track your hair washing schedule.

![HairWashTracker Demo](https://via.placeholder.com/800x450.png?text=HairWashTracker+App+Screenshot)

## About The Project

`HairWashTracker` is a cross-platform mobile application built with Flutter, designed for users who want to monitor and maintain a consistent hair washing routine. The app provides an intuitive calendar interface to mark wash days and offers insightful statistics to help you understand your habits. With local data storage and simple data management features, it's a private and efficient tool for personal care.

## Key Features

- **Interactive Calendar:** Easily tap any day to mark it as a hair wash day.
- **Statistics Tracking:** View total washes, as well as washes in the current week and month, on a dedicated stats page.
- **Local Data Persistence:** All your wash dates are securely saved on your device using `shared_preferences`.
- **Data Import/Export:** Backup and restore your data by exporting and importing your wash history as a `.csv` file.
- **Secure Data Deletion:** A confirmation dialog ensures you can safely clear all tracked data when needed.

## Technology Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Provider](https://pub.dev/packages/provider) (`ChangeNotifier`)
- **Local Storage:** [shared_preferences](https://pub.dev/packages/shared_preferences)
- **UI Components:** [table_calendar](https://pub.dev/packages/table_calendar)
- **Utilities:**
  - [intl](https://pub.dev/packages/intl) (Date Formatting)
  - [file_picker](https://pub.dev/packages/file_picker) (Data Import)
  - [share_plus](https://pub.dev/packages/share_plus) (Data Export)

## Architecture Overview

This project is built upon a clean and scalable architecture that adheres to **SOLID principles**, ensuring a high degree of maintainability and testability. State is managed centrally by an `AppController` using the `provider` package, which notifies the UI of any changes. The core logic is decoupled from the UI through the use of abstract classes for services like data persistence and file operations, following the Dependency Inversion Principle. This creates a clear separation of concerns between the UI (`pages`, `widgets`), state management (`providers`), and business logic (`services`).

## Project Structure

The codebase is organized into a clean, feature-driven directory structure that promotes separation of concerns.

```
lib/
├── models/
│   └── wash_event.dart
├── providers/
│   └── app_controller.dart
├── services/
│   ├── data_repository.dart
│   └── file_operations_service.dart
├── ui/
│   ├── pages/
│   │   ├── home_page.dart
│   │   └── stats_page.dart
│   └── widgets/
│       ├── app_drawer.dart
│       ├── calendar_widget.dart
│       ├── confirmation_dialog.dart
│       └── monthly_washes_widget.dart
├── utils/
│   └── statistics_calculator.dart
└── main.dart
```

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

Ensure you have the Flutter SDK installed on your machine. For installation instructions, please see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/your_username/HairWashTracker.git
    ```
2.  **Navigate to the project directory:**
    ```sh
    cd HairWashTracker/HairWashTracker
    ```
3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```
4.  **Run the application:**
    ```sh
    flutter run
    ```
