# TO Best 🏋️

**نظام تدريب رياضي احترافي | Professional Training & Nutrition System**

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()

---

## About

TO Best is a complete Flutter mobile app for personal training management, built as a successor to MAZEN COACH PWA. It connects to a Google Apps Script backend and uses SQLite as an offline cache.

## Features

- 🔐 Auth (Login, Register, Pending approval flow)
- 🏋️ Workout tracking (UL, AP, FB, Arnold, PPL, Custom programs)
- 🥗 Nutrition logging with macros
- 📅 Attendance calendar
- 📊 Progress charts & PRs
- 💬 5 chat rooms
- 🛡️ Admin panel
- 💳 Subscription management
- 🎁 Referral system
- 🌐 Full AR/EN + RTL/LTR support

## Quick Start

See [docs/QUICKSTART.md](docs/QUICKSTART.md)

## Deployment

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## Documentation

See [docs/PROJECT_DOCUMENTATION.md](docs/PROJECT_DOCUMENTATION.md)

## Tech Stack

- Flutter 3.19+ / Dart 3.3+
- Riverpod 2.5 (State management)
- GoRouter 13 (Navigation)
- Dio 5 (HTTP)
- sqflite 2 (Local cache)
- fl_chart (Charts)
- flutter_animate (Animations)

## Build

```bash
flutter pub get
flutter build apk --release
```

See [codemagic.yaml](codemagic.yaml) for CI/CD configuration.
