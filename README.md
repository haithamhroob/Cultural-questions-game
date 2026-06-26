# Cultural Quest 🌍🏆

Cultural Quest is a cultural quiz application built with Flutter. It tests players' knowledge across a variety of fields — including History, Geography, Science, Sports, Islamic Culture, Arabic Language, and Mathematics — through a fun and interactive experience.

## Features ✨

- **200 diverse questions** spread across 20 progressive difficulty levels.
- **Level progression system** — players must achieve a passing score before unlocking the next level.
- **Multi-player support** — multiple players can be added, with each player's progress saved independently.
- **Fully offline** — no internet connection required; all data is stored locally on the device.
- **Modern UI** — a clean, attractive interface with full Arabic (RTL) support.

## Technologies Used 🛠️

- **Flutter** (Material 3)
- **Dart**
- **Provider** — state management
- **shared_preferences** — local data persistence
- **google_fonts** — custom typography

## Getting Started 🚀

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Clone the repository.
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application on an emulator or physical device:
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── main.dart              # App entry point and theme configuration
├── data/                  # Question banks and seed data
├── models/                # Data models (e.g., Question, Player)
├── screens/               # UI screens (profile setup, dashboard, quiz, etc.)
└── services/              # Business logic (authentication, progress tracking)
```

---
*Developed by Haitham using Flutter & Dart.*
