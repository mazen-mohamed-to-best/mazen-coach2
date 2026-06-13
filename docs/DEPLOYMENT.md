# TO Best — Deployment Guide

---

## Prerequisites

- Flutter SDK ≥ 3.19.6
- Dart SDK ≥ 3.3.0
- Android Studio / VS Code with Flutter extension
- Codemagic account (for CI/CD builds)
- Active Google Apps Script (GAS) WebApp deployment
- Android keystore (for release builds)

---

## Step 1: Google Apps Script Setup

Your GAS backend must be deployed as a Web App with "Execute as: Me" and "Who has access: Anyone".

### Required GAS Actions
Ensure your `Code.gs` handles all 30+ actions defined in `lib/core/constants/api_actions.dart`.

### Obtaining the WebApp URL and Secret Key
1. Open your GAS project
2. Deploy → New Deployment → Web App
3. Copy the deployment URL (e.g., `https://script.google.com/macros/s/AKfy.../exec`)
4. Note your `SECRET_KEY` from the GAS script properties

---

## Step 2: Configure the App

### In-App Setup (First Launch)
1. Launch the app
2. Tap "إعداد الاتصال" on the login screen
3. Enter:
   - **WebApp URL**: Your GAS deployment URL
   - **Secret Key**: Your GAS secret key
4. Tap "اختبار الاتصال" to verify
5. Tap "حفظ"

These are stored securely in SharedPreferences on the device.

---

## Step 3: Android Keystore Setup

### Generate a new keystore
```bash
keytool -genkey -v \
  -keystore to-best-release.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias to_best_key
```

### Create `android/key.properties` (local development only, do NOT commit)
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=to_best_key
storeFile=/path/to/to-best-release.jks
```

---

## Step 4: Codemagic CI/CD Setup

### 4.1 Connect Repository
1. Sign in to [Codemagic](https://codemagic.io)
2. Add your repository (GitHub/GitLab/Bitbucket)
3. Select this project

### 4.2 Configure Keystore in Codemagic
1. Go to **Settings → Teams → [Your Team] → Code signing identities**
2. Upload your `.jks` keystore file
3. Note the variable names Codemagic assigns

### 4.3 Add Environment Variables in Codemagic
In your workflow's **Environment variables**:

| Variable | Value | Secret |
|----------|-------|--------|
| `CM_KEYSTORE` | Base64-encoded keystore | ✅ |
| `CM_KEYSTORE_PASSWORD` | Keystore password | ✅ |
| `CM_KEY_ALIAS` | Key alias | ✅ |
| `CM_KEY_PASSWORD` | Key password | ✅ |

Encode your keystore:
```bash
base64 -i to-best-release.jks | pbcopy  # macOS
base64 to-best-release.jks | xclip      # Linux
```

### 4.4 Create Environment Variable Groups in Codemagic
- `keystore_credentials` → Add all keystore vars above
- `google_play` → (Optional) For Google Play automatic publishing

### 4.5 Trigger a Build
- Push to `main` branch → triggers Android APK (debug)
- Push a tag (e.g., `v1.0.0`) → triggers Android App Bundle (release)

---

## Step 5: Font Assets (Required Before Build)

The fonts must exist in `assets/fonts/` before building. The Codemagic script downloads them automatically. For local builds:

```bash
mkdir -p assets/fonts assets/icons

# Download Cairo from Google Fonts
curl -L "https://fonts.google.com/download?family=Cairo" -o /tmp/cairo.zip
unzip /tmp/cairo.zip -d /tmp/cairo/
cp /tmp/cairo/Cairo-Regular.ttf assets/fonts/
cp /tmp/cairo/Cairo-Medium.ttf assets/fonts/
cp /tmp/cairo/Cairo-SemiBold.ttf assets/fonts/
cp /tmp/cairo/Cairo-Bold.ttf assets/fonts/

# Download Poppins
curl -L "https://fonts.google.com/download?family=Poppins" -o /tmp/poppins.zip
unzip /tmp/poppins.zip -d /tmp/poppins/
cp /tmp/poppins/Poppins-Regular.ttf assets/fonts/
cp /tmp/poppins/Poppins-Medium.ttf assets/fonts/
cp /tmp/poppins/Poppins-SemiBold.ttf assets/fonts/
cp /tmp/poppins/Poppins-Bold.ttf assets/fonts/
```

**App Icons** — Place your icons:
- `assets/icons/icon_dark.png` (512×512, PNG)
- `assets/icons/icon_light.png` (512×512, PNG)

---

## Step 6: Local Development Build

```bash
# Install dependencies
flutter pub get

# Check for issues
flutter analyze

# Run on connected device (debug)
flutter run

# Build release APK
flutter build apk --release

# Build release App Bundle
flutter build appbundle --release
```

---

## Step 7: App Distribution

### Alpha/Beta Testing
Use the debug APK from Codemagic artifacts for internal testing. Share via:
- Firebase App Distribution
- Direct APK download link
- WhatsApp / Telegram

### Production Release
1. Download the `.aab` artifact from Codemagic
2. Upload to Google Play Console → Production track
3. Complete store listing (screenshots, description)
4. Submit for review

---

## Environment Variables Reference

| Variable | Description | Where Set |
|----------|-------------|-----------|
| GAS WebApp URL | Google Apps Script URL | In-App (Setup Screen) |
| Secret Key | GAS authentication key | In-App (Setup Screen) |
| CM_KEYSTORE | Base64 keystore for signing | Codemagic |
| CM_KEYSTORE_PASSWORD | Keystore password | Codemagic |
| CM_KEY_ALIAS | Key alias | Codemagic |
| CM_KEY_PASSWORD | Key password | Codemagic |

---

## Troubleshooting

### Build fails: "flutter.sdk not found"
Add `flutter.sdk=/path/to/flutter` to `android/local.properties`

### Fonts not found
Ensure all 8 font files exist in `assets/fonts/` before building.

### API calls failing
- Verify GAS WebApp URL is correct (no trailing slash issues)
- Verify secret key matches GAS `PropertiesService`
- Check GAS deployment has "Execute as: Me, Access: Anyone"
- Codemagic build includes the network_security_config.xml

### Chat not loading
Check that GAS handles `FETCH_MSGS` action and returns `{ok: true, messages: [...]}`

### SQLite errors on upgrade
The schema uses `onUpgrade` callbacks — ensure version number is bumped when schema changes.

---

## Minimum Requirements

| Platform | Minimum |
|----------|---------|
| Android | API 23 (Android 6.0) |
| iOS | iOS 13.0 (future) |
| Flutter | 3.19.6 |
| Dart | 3.3.0 |
