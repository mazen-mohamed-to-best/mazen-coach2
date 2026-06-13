# TO Best — Flutter Fitness App

Flutter mobile app for the "TO Best" fitness coaching platform. Complete offline-first app with Google Apps Script backend.

## Project Layout

```
artifacts/to-best-flutter/     ← Flutter project root
├── lib/                        ← All Dart source
├── android/                    ← Android native project
├── ios/                        ← iOS native project
├── assets/
│   ├── fonts/                  ← Cairo + Poppins (download at build time, not committed)
│   ├── icons/                  ← App icons (placeholder — replace before release)
│   └── lottie/                 ← Lottie animations
├── docs/                       ← Documentation
│   ├── ARCHITECTURE.md         ← System architecture & design decisions
│   ├── GAS_CONTRACT.md         ← GAS API action reference (all payloads/responses)
│   └── BUILD_GUIDE.md          ← Build, CI/CD, and release instructions
└── codemagic.yaml              ← CI: android-release, android-debug, ios-release
```

## Stack

- **Flutter** 3.19.6 / **Dart** 3.3+
- **State**: Riverpod 2.5
- **Navigation**: GoRouter 13
- **Network**: Dio 5
- **Local DB**: sqflite 2 (SQLite)
- **Backend**: Google Apps Script (GAS) — source of truth

## Running Locally

```bash
cd artifacts/to-best-flutter

# Install font files first (not committed)
mkdir -p assets/fonts assets/icons
curl -fsSL "https://github.com/google/fonts/raw/main/ofl/cairo/Cairo%5Bslnt%2Cwght%5D.ttf" -o assets/fonts/Cairo-Regular.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Cairo-Medium.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Cairo-SemiBold.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Cairo-Bold.ttf
curl -fsSL "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" -o assets/fonts/Poppins-Regular.ttf
cp assets/fonts/Poppins-Regular.ttf assets/fonts/Poppins-Medium.ttf
cp assets/fonts/Poppins-Regular.ttf assets/fonts/Poppins-SemiBold.ttf
cp assets/fonts/Poppins-Regular.ttf assets/fonts/Poppins-Bold.ttf
printf '\x89PNG\r\n\x1a\n' > assets/icons/icon_dark.png
cp assets/icons/icon_dark.png assets/icons/icon_light.png

flutter pub get
flutter run
```

## Features

- **Auth**: Login, register, change password, force logout, identity ban
- **Workout**: 5 programs (UL, AP, FB, Arnold, PPL), session logger, rest timer, RPE, Epley 1RM, PRs
- **Nutrition**: Food log per meal, macros tracker, water tracker, daily targets
- **Attendance**: Monthly calendar, gym/rest/absent marking, commitment stats
- **Progress**: PR charts, volume trends, session history, Google Drive video playback
- **Chat**: 5 rooms (General, Announcements, Coach, Support, AI), pin/delete/edit, file/image sharing
- **Subscription**: Plans, promo codes, referral system, coins
- **Admin**: User management, approval, program assignment, sub requests, promo/guest codes, ban management
- **Settings**: Dark/light mode, AR/EN language, RTL/LTR, left-hand mode, wakelock, RPE/1RM display

## Roles

`superAdmin` → `admin` → `coach` → `trainee` → `viewer`

## Codemagic Workflows

| Workflow | When | Output |
|---|---|---|
| `android-debug` | Push to any branch | Debug APK |
| `android-release` | Push to main / git tag | AAB (release) / APK (debug) |
| `ios-release` | Tag on `release/*` | IPA → TestFlight |

## Important Files

- `lib/data/training_config.dart` — all exercise definitions for all programs/sessions
- `lib/providers/app_providers.dart` — full Riverpod DI graph
- `lib/core/local_db/database_helper.dart` — all SQLite schema and CRUD
- `lib/core/network/api_service.dart` — GAS HTTP client
- `lib/services/sync_service.dart` — offline queue + auto-sync
- `lib/router/app_router.dart` — role-based navigation guards
- `lib/l10n/app_localizations.dart` — all AR/EN strings

## User Preferences

- Cairo font for Arabic, Poppins for English
- Fonts are NOT committed — downloaded at CI build time
- App icons are placeholders — replace `assets/icons/icon_dark.png` and `icon_light.png` with real 1024×1024 PNGs before release
- GAS URL and secret key are set by admin via the in-app Setup screen (first-run flow)
- Android package ID: `com.tobest.app` | iOS bundle ID: `com.tobest.app`
