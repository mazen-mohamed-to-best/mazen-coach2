# TO Best — Build & Release Guide

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter | 3.19.6+ | `flutter --version` |
| Dart | 3.3+ | bundled with Flutter |
| Android Studio / SDK | API 34 | for Android builds |
| Xcode | 15+ | macOS only, for iOS builds |
| CocoaPods | latest | `sudo gem install cocoapods` |
| Java | 17 | for Gradle |
| Git | any | version control |

---

## Local Development Setup

### 1. Clone and install dependencies
```bash
git clone <repo-url>
cd to-best-flutter
flutter pub get
cd ios && pod install && cd ..   # macOS only
```

### 2. Download fonts (not committed to repo)
```bash
mkdir -p assets/fonts assets/icons

# Cairo (Arabic)
curl -fsSL "https://github.com/google/fonts/raw/main/ofl/cairo/Cairo%5Bslnt%2Cwght%5D.ttf" \
  -o assets/fonts/Cairo-Regular.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Cairo-Medium.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Cairo-SemiBold.ttf
cp assets/fonts/Cairo-Regular.ttf assets/fonts/Cairo-Bold.ttf

# Poppins (English)
curl -fsSL "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" \
  -o assets/fonts/Poppins-Regular.ttf
curl -fsSL "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf" \
  -o assets/fonts/Poppins-Medium.ttf
curl -fsSL "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf" \
  -o assets/fonts/Poppins-SemiBold.ttf
curl -fsSL "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf" \
  -o assets/fonts/Poppins-Bold.ttf
```

### 3. Add app icons (optional for dev)
```bash
# Placeholder (so build doesn't fail)
printf '\x89PNG\r\n\x1a\n' > assets/icons/icon_dark.png
cp assets/icons/icon_dark.png assets/icons/icon_light.png
```

### 4. Run on device/emulator
```bash
flutter run
# or with flavor:
flutter run --debug
flutter run --release
```

---

## Android Build

### Debug APK
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release AAB (for Play Store)
```bash
# 1. Create a keystore (one-time setup):
keytool -genkey -v -keystore ~/tobest.keystore \
  -alias tobest -keyalg RSA -keysize 2048 -validity 10000

# 2. Create android/key.properties:
cat > android/key.properties <<EOF
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=tobest
storeFile=/Users/<you>/tobest.keystore
EOF

# 3. Build:
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Gradle configuration
- `android/app/build.gradle` reads signing config from `key.properties`
- Min SDK: 23 (Android 6.0)
- Target SDK: 34 (Android 14)
- Package: `com.tobest.app`

---

## iOS Build (macOS only)

### Prerequisites
1. Apple Developer account (paid membership required for TestFlight/App Store)
2. Bundle ID registered: `com.tobest.app`
3. Provisioning profile and signing certificate downloaded

### First-time setup
```bash
cd ios
pod install
open Runner.xcworkspace   # open in Xcode, set signing team
```

In Xcode:
- Select the `Runner` target → Signing & Capabilities
- Set your team and bundle identifier
- Let Xcode manage provisioning profile automatically

### Build IPA (release)
```bash
flutter build ios --release
# Then archive in Xcode: Product → Archive → Distribute App
```

---

## Codemagic CI/CD Setup

### Step 1: Connect repository
1. Log in to [Codemagic](https://codemagic.io)
2. Add your repository (GitHub/GitLab/Bitbucket)
3. Select **Flutter App**

### Step 2: Configure environment variable groups

#### `keystore_credentials` group (Android):
| Variable | Value |
|---|---|
| `CM_KEYSTORE` | Base64-encoded `.jks` file: `base64 ~/tobest.keystore` |
| `CM_KEYSTORE_PASSWORD` | Your keystore password |
| `CM_KEY_ALIAS` | `tobest` |
| `CM_KEY_PASSWORD` | Your key password |

#### `google_play` group (Android publish):
| Variable | Value |
|---|---|
| `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | JSON content of your service account key |
| `PACKAGE_NAME` | `com.tobest.app` |

#### `ios_credentials` group (iOS publish):
Configure via Codemagic's App Store Connect integration:
- Go to **Teams → Integrations → App Store Connect**
- Add your App Store Connect API key
- Reference it in `codemagic.yaml` as `app_store_connect: codemagic`

### Step 3: Build workflows

| Workflow | Trigger | Output |
|---|---|---|
| `android-release` | Push to `main` or `release/*` tag | `.aab` (release) / `.apk` (debug) |
| `android-debug` | Any push | `.apk` debug |
| `ios-release` | Tag on `release/*` | `.ipa` → TestFlight |

### Step 4: Trigger a build
```bash
# Android debug — push to main
git push origin main

# Android release — create a tag
git tag v1.0.0 && git push origin v1.0.0

# iOS release — tag on release branch
git checkout -b release/1.0.0
git tag v1.0.0-ios && git push origin v1.0.0-ios
```

---

## App Configuration (First Run)

When the app is installed fresh:

1. **Setup screen** opens automatically (no GAS URL configured)
2. Enter the GAS WebApp URL and secret key
3. Tap **Test Connection** — should return `{"ok": true}`
4. Tap **Save** — redirects to login

### GAS Setup Steps
1. Open your Google Apps Script project
2. Deploy → New deployment → Web App
3. Execute as: **Me**, Access: **Anyone**
4. Copy the deployment URL → paste in app Setup screen
5. Set the same secret key in both GAS and the app

---

## App Icon Generation

Replace placeholder icons with real 1024×1024 PNG files:
```
assets/icons/icon_dark.png    (white icon on dark/transparent bg)
assets/icons/icon_light.png   (dark icon on white/transparent bg)
```

Then optionally use `flutter_launcher_icons`:
```yaml
# pubspec.yaml addition (not included by default)
dev_dependencies:
  flutter_launcher_icons: ^0.13.0

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icons/icon_light.png"
```
```bash
flutter pub run flutter_launcher_icons
```

---

## Version Bumping

Version format: `MAJOR.MINOR.PATCH+BUILD` (defined in `pubspec.yaml`)

```yaml
version: 1.0.0+1
```

For Codemagic builds, the `+BUILD` is overridden by `$BUILD_NUMBER` env variable:
```bash
flutter build apk --build-name=1.0.0 --build-number=$BUILD_NUMBER
```

---

## Debugging Tips

### `flutter analyze`
```bash
flutter analyze --no-fatal-infos
```

### Common build issues

| Issue | Fix |
|---|---|
| `Font not found` | Run the font download script above |
| `Podfile lock error` | `cd ios && pod install --repo-update` |
| `Gradle build failed` | Check `android/key.properties` exists |
| `HMAC mismatch` | Ensure secret key matches exactly in app and GAS |
| `Session expired` | User needs to log in again |
| `Sync queue not flushing` | Check network connectivity; see `SyncService.flushQueue()` |

### Inspect SQLite (debug builds)
```bash
# Android
adb shell run-as com.tobest.app cat /data/data/com.tobest.app/databases/tobest.db > /tmp/tobest.db
# Open with DB Browser for SQLite
```

---

## Release Checklist

- [ ] Update `version` in `pubspec.yaml`
- [ ] Replace placeholder app icons with real ones
- [ ] Verify GAS URL works in production environment
- [ ] Run `flutter analyze` — no errors
- [ ] Test on physical device (Android + iOS)
- [ ] Tag and push to trigger Codemagic build
- [ ] Verify build artifacts in Codemagic dashboard
- [ ] Submit to Google Play internal track / TestFlight
