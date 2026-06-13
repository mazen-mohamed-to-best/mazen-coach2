# TO Best — Project Documentation

> نظام تدريب رياضي احترافي | Professional Training & Nutrition System  
> Version: 1.0.0 | Flutter 3.19+ | Backend: Google Apps Script

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Feature Set](#feature-set)
4. [Tech Stack](#tech-stack)
5. [Backend Integration (GAS)](#backend-integration)
6. [Data Models](#data-models)
7. [State Management](#state-management)
8. [Navigation](#navigation)
9. [Localization (AR/EN)](#localization)
10. [Theming](#theming)
11. [Offline & Sync](#offline--sync)
12. [Training Programs](#training-programs)
13. [Roles & Permissions](#roles--permissions)
14. [File Structure](#file-structure)

---

## Project Overview

**TO Best** is a full-featured mobile fitness application built with Flutter, designed to replace the MAZEN COACH PWA. It provides:

- Comprehensive workout tracking with all original training programs
- Nutrition logging with a built-in food database
- Attendance/commitment calendar
- Progress analytics with PR tracking and charts
- Real-time chat (5 rooms)
- Complete admin panel
- Subscription management with promo codes
- Referral system
- Full Arabic/English support with RTL/LTR

The backend remains Google Apps Script (GAS) with SQLite as a local cache-only layer.

---

## Architecture

```
TO Best Flutter App
├── Presentation Layer     (Screens, Widgets, Providers)
├── Business Logic Layer   (Services, Use Cases)
├── Data Layer             (Models, Local DB, API Service)
└── Core                   (Constants, Theme, Utils, Network)
```

**Design Patterns:**
- Feature-First folder structure
- Repository Pattern for data access
- Riverpod for state management (StateNotifier, Provider, StateProvider)
- Clean separation: API ↔ Services ↔ Providers ↔ UI

**Data Flow:**
```
UI → Provider → Service → API (GAS) or SQLite Cache
                ↓
          SQLite Cache (write-through)
                ↓
          Sync Queue (if offline)
                ↓
          Auto-flush on reconnect
```

---

## Feature Set

### 🔐 Authentication
- Login with email + password (GAS session token)
- Registration with optional referral code
- Account status flow: pending → active / rejected
- Force logout (server-triggered)
- Ban checking on login
- Secure secret key storage (base64 obfuscation)

### 🏋️ Workout
- **5 training programs**: UL, AP, FB, Arnold, PPL + Custom
- Full exercise database per session with warmup protocol
- Set logging: weight, reps, RPE, Epley 1RM calculation
- Rest timer with configurable duration
- Session history with PR detection
- Wakelock during session
- Exercise alternatives defined per exercise

### 🥗 Nutrition
- Built-in food database (18 common foods)
- Meal categorization: breakfast, lunch, dinner, snack
- Macros tracking: calories, protein, carbs, fat, fiber
- Progress rings and macro bars
- Water intake tracker
- Daily targets from user profile (nutritionTargets)
- Swipe to delete food entries

### 📅 Attendance
- Monthly calendar view with navigation
- 3 states per day: Gym 🟢, Absent 🔴, Rest 🔵
- Tap to cycle through states
- Monthly stats: gym days, absent, rest, commitment %
- Data synced to GAS backend

### 📊 Progress
- Total sessions, streak, total volume stats
- Personal Records (PR) with gold/silver/bronze medals
- fl_chart line chart for exercise 1RM progress
- Recent sessions list with PR indicator
- Exercise progress history

### 💬 Chat (5 Rooms)
- General group chat
- Announcements (admin only posting)
- Coach chat
- Support
- AI assistant (TO Best AI)
- Message reply, delete, edit, pin
- Auto-poll every 10 seconds
- Cached messages in SQLite
- Chat ban / mute system

### ⚙️ Settings
- Dark/light theme toggle
- Arabic/English language switch (RTL/LTR auto)
- Left-hand mode toggle
- Workout display settings (old values, Epley, RPE, rep suggestions)
- Wakelock toggle
- Water goal slider
- Connection setup (GAS URL + secret key)

### 👤 Profile
- Profile picture upload (base64 to GAS Google Drive)
- Name/phone editing
- Role badge display
- Subscription info
- Referral code + coin balance
- Password change

### 💳 Subscription
- Plan selection (loaded from GAS config)
- Payment method selection (bank transfer, STC Pay, cash)
- Promo code validation
- Subscription request submission
- Current subscription display

### 🛡️ Admin Panel
- **Users tab**: List all users, approve/reject pending, force logout, ban chat, delete account
- **Subscriptions tab**: View/approve/reject subscription requests
- **Promo Codes tab**: Create/delete codes with discount %
- **Ban tab**: View/unban banned identities, force logout all

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.19+ |
| State | Riverpod 2.5 |
| Navigation | GoRouter 13 + ShellRoute |
| HTTP Client | Dio 5.4 |
| Local DB | sqflite 2.3 |
| Settings | shared_preferences |
| Charts | fl_chart 0.68 |
| Animations | flutter_animate 4.5 |
| Images | cached_network_image |
| Media | image_picker, webview_flutter |
| Progress | percent_indicator |
| Utils | uuid, connectivity_plus, wakelock_plus |
| Notifications | flutter_local_notifications |
| Fonts | Cairo (Arabic), Poppins (English) |

---

## Backend Integration

All API calls go to the Google Apps Script WebApp URL via HTTP POST.

**Payload format:**
```json
{
  "payload": "{\"action\":\"LOGIN\",\"email\":\"...\",\"password\":\"...\",\"secret\":\"...\",\"sessionToken\":\"...\"}"
}
```

**Content-Type:** `application/x-www-form-urlencoded`

**Response format:**
```json
{"ok": true, "data": {...}}
{"ok": false, "err": "error_code"}
```

### API Actions (30+)

| Category | Actions |
|----------|---------|
| Auth | LOGIN, REGISTER, CHANGE_PASSWORD, PING, CHECK_BAN |
| User Data | FETCH_USER_DATA, FETCH_ALL_USERS, FULL_SYNC_PULL, UPDATE_USER_SHEET |
| Admin | ADMIN_UPDATE_USER, ADMIN_APPROVE, ADMIN_DELETE_USER, APPROVE_PROGRAM |
| Subscription | SUB_REQUEST, GET_SUB_REQUESTS, UPDATE_SUB_REQUEST, SUB_CONFIG |
| Chat | FETCH_MSGS, SEND_MSG, DELETE_MSG, EDIT_MSG, PIN_MSG, UNPIN_MSG, GET_PINNED, CHAT_BAN, CHAT_MUTE, SEND_FILE_MSG |
| Promo | PROMO_CHECK, PROMO_CREATE, PROMO_LIST, PROMO_DELETE |
| Guest | GUEST_CREATE, GUEST_LIST, GUEST_DELETE |
| Profile | SAVE_PROFILE_PIC |
| Security | FORCE_LOGOUT_USER, FORCE_LOGOUT_ALL, BAN_IDENTITY, UNBAN_IDENTITY, LIST_BANNED |
| Referral | GET_REFERRAL_STATS |

---

## Data Models

### UserModel
```dart
uid, email, name, phone, role, status, programId, programDays,
pictureUrl, referralCode, referralCoins, subscriptionInfo,
nutritionTargets, gymDays, forceLogoutToken, chatBanned, chatMuteUntil
```

### WorkoutLogModel
```dart
id, uid, date, sessionName, programId,
exercises: [ExerciseLog{name, sets: [WorkoutSetLog{set, weight, reps, rpe, epley}], isPR}],
durationMinutes, note, timestamp
```

### FoodLogEntry
```dart
id, uid, date, mealType, foodName, amount,
calories, protein, carbs, fat, fiber, timestamp
```

### ChatMessageModel
```dart
id, roomId, uid, senderName, senderPicture, text,
fileUrl, fileType, timestamp, deleted, edited, isPinned
```

### SubscriptionRequestModel
```dart
id, uid, userName, userEmail, planName, amount,
currency, paymentMethod, proofUrl, status, promoCode,
discountPercent, createdAt, processedAt
```

---

## State Management (Riverpod)

### Core Providers
```dart
databaseHelperProvider    // SQLite instance
apiServiceProvider        // Dio HTTP client
syncServiceProvider       // Offline queue + auto-sync
authServiceProvider       // Auth operations
workoutServiceProvider    // Workout CRUD
nutritionServiceProvider  // Nutrition CRUD
attendanceServiceProvider // Attendance CRUD
adminServiceProvider      // Admin operations
chatServiceProvider       // Chat operations
```

### App State Providers
```dart
currentUserProvider   // StateProvider<UserModel?> — logged-in user
themeModeProvider     // StateProvider<ThemeMode>
localeProvider        // StateProvider<Locale?>
settingsProvider      // StateNotifierProvider<SettingsNotifier, AppSettings>
routerProvider        // GoRouter instance
```

---

## Navigation

```
/login          → LoginScreen
/register       → RegisterScreen
/setup          → SetupScreen (GAS connection config)
/pending        → PendingScreen (awaiting approval)
/ (ShellRoute)
  /             → HomeScreen
  /workout      → WorkoutScreen
  /workout/session → WorkoutSessionScreen
  /nutrition    → NutritionScreen
  /attendance   → AttendanceScreen
  /progress     → ProgressScreen
  /chat         → ChatScreen
  /chat/room    → ChatRoomScreen
  /settings     → SettingsScreen
  /admin        → AdminScreen
  /profile      → ProfileScreen
  /subscription → SubscriptionScreen
```

**Auth redirect rules:**
- Not logged in → `/login`
- Logged in + pending → `/pending`
- Logged in + active → allowed to navigate normally
- On login routes while logged in → redirect to `/`

---

## Localization

File: `lib/l10n/app_localizations.dart`

All strings are in one class with `_s(ar, en)` helper method.

**Supported locales:** `ar` (default, RTL), `en` (LTR)

**Directionality:** Auto-set by `Directionality` widget in `main.dart` based on selected locale.

**RTL fonts:** Cairo (Arabic), Poppins (English) — both declared in pubspec.yaml.

**Date/time:** Formatted per locale using `intl` package.

---

## Theming

File: `lib/core/theme/app_theme.dart`

### Color Palette
| Token | Dark | Light |
|-------|------|-------|
| Primary | `#4CAF50` (Green) | `#4CAF50` |
| Background | `#0D0D0D` | `#F5F5F5` |
| Surface | `#1A1A1A` | `#FFFFFF` |
| Card | `#222222` | `#FFFFFF` |

### Gradients
- `AppGradients.primaryGradient` — Green gradient header cards
- `AppGradients.heroGradient` — Deep green for session card
- `AppGradients.darkCardGradient` — Dark card shimmer

---

## Offline & Sync

**SyncService** manages:
1. **Online detection**: `connectivity_plus` package
2. **Auto-sync timer**: 30-second interval when online
3. **Sync queue**: SQLite `sync_queue` table
4. **Queue flush**: On reconnect and periodic timer
5. **Full sync pull**: `FULL_SYNC_PULL` GAS action seeds all user data

**Queue flow:**
```
User action → Service method → API call attempt
               ↓ (if offline)
        Add to sync_queue table
               ↓ (on reconnect)
        Flush queue → API calls → Remove from queue
```

**SQLite Tables:**
- `users` — User profiles cache
- `workout_logs` — Training session logs
- `food_logs` — Nutrition entries
- `attendance` — Attendance records
- `sync_queue` — Offline operation queue
- `kv_store` — Key-value pairs (water intake, etc.)
- `chat_messages` — Recent chat cache (60 messages per room)
- `custom_exercises` — User-defined exercises

---

## Training Programs

### UL (Upper/Lower) — 4 days/week
- Upper A, Lower A, Upper B, Lower B

### AP (Anterior/Posterior) — 4 days/week
- Anterior A, Posterior A, Anterior B, Posterior B

### FB (Full Body) — 3 days/week
- Full Body #1, Full Body #2, Full Body #3

### Arnold — 5 days/week
- Chest & Back, Shoulders & Arms, Lower A, Upper, Lower B

### PPL (Push/Pull/Legs) — 5 days/week
- PUSH, PULL, Lower A, Upper, Lower B

### Warmup Protocol (All programs)
6 exercises: Pallof Press, Pallof Rotation, External Rotation, Scapula Push Plus, Neck Extension, Neck Flexion

---

## Roles & Permissions

| Role | Access |
|------|--------|
| `superadmin` | Full access including other admins |
| `admin` | Admin panel, user management, subscriptions |
| `coach` | All trainee features + coach chat |
| `trainee` | Workout, nutrition, attendance, progress, chat |
| `viewer` | Read-only access |

**Admin panel tabs:**
- Users (approve/reject/ban/delete)
- Subscriptions (approve/reject requests)
- Promo codes (create/delete)
- Ban list (unban, force logout all)

---

## File Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # All app constants
│   │   └── api_actions.dart        # GAS action strings
│   ├── theme/
│   │   └── app_theme.dart          # Material3 themes + colors
│   ├── network/
│   │   └── api_service.dart        # Dio HTTP client
│   ├── utils/
│   │   ├── router.dart             # GoRouter config
│   │   └── secure_settings.dart    # Secret key storage
│   └── local_db/
│       └── database_helper.dart    # SQLite CRUD
├── models/
│   ├── user_model.dart
│   ├── workout_log_model.dart
│   ├── food_log_model.dart
│   ├── chat_message_model.dart
│   └── subscription_model.dart
├── services/
│   ├── auth_service.dart
│   ├── sync_service.dart
│   ├── workout_service.dart
│   ├── nutrition_service.dart
│   ├── attendance_service.dart
│   ├── admin_service.dart
│   └── chat_service.dart
├── providers/
│   └── app_providers.dart          # All Riverpod providers
├── data/
│   └── training_config.dart        # Programs + exercises DB
├── l10n/
│   └── app_localizations.dart      # AR/EN strings
└── features/
    ├── auth/presentation/screens/
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   ├── pending_screen.dart
    │   └── setup_screen.dart
    ├── home/presentation/
    │   ├── screens/home_screen.dart
    │   ├── screens/main_shell.dart
    │   └── widgets/...
    ├── workout/presentation/screens/
    │   ├── workout_screen.dart
    │   └── workout_session_screen.dart
    ├── nutrition/presentation/
    │   ├── screens/nutrition_screen.dart
    │   └── widgets/...
    ├── attendance/presentation/screens/attendance_screen.dart
    ├── progress/presentation/screens/progress_screen.dart
    ├── chat/presentation/screens/
    │   ├── chat_screen.dart
    │   └── chat_room_screen.dart
    ├── settings/presentation/screens/settings_screen.dart
    ├── admin/presentation/screens/admin_screen.dart
    ├── profile/presentation/screens/profile_screen.dart
    └── subscription/presentation/screens/subscription_screen.dart
```
