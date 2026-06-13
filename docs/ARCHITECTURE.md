# TO Best — Architecture Guide

## Overview

TO Best is a Flutter-based fitness coaching PWA/mobile app. It is a **client-only offline-first app** where **Google Apps Script (GAS)** serves as the sole backend and source of truth. The device's SQLite database is used exclusively as a read-through cache layer.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.19+, Dart 3.3+ |
| State Management | Riverpod 2.5 (code-gen free) |
| Navigation | GoRouter 13 |
| Network | Dio 5 |
| Local DB | sqflite 2 (SQLite) |
| Preferences | shared_preferences |
| Connectivity | connectivity_plus |
| Charts | fl_chart, percent_indicator |
| Animations | flutter_animate, lottie |
| Fonts | Cairo (AR) + Poppins (EN) via Google Fonts |
| Build CI | Codemagic |

---

## Directory Structure

```
lib/
├── main.dart                      # App entry point, ProviderScope, theme, locale
├── core/
│   ├── constants/
│   │   ├── app_constants.dart     # SharedPrefs keys, role names, status codes
│   │   └── api_actions.dart       # All GAS action string constants
│   ├── local_db/
│   │   └── database_helper.dart   # SQLite CRUD — all DB access goes through here
│   ├── network/
│   │   └── api_service.dart       # GAS HTTP client (form-urlencoded + HMAC-SHA256)
│   ├── theme/
│   │   └── app_theme.dart         # AppColors, AppGradients, AppTheme (light+dark)
│   └── utils/
│       └── secure_settings.dart   # Encrypted storage for GAS URL + secret key
├── data/
│   └── training_config.dart       # All 5 programs × all sessions × all exercises
├── features/                      # Feature-first folder layout
│   ├── auth/
│   ├── home/
│   ├── workout/
│   ├── nutrition/
│   ├── attendance/
│   ├── progress/
│   ├── chat/
│   ├── settings/
│   ├── subscription/
│   ├── admin/
│   └── profile/
├── l10n/
│   └── app_localizations.dart     # Inline AR/EN strings (no ARB files)
├── models/                        # Pure data classes with fromMap/toMap
├── providers/
│   └── app_providers.dart         # All Riverpod providers (DI graph)
├── router/
│   └── app_router.dart            # GoRouter definition with role-based guards
├── services/                      # Business logic — no direct UI dependencies
│   ├── workout_service.dart
│   ├── nutrition_service.dart
│   ├── attendance_service.dart
│   ├── chat_service.dart
│   ├── admin_service.dart
│   └── sync_service.dart
└── widgets/                       # Shared/reusable widgets
```

---

## Data Flow

```
GAS (source of truth)
       ↕  HTTPS form-urlencoded POST
   ApiService (Dio)
       ↕
   SyncService           ← offline queue in SQLite
       ↕
   DatabaseHelper (SQLite)   ← read cache
       ↕
   Riverpod Providers    ← reactive state
       ↕
   Flutter UI
```

### Write path (online)
1. User performs action → Service method called
2. Service calls `SyncService.queueOrPush()`
3. If online: GAS API call → on success, SQLite updated
4. If offline: data written to `sync_queue` table → auto-flushed when online

### Write path (offline)
1. Data saved to SQLite immediately
2. Added to `sync_queue` table with `action`, `key`, `data`, `uid`
3. `SyncService` timer (30s) and `connectivity_plus` listener flush queue when online

### Read path
1. All reads from SQLite first
2. Background sync pulls fresh data from GAS → overwrites SQLite cache
3. UI rebuilds via Riverpod state

---

## GAS API Protocol

All API calls use HTTP POST with `application/x-www-form-urlencoded` body:

```
payload=<URL-encoded JSON>
```

The JSON payload must include:
- `action` — one of `ApiActions.*` constants
- `sessionToken` — stored in SharedPreferences after login
- Any action-specific fields

HMAC-SHA256 authentication: the secret key is stored in encrypted storage (`secure_settings.dart`) and prepended/hashed per the GAS contract.

---

## State Management (Riverpod)

All providers are defined in `lib/providers/app_providers.dart`:

| Provider | Type | Purpose |
|---|---|---|
| `currentUserProvider` | `StateProvider<UserModel?>` | Logged-in user |
| `themeModeProvider` | `StateProvider<ThemeMode>` | Light/Dark |
| `localeProvider` | `StateProvider<Locale?>` | AR/EN |
| `settingsProvider` | `StateNotifierProvider` | App settings (wakelock, RPE, etc.) |
| `apiServiceProvider` | `Provider<ApiService>` | Singleton HTTP client |
| `databaseHelperProvider` | `Provider<DatabaseHelper>` | Singleton DB |
| `syncServiceProvider` | `Provider<SyncService>` | Offline sync |
| `workoutServiceProvider` | `Provider<WorkoutService>` | Workout CRUD |
| `nutritionServiceProvider` | `Provider<NutritionService>` | Food log CRUD |
| `attendanceServiceProvider` | `Provider<AttendanceService>` | Attendance CRUD |
| `chatServiceProvider` | `Provider<ChatService>` | Chat read/write |
| `adminServiceProvider` | `Provider<AdminService>` | Admin operations |

---

## Roles & Access Control

| Role | Value | Access |
|---|---|---|
| Super Admin | `superAdmin` | Everything + user deletion |
| Admin | `admin` | User management, subscriptions, promos |
| Coach | `coach` | Assign programs, view all trainees |
| Trainee | `trainee` | Own workouts, nutrition, attendance |
| Viewer | `viewer` | Read-only view |

Routes are guarded in `app_router.dart` using `GoRouter.redirect`. Unauthorized navigation returns to `/home`.

---

## Training Programs

Defined in `lib/data/training_config.dart`:

| Program ID | Name | Days | Sessions |
|---|---|---|---|
| `UL` | Upper/Lower | 4 | Upper A, Lower A, Upper B, Lower B |
| `AP` | Anterior/Posterior | 4 | Anterior A, Posterior A, Anterior B, Posterior B |
| `FB` | Full Body | 3 | Full Body #1, #2, #3 |
| `ARNOLD` | Arnold | 5 | Chest & Back, Shoulders & Arms, Lower A, Upper, Lower B |
| `PPL` | Push/Pull/Legs | 5 | PUSH, PULL, Lower A, Upper, Lower B |
| `CUSTOM` | Custom | 3–6 | User-defined |

---

## Offline-First Design

- Every write is optimistically saved to SQLite before any API call
- `sync_queue` table accumulates failed pushes
- Auto-flush triggers on: connectivity restored, app foreground, every 30s timer
- Full sync pull on login and on `RefreshIndicator` drag

---

## Localization

Handled entirely in `lib/l10n/app_localizations.dart` — no ARB files. The `_s(ar, en)` helper switches based on `locale.languageCode`. RTL layout is handled automatically by Flutter's `Directionality` widget driven by `localeProvider`.

---

## Build Configuration

See `codemagic.yaml` for:
- **`android-release`** — AAB for Play Store (triggers on git tag)
- **`android-debug`** — APK for testing (triggers on push to main)
- **`ios-release`** — IPA for App Store via TestFlight (triggers on release/* tag)

Fonts (Cairo + Poppins) are **not committed** to the repo. They are downloaded by the CI pre-build script from Google Fonts at build time.
