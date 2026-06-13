# نظام التحديث — دليل الإدارة الكامل

## نظرة عامة

يعتمد نظام التحديث على استجابة GAS لعملية `VERSION_CHECK`.  
عند فتح التطبيق **قبل أي شيء آخر** يسأل التطبيق الخادم: *"هل أنا محدَّث؟"*  
بناءً على الجواب، يتصرف التطبيق بأحد أربعة أحوال:

| الحالة | السلوك |
|---|---|
| `upToDate` | لا شيء — التطبيق يعمل بشكل عادي |
| `optional` | تظهر شاشة تحديث مع زر "لاحقاً" يمكن للمستخدم تخطيها |
| `required` | شاشة تحديث إجبارية — **لا يمكن التخطي** |
| `blocked` | شاشة حظر كاملة — **التطبيق لا يعمل** |
| `maintenance` | شاشة صيانة — **التطبيق لا يعمل** حتى تنتهي |

---

## استجابة GAS المطلوبة

أضف هذا الكود في Google Apps Script لمعالجة `VERSION_CHECK`:

```javascript
function handleVersionCheck() {
  // قراءة الإعدادات من Sheet أو مباشرة هنا
  return {
    ok: true,
    version: {
      // أقدم نسخة مدعومة — أقل منها: BLOCKED (لا يعمل)
      minVersion: "1.0.0",

      // أقدم نسخة مقبولة — أقل منها: REQUIRED (تحديث إجباري)
      requiredVersion: "1.2.0",

      // أحدث نسخة — أقل منها: OPTIONAL (تحديث اختياري)
      latestVersion: "1.3.0",

      // رابط التحميل (APK مباشر أو رابط Google Play)
      downloadUrl: "https://play.google.com/store/apps/details?id=com.tobest.app",

      // رسائل مخصصة (اختيارية — إذا فارغة تُستخدم الرسائل الافتراضية)
      messageAr: "",
      messageEn: "",

      // وضع الصيانة
      maintenanceMode: false,
      maintenanceAr: "التطبيق تحت الصيانة. نعود قريباً إن شاء الله 🔧",
      maintenanceEn: "App is under maintenance. We'll be back soon 🔧",

      // رابط التواصل (يظهر فقط عند BLOCKED)
      contactUrl: "https://wa.me/966XXXXXXXXX"
    }
  };
}
```

### مثال كامل لدالة `doPost` في GAS:

```javascript
function doPost(e) {
  try {
    const payload = JSON.parse(decodeURIComponent(e.parameter.payload));
    
    // تحقق من HMAC أولاً
    if (!verifyHmac(payload)) {
      return jsonResponse({ ok: false, error: "UNAUTHORIZED" });
    }

    switch (payload.action) {
      case "VERSION_CHECK":
        return jsonResponse(handleVersionCheck());
      // ... بقية الـ actions
    }
  } catch (err) {
    return jsonResponse({ ok: false, error: err.message });
  }
}

function jsonResponse(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
```

---

## كيفية التحكم بالتحديثات

### ✅ إصدار تحديث اختياري (optional)
```javascript
// في handleVersionCheck():
latestVersion: "1.4.0",    // ← زد هذا الرقم
requiredVersion: "1.0.0",  // لا تغيره
minVersion: "1.0.0",       // لا تغيره
```
> المستخدمون على 1.3.0 سيرون شاشة "تحديث متوفر" مع زر "لاحقاً".

---

### 🔴 إصدار تحديث إجباري (required)
```javascript
requiredVersion: "1.4.0",  // ← زد هذا لإجبار الجميع على التحديث
latestVersion: "1.4.0",
minVersion: "1.0.0",
```
> من لديه نسخة أقل من 1.4.0 لا يمكنه استخدام التطبيق حتى يُحدِّث.

---

### ⛔ حظر نسخة قديمة جداً (blocked)
```javascript
minVersion: "1.2.0",  // ← من لديه أقل من هذا: BLOCKED
```
> المستخدمون على 1.0.x و 1.1.x تظهر لهم شاشة حظر بدون أي خيار.

---

### 🔧 تفعيل وضع الصيانة
```javascript
maintenanceMode: true,
maintenanceAr: "نقوم بتحديث الخوادم. نعود خلال ساعة.",
maintenanceEn: "Server upgrade in progress. Back in 1 hour.",
```
> **كل** المستخدمين يرون شاشة الصيانة بغض النظر عن نسختهم.  
> لإنهاء الصيانة: غيّر `maintenanceMode` إلى `false`.

---

### 📝 إضافة رسالة مخصصة
```javascript
messageAr: "الإصدار الجديد يحتوي على تحسينات كبيرة في سرعة التحميل وتجربة التمرين!",
messageEn: "New version includes major speed improvements and workout UX enhancements!",
```

---

## جدول قرار الحالات

```
نسخة المستخدم    minVersion   requiredVersion   latestVersion   الحالة
───────────────────────────────────────────────────────────────────────
0.9.x            1.0.0        1.2.0             1.4.0           BLOCKED
1.0.x            1.0.0        1.2.0             1.4.0           BLOCKED  (< min)
1.1.x            1.0.0        1.2.0             1.4.0           BLOCKED  (< min)
1.2.0            1.0.0        1.2.0             1.4.0           OPTIONAL (< latest)
1.3.x            1.0.0        1.2.0             1.4.0           OPTIONAL
1.4.0            1.0.0        1.2.0             1.4.0           UP_TO_DATE ✓
```

> **قاعدة مهمة:** `minVersion ≤ requiredVersion ≤ latestVersion` دائماً.

---

## سلوك التطبيق بدون إنترنت

- إذا فشل طلب VERSION_CHECK، يبحث التطبيق عن **نسخة مخزّنة محلياً** (تنتهي صلاحيتها بعد 6 ساعات).
- إذا لا يوجد كاش: **التطبيق يعمل بشكل عادي** (upToDate افتراضياً).
- هذا يضمن أن المستخدمين غير المتصلين لن يُحظروا بسبب فقدان الاتصال.

---

## ملفات النظام في المشروع

| الملف | الوظيفة |
|---|---|
| `lib/models/version_model.dart` | `VersionInfo` + `UpdateState` + منطق المقارنة |
| `lib/services/version_service.dart` | استدعاء GAS + cache محلي (6 ساعات) |
| `lib/providers/version_provider.dart` | Riverpod providers للحالة |
| `lib/features/update/presentation/screens/update_screen.dart` | شاشة التحديث/الحظر/الصيانة |
| `lib/main.dart` | `_VersionGate` يعترض التطبيق كاملاً قبل أي شاشة |
| `lib/core/constants/api_actions.dart` | ثابت `versionCheck = 'VERSION_CHECK'` |

---

## تسلسل التنفيذ عند فتح التطبيق

```
main() → DatabaseHelper.initialize()
       → ProviderScope → ToBestApp
       → MaterialApp.builder → _VersionGate
       → versionCheckProvider (FutureProvider)
         ├─ loading:    → شاشة تحميل بالشعار
         ├─ error:      → التطبيق يعمل (offline-safe)
         └─ data:
             ├─ upToDate   → التطبيق الكامل
             ├─ optional   → UpdateScreen + زر "لاحقاً"
             ├─ required   → UpdateScreen (بدون زر تخطي)
             ├─ blocked    → UpdateScreen (بدون أي زر)
             └─ maintenance→ UpdateScreen (رسالة صيانة)
```
