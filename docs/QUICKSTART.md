# TO Best — Quick Start Guide

> Get the app running in under 10 minutes.

---

## 1. Clone & Install

```bash
# Clone or download the project
git clone <your-repo-url> to-best-flutter
cd to-best-flutter

# Install Flutter dependencies
flutter pub get
```

---

## 2. Add Required Assets

```bash
# Create asset directories
mkdir -p assets/fonts assets/icons assets/lottie

# Option A: Use placeholder files (for quick testing)
touch assets/fonts/Cairo-Regular.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Cairo-Medium.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Cairo-SemiBold.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Cairo-Bold.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Poppins-Regular.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Poppins-Medium.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Poppins-SemiBold.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Poppins-Bold.ttf
touch assets/icons/icon_dark.png assets/icons/icon_light.png

# Option B: Download real fonts (recommended)
# Download Cairo & Poppins from fonts.google.com and place TTF files in assets/fonts/
```

---

## 3. Run the App

```bash
# Check connected devices
flutter devices

# Run on device/emulator
flutter run

# Run with specific device
flutter run -d <device-id>
```

---

## 4. First-Time App Setup

When the app launches:

1. **Tap** "إعداد الاتصال" (Connection Setup) on the login screen
2. **Enter** your Google Apps Script WebApp URL
3. **Enter** your Secret Key
4. **Tap** "اختبار الاتصال" to test
5. **Tap** "حفظ" to save
6. **Return** to login and sign in

---

## 5. Quick Feature Test

| Feature | How to Test |
|---------|-------------|
| Login | Enter credentials → tap دخول |
| Workout | Home → session card → tap بدأ التمرين |
| Log a set | Enter weight + reps → tap ✓ |
| Nutrition | Nutrition tab → + → search food → select → save |
| Attendance | Attendance tab → tap any day |
| Chat | Chat tab → General → type message |
| Admin | Drawer → الإدارة (admin/superadmin only) |

---

## 6. Language & Theme

- **Language**: Settings → Language toggle (AR ↔ EN)
- **Theme**: Settings → Dark Mode toggle
- RTL/LTR switches automatically with language

---

## 7. Build APK (Quick)

```bash
# Debug APK (no signing needed)
flutter build apk --debug

# Find APK at:
# build/app/outputs/flutter-apk/app-debug.apk
```

---

## 8. Common Commands

```bash
# Analyze code
flutter analyze

# Clean build cache
flutter clean && flutter pub get

# Update packages
flutter pub upgrade

# View devices
flutter devices

# Build release (requires key.properties setup)
flutter build apk --release
flutter build appbundle --release
```

---

## 9. Project Structure (Quick Map)

```
lib/
├── main.dart               # App entry point
├── core/constants/         # App constants & API actions
├── core/theme/             # Material3 dark/light themes
├── core/network/           # Dio HTTP client
├── core/local_db/          # SQLite helper
├── models/                 # Data models
├── services/               # Business logic (API + DB)
├── providers/              # Riverpod state providers
├── data/training_config.dart  # All exercises & programs
├── l10n/app_localizations.dart # AR/EN strings
└── features/               # UI screens per feature
    ├── auth/               # Login, Register, Setup, Pending
    ├── home/               # Dashboard + navigation shell
    ├── workout/            # Program view + session screen
    ├── nutrition/          # Food logging + macros
    ├── attendance/         # Monthly calendar
    ├── progress/           # Stats + charts + PRs
    ├── chat/               # 5 chat rooms
    ├── settings/           # App settings
    ├── admin/              # Admin panel (users/subs/promo/ban)
    ├── profile/            # User profile
    └── subscription/       # Plan selection + payment
```

---

## 10. GAS Connection Test

To verify your GAS backend works:

```bash
# Replace with your actual URL and key
curl -X POST "YOUR_GAS_WEBAPP_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d 'payload=%7B%22action%22%3A%22PING%22%2C%22secret%22%3A%22YOUR_SECRET%22%7D'

# Expected: {"ok":true}
```

---

## Done! 🎉

Your **TO Best** app is ready. For production deployment, see [DEPLOYMENT.md](./DEPLOYMENT.md).

For full technical details, see [PROJECT_DOCUMENTATION.md](./PROJECT_DOCUMENTATION.md).
