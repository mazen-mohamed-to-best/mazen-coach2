# TO Best — Google Apps Script (GAS) API Contract

## Overview

The GAS web app is the **sole backend and source of truth** for TO Best. The Flutter app communicates with it exclusively via HTTPS POST requests using `application/x-www-form-urlencoded` encoding. All data is stored in Google Sheets managed by the GAS project.

---

## Request Format

Every request is a POST with a single `payload` field:

```
POST <GAS_WEBAPP_URL>
Content-Type: application/x-www-form-urlencoded

payload=%7B%22action%22%3A%22LOGIN%22%2C...%7D
```

The value of `payload` is a URL-encoded JSON string. The JSON object must always contain:

| Field | Type | Required | Description |
|---|---|---|---|
| `action` | string | ✓ | Action identifier (see table below) |
| `sessionToken` | string | ✓* | Token returned by LOGIN. Required for all authenticated actions. |
| `hmac` | string | ✓ | HMAC-SHA256 of the payload JSON using the shared `secretKey` |

*Not required for `LOGIN`, `REGISTER`, `GUEST_CREATE`, `CHECK_BAN`.

---

## Authentication

### HMAC Signature

The Flutter app signs every request using HMAC-SHA256:

```dart
// Pseudocode — see ApiService.dart
final sig = HMAC_SHA256(secretKey, payloadJsonString);
final payload = {...originalPayload, 'hmac': sig};
```

The GAS side verifies this signature against the stored secret key before processing any request.

### Session Token

On successful `LOGIN`, GAS returns a `sessionToken`. This token is stored in `SharedPreferences` and included in every subsequent request. GAS validates it against the user's stored token in the Sheet.

---

## Actions Reference

### Auth Actions

#### `LOGIN`
```json
// Request
{"action": "LOGIN", "email": "user@example.com", "password": "hashed_password", "deviceId": "uuid", "hmac": "..."}

// Response
{"ok": true, "sessionToken": "TOKEN", "user": {...UserObject}}
// or
{"ok": false, "error": "INVALID_CREDENTIALS|BANNED|PENDING"}
```

#### `REGISTER`
```json
// Request
{"action": "REGISTER", "email": "...", "password": "...", "name": "...", "phone": "...", "referralCode": "optional", "guestCode": "optional", "hmac": "..."}

// Response
{"ok": true, "uid": "...", "sessionToken": "..."}
// or
{"ok": false, "error": "EMAIL_EXISTS|BANNED"}
```

#### `CHANGE_PASSWORD`
```json
{"action": "CHANGE_PASSWORD", "sessionToken": "...", "oldPassword": "...", "newPassword": "...", "hmac": "..."}
// Response: {"ok": true} or {"ok": false, "error": "..."}
```

#### `PING`
```json
{"action": "PING", "sessionToken": "...", "hmac": "..."}
// Response: {"ok": true, "ts": 1234567890, "serverVersion": "2.0"}
```

#### `CHECK_BAN`
```json
{"action": "CHECK_BAN", "email": "...", "deviceId": "...", "hmac": "..."}
// Response: {"ok": true, "banned": false} or {"ok": true, "banned": true, "reason": "..."}
```

---

### User Data Actions

#### `FETCH_USER_DATA`
```json
{"action": "FETCH_USER_DATA", "sessionToken": "...", "uid": "...", "hmac": "..."}

// Response
{"ok": true, "data": {...UserObject}}
```

#### `FULL_SYNC_PULL`
```json
{"action": "FULL_SYNC_PULL", "sessionToken": "...", "uid": "...", "hmac": "..."}

// Response
{
  "ok": true,
  "data": {
    "user": {...UserObject},
    "workoutLogs": [...],
    "foodLogs": [...],
    "attendance": [...]
  }
}
```

#### `UPDATE_USER_SHEET`
```json
{"action": "UPDATE_USER_SHEET", "sessionToken": "...", "uid": "...", "snapshot": {...}, "hmac": "..."}
// Response: {"ok": true}
```

---

### Workout Actions

#### `SAVE_WORKOUT_LOG`
```json
{
  "action": "SAVE_WORKOUT_LOG",
  "sessionToken": "...",
  "key": "workout_<uuid>",
  "uid": "...",
  "data": {
    "id": "uuid",
    "date": "2024-01-15",
    "sessionName": "Upper A",
    "programId": "UL",
    "exercises": [
      {
        "name": "Smith High Incline Press",
        "sets": [
          {"set": 1, "weight": 60, "reps": 8, "rpe": 7, "epley": 64}
        ],
        "isPR": false
      }
    ],
    "duration": 55,
    "ts": 1705276800000
  },
  "hmac": "..."
}
// Response: {"ok": true}
```

---

### Nutrition Actions

#### `SAVE_FOOD_LOG`
```json
{
  "action": "SAVE_FOOD_LOG",
  "sessionToken": "...",
  "key": "food_<uuid>",
  "uid": "...",
  "data": {
    "id": "uuid",
    "date": "2024-01-15",
    "mealType": "breakfast|lunch|dinner|snack",
    "items": [
      {"name": "صدر دجاج", "calories": 165, "protein": 31, "carbs": 0, "fat": 3.6, "amount": 150}
    ],
    "totalCalories": 247.5,
    "ts": 1705276800000
  },
  "hmac": "..."
}
// Response: {"ok": true}
```

---

### Attendance Actions

#### `SAVE_ATTENDANCE`
```json
{
  "action": "SAVE_ATTENDANCE",
  "sessionToken": "...",
  "key": "att_<uid>_<date>",
  "uid": "...",
  "data": {
    "id": "uid_2024-01-15",
    "date": "2024-01-15",
    "type": "gym|rest|absent",
    "ts": 1705276800000
  },
  "hmac": "..."
}
// Response: {"ok": true}
```

---

### Admin Actions

#### `FETCH_ALL_USERS`
```json
{"action": "FETCH_ALL_USERS", "sessionToken": "...", "hmac": "..."}
// Response: {"ok": true, "users": [...UserObjects]}
```

#### `ADMIN_UPDATE_USER`
```json
{"action": "ADMIN_UPDATE_USER", "sessionToken": "...", "uid": "...", "fields": {"programId": "UL", "programDays": 4, "status": "active"}, "hmac": "..."}
// Response: {"ok": true}
```

#### `ADMIN_APPROVE`
```json
{"action": "ADMIN_APPROVE", "sessionToken": "...", "uid": "...", "approved": true, "hmac": "..."}
// Response: {"ok": true}
```

#### `ADMIN_DELETE_USER`
```json
{"action": "ADMIN_DELETE_USER", "sessionToken": "...", "uid": "...", "hmac": "..."}
// Response: {"ok": true}
```

#### `APPROVE_PROGRAM`
```json
{"action": "APPROVE_PROGRAM", "sessionToken": "...", "uid": "...", "programId": "UL", "programDays": 4, "hmac": "..."}
// Response: {"ok": true}
```

---

### Subscription Actions

#### `SUB_REQUEST`
```json
{"action": "SUB_REQUEST", "sessionToken": "...", "uid": "...", "planId": "monthly", "paymentMethod": "bank", "promoCode": "optional", "hmac": "..."}
// Response: {"ok": true, "requestId": "..."}
```

#### `SUB_CONFIG`
```json
// GET config
{"action": "SUB_CONFIG", "sessionToken": "...", "hmac": "..."}
// Response: {"ok": true, "plans": [{"id": "monthly", "name": "...", "price": 150, "currency": "SAR", "days": 30}]}

// SET config (admin only)
{"action": "SUB_CONFIG", "sessionToken": "...", "data": {...}, "hmac": "..."}
// Response: {"ok": true}
```

#### `GET_SUB_REQUESTS`
```json
{"action": "GET_SUB_REQUESTS", "sessionToken": "...", "hmac": "..."}
// Response: {"ok": true, "requests": [...SubscriptionRequestObjects]}
```

#### `UPDATE_SUB_REQUEST`
```json
{"action": "UPDATE_SUB_REQUEST", "sessionToken": "...", "id": "...", "status": "approved|rejected", "fields": {"planName": "شهري", "expiresAt": 1234567890000}, "hmac": "..."}
// Response: {"ok": true}
```

---

### Chat Actions

#### `FETCH_MSGS`
```json
{"action": "FETCH_MSGS", "sessionToken": "...", "roomId": "general|announcements|coach|support|ai", "since": 1705276800000, "hmac": "..."}
// Response: {"ok": true, "messages": [...MessageObjects]}
```

#### `SEND_MSG`
```json
{
  "action": "SEND_MSG",
  "sessionToken": "...",
  "roomId": "general",
  "msg": {
    "id": "uuid",
    "uid": "...",
    "name": "User Name",
    "text": "Hello!",
    "ts": 1705276800000,
    "type": "text|image|file|voice"
  },
  "hmac": "..."
}
// Response: {"ok": true}
```

#### `DELETE_MSG` / `EDIT_MSG` / `PIN_MSG` / `UNPIN_MSG` / `GET_PINNED`
```json
{"action": "DELETE_MSG", "sessionToken": "...", "roomId": "...", "msgId": "...", "hmac": "..."}
{"action": "EDIT_MSG", "sessionToken": "...", "roomId": "...", "msgId": "...", "newText": "...", "hmac": "..."}
{"action": "PIN_MSG", "sessionToken": "...", "roomId": "...", "msg": {...}, "hmac": "..."}
{"action": "UNPIN_MSG", "sessionToken": "...", "roomId": "...", "msgId": "...", "hmac": "..."}
{"action": "GET_PINNED", "sessionToken": "...", "roomId": "...", "hmac": "..."}
// All respond: {"ok": true}
```

#### `CHAT_BAN` / `CHAT_MUTE`
```json
{"action": "CHAT_BAN", "sessionToken": "...", "uid": "...", "ban": true, "hmac": "..."}
{"action": "CHAT_MUTE", "sessionToken": "...", "uid": "...", "muteUntil": 1705276800000, "hmac": "..."}
// Response: {"ok": true}
```

---

### Promo & Guest Codes

#### `PROMO_CHECK`
```json
{"action": "PROMO_CHECK", "sessionToken": "...", "code": "SAVE20", "hmac": "..."}
// Response: {"ok": true, "discount": 20, "type": "percent|fixed"}
// or: {"ok": false, "error": "INVALID|EXPIRED|EXHAUSTED"}
```

#### `PROMO_CREATE` / `PROMO_LIST` / `PROMO_DELETE`
```json
{"action": "PROMO_CREATE", "sessionToken": "...", "code": "SAVE20", "discount": 20, "maxUses": 100, "hmac": "..."}
{"action": "PROMO_LIST", "sessionToken": "...", "hmac": "..."}
{"action": "PROMO_DELETE", "sessionToken": "...", "code": "SAVE20", "hmac": "..."}
```

#### `GUEST_CREATE` / `GUEST_LIST` / `GUEST_DELETE`
```json
{"action": "GUEST_CREATE", "sessionToken": "...", "code": "GUEST2024", "hmac": "..."}
{"action": "GUEST_LIST", "sessionToken": "...", "hmac": "..."}
{"action": "GUEST_DELETE", "sessionToken": "...", "code": "GUEST2024", "hmac": "..."}
```

---

### Force Logout & Ban

```json
{"action": "FORCE_LOGOUT_USER", "sessionToken": "...", "uid": "...", "token": "timestamp", "hmac": "..."}
{"action": "FORCE_LOGOUT_ALL", "sessionToken": "...", "token": "timestamp", "hmac": "..."}
{"action": "BAN_IDENTITY", "sessionToken": "...", "banEntry": {"email": "...", "deviceId": "...", "reason": "..."}, "hmac": "..."}
{"action": "UNBAN_IDENTITY", "sessionToken": "...", "banId": "...", "hmac": "..."}
{"action": "LIST_BANNED", "sessionToken": "...", "hmac": "..."}
```

---

### Referral & Profile

```json
{"action": "GET_REFERRAL_STATS", "sessionToken": "...", "code": "REF123", "hmac": "..."}
// Response: {"ok": true, "referredCount": 5, "pendingCoins": 150, "totalCoins": 300}

{"action": "SAVE_PROFILE_PIC", "sessionToken": "...", "uid": "...", "imageData": "data:image/jpeg;base64,...", "hmac": "..."}
// Response: {"ok": true, "pictureUrl": "https://..."}
```

---

## UserObject Schema

```json
{
  "uid": "string",
  "email": "string",
  "name": "string",
  "phone": "string",
  "role": "superAdmin|admin|coach|trainee|viewer",
  "status": "active|pending|rejected",
  "programId": "UL|AP|FB|ARNOLD|PPL|CUSTOM|null",
  "programDays": 4,
  "picture": "https://...",
  "referralCode": "REF123",
  "referralCoins": 0,
  "subscription": {
    "planId": "monthly",
    "planName": "شهري",
    "expiresAt": 1705276800000,
    "status": "active|expired"
  },
  "nutritionTargets": {
    "calories": 2500,
    "protein": 180,
    "carbs": 300,
    "fat": 80
  },
  "gymDays": ["Mon", "Wed", "Fri", "Sat"],
  "forceLogoutToken": "optional",
  "chatBanned": false,
  "chatMuteUntil": null
}
```

---

## Error Codes

| Code | Meaning |
|---|---|
| `INVALID_CREDENTIALS` | Wrong email/password |
| `BANNED` | Account/device/email is banned |
| `PENDING` | Account awaiting admin approval |
| `REJECTED` | Account was rejected |
| `SESSION_EXPIRED` | Session token invalid or expired |
| `UNAUTHORIZED` | Action requires higher role |
| `EMAIL_EXISTS` | Email already registered |
| `INVALID` | Generic validation failure |
| `EXPIRED` | Promo code expired |
| `EXHAUSTED` | Promo code max uses reached |

---

## Notes

- All timestamps are **Unix milliseconds** (JavaScript `Date.now()`)
- All dates are **ISO 8601 date strings** (`YYYY-MM-DD`)
- GAS responses always include `"ok": true|false` at the top level
- The GAS URL and secret key are entered by the user in the Setup screen and stored in encrypted storage (`secure_settings.dart`)
