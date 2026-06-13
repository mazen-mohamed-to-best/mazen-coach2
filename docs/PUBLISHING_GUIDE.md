# دليل النشر — بدون كمبيوتر

## المقدمة

هذا الدليل يشرح **أربع طرق احترافية** لنشر التطبيق بدون حاجة للكمبيوتر.  
كل طريقة تعمل بالكامل من الهاتف.

---

## الطريقة ١ — Codemagic + GitHub (الأفضل والأكثر احترافية) ⭐

### المبدأ
تدفع commit أو tag من GitHub Mobile → Codemagic يبني APK/IPA تلقائياً → ترفعه على Play Store أو TestFlight.

### الإعداد (مرة واحدة فقط)

**1. أنشئ حساب GitHub وارفع المشروع**
- حمّل تطبيق **GitHub Mobile** من المتجر
- أنشئ repository جديد (private أو public)
- ارفع ملفات المشروع

**2. أنشئ حساب Codemagic**
- افتح [codemagic.io](https://codemagic.io) من المتصفح في هاتفك
- سجّل بحساب GitHub مباشرة
- ربط الـ repository

**3. أضف متغيرات البيئة في Codemagic**
- افتح إعدادات المشروع → Environment variables
- أضف المجموعات المذكورة في `docs/BUILD_GUIDE.md`:
  - `keystore_credentials` للأندرويد
  - `google_play` لرفع Play Store
  - `ios_credentials` للـ iOS

### النشر اليومي (من الهاتف في ثوانٍ)

```bash
# من GitHub Mobile:
# 1. افتح الـ repository
# 2. عدّل version في pubspec.yaml: مثلاً 1.1.0+5
# 3. Commit مباشرة على main
# → Codemagic يبدأ البناء تلقائياً
```

أو لإصدار رسمي مُوقَّع (APK release):
- افتح GitHub Mobile → Repository → Releases → Create a release
- أدخل tag مثل `v1.1.0`
- انشر الـ release
- → Codemagic يبني الـ AAB ويرفعه على Play Store (internal track)

### متابعة البناء
- تطبيق **Codemagic** متوفر على iOS/Android
- أو بريد إلكتروني عند اكتمال البناء أو فشله

---

## الطريقة ٢ — GitHub Actions (مجاني تماماً) ⭐

### المبدأ
GitHub يبني APK مجاناً بدون Codemagic.

### إعداد workflow الأندرويد

أنشئ الملف `.github/workflows/android.yml` في المشروع:

```yaml
name: Android Debug APK

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.6'

      - name: Download fonts
        run: |
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

      - run: flutter pub get
      - run: flutter build apk --debug

      - uses: actions/upload-artifact@v4
        with:
          name: debug-apk
          path: build/app/outputs/flutter-apk/app-debug.apk
```

### تشغيل البناء من الهاتف
1. افتح GitHub Mobile
2. اذهب إلى **Actions**
3. اختر الـ workflow
4. اضغط **Run workflow** → ابدأ البناء يدوياً
5. عند الانتهاء حمّل الـ APK من صفحة الـ workflow

### نشر على GitHub Releases تلقائياً
```yaml
# أضف هذا الجزء بعد upload-artifact:
      - name: Release APK
        if: startsWith(github.ref, 'refs/tags/')
        uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/app-debug.apk
```
> أنشئ tag من GitHub Mobile → يُرفع APK على صفحة Releases تلقائياً.

---

## الطريقة ٣ — توزيع مباشر بدون متاجر (للاختبار والمجموعات الخاصة) ⭐

### الأسرع للاختبار مع العملاء

**أ) Firebase App Distribution (مجاني)**
1. أنشئ مشروع على [firebase.google.com](https://firebase.google.com) (من الهاتف)
2. بعد بناء APK من Codemagic أو GitHub Actions:
   - Codemagic يستطيع رفع APK على Firebase App Distribution مباشرة
3. المختبِرون يتلقون رابط تحميل مباشر على بريدهم

أضف هذا في `codemagic.yaml` تحت `publishing`:
```yaml
publishing:
  firebase:
    firebase_token: $FIREBASE_TOKEN
    android:
      app_id: "1:XXXX:android:XXXX"
      groups:
        - testers
```

**ب) رفع APK على Google Drive + مشاركة رابط**
1. بعد بناء APK من GitHub Actions، حمّله على هاتفك
2. ارفعه على **Google Drive**
3. اجعله عاماً وشارك الرابط
4. **ضع الرابط في GAS** على حقل `downloadUrl` في `VERSION_CHECK`
5. عند نشر تحديث جديد: ارفع APK الجديد، غيّر الرابط في GAS، وحدّث `latestVersion`

**ج) Telegram — الأبسط والأسرع**
- أنشئ بوت تيليغرام أو قناة خاصة
- ارفع APK مباشرة على التيليغرام (حجم حتى 2GB)
- شارك الرابط المباشر في حقل `downloadUrl`

---

## الطريقة ٤ — Google Play Console (رسمي ودائم)

### المتطلبات
- حساب مطور Google Play ($25 رسوم مرة واحدة)
- APK موقَّع (signed) — يبنيه Codemagic أو GitHub Actions

### النشر من الهاتف

1. حمّل تطبيق **Google Play Console** من المتجر
2. افتح تطبيقك → **Production** أو **Internal Testing**
3. اضغط **Create new release**
4. ارفع الـ AAB (Android App Bundle)
5. راجع وأرسل

### تتبع الإصدارات مع نظام التحديث

بعد رفع إصدار جديد على Play Store:
1. افتح GAS
2. حدّث `VERSION_CHECK`:
   - اجعل `latestVersion` = الإصدار الجديد
   - حدّد ما إذا كان إجبارياً أو اختيارياً
3. الـ `downloadUrl` يبقى ثابتاً: رابط صفحة التطبيق على Play Store

---

## مقارنة الطرق

| الطريقة | السرعة | المجانية | iOS | Android | التوزيع |
|---|---|---|---|---|---|
| Codemagic + GitHub | ⭐⭐⭐ | جزئي (250 دقيقة/شهر مجاناً) | ✅ | ✅ | Play Store + TestFlight |
| GitHub Actions | ⭐⭐⭐ | ✅ كامل | ❌ | ✅ APK فقط | Releases مباشر |
| Firebase Dist | ⭐⭐⭐⭐ | ✅ | ✅ | ✅ | مجموعات مختبِرين |
| Google Drive/Telegram | ⭐⭐⭐⭐⭐ | ✅ | ❌ | ✅ | رابط مباشر |
| Play Console | ⭐⭐ | رسوم $25 مرة | ❌ | ✅ | رسمي للعموم |

---

## الخطة الموصى بها

```
مرحلة الاختبار (Beta):
  GitHub Actions → APK → Telegram/Google Drive
  + حدّث downloadUrl في GAS

مرحلة الإطلاق الرسمي:
  Codemagic → AAB موقَّع → Play Store Internal
  → Promote to Production

للتحديثات السريعة:
  GitHub Mobile: غيّر pubspec.yaml version → Commit
  → Codemagic يبني → Play Store Internal تلقائياً
```

---

## سير عمل التحديث الكامل (خطوة بخطوة)

### مثال: إصدار تحديث v1.2.0

**1. على هاتفك — GitHub Mobile:**
```
افتح pubspec.yaml
غيّر: version: 1.1.0+4  →  version: 1.2.0+5
Commit & Push
```

**2. إذا تحديث إجباري — Codemagic / GitHub Actions:**
```
انتظر اكتمال البناء (15-30 دقيقة)
حمّل الـ APK/AAB
ارفعه على Play Store أو Google Drive
```

**3. في GAS — حدّث VERSION_CHECK:**
```javascript
requiredVersion: "1.2.0",  // أجبر الجميع على التحديث
latestVersion: "1.2.0",
downloadUrl: "<رابط جديد أو نفس رابط Play Store>"
```

**4. النتيجة:**
```
المستخدمون على 1.0.x و 1.1.x → شاشة تحديث إجبارية
المستخدمون على 1.2.0 → التطبيق يعمل بشكل عادي ✅
```

---

## ملفات التكوين

| الملف | الوظيفة |
|---|---|
| `codemagic.yaml` | 3 workflows: android-release, android-debug, ios-release |
| `.github/workflows/android.yml` | GitHub Actions للـ APK المجاني |
| `docs/UPDATE_SYSTEM.md` | كيفية إدارة إصدارات GAS |
| `pubspec.yaml` → `version` | رقم الإصدار (`major.minor.patch+build`) |
