class AppConstants {
  AppConstants._();

  static const String appName = 'TO Best';
  static const String appVersion = 'v8.2.0';
  static const int apiTimeoutSeconds = 14;

  // SharedPreferences keys
  static const String keyWebAppUrl = 'web_app_url';
  static const String keySecretKey = 'secret_key_enc';
  static const String keySecretKeyIv = 'secret_key_iv';
  static const String keySecretKeyWrap = 'secret_key_wrap';
  static const String keySessionToken = 'session_token';
  static const String keyCurrentUserId = 'current_user_id';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme_mode';
  static const String keyAccentColor = 'accent_color';
  static const String keyHandMode = 'hand_mode';
  static const String keyRestTimerSound = 'rest_timer_sound';
  static const String keyShowOldValues = 'show_old_values';
  static const String keyShowEpley = 'show_epley';
  static const String keyShowRPE = 'show_rpe';
  static const String keyShowRepSuggest = 'show_rep_suggest';
  static const String keyWakeLock = 'wake_lock';

  // User roles
  static const String roleSuperAdmin = 'superadmin';
  static const String roleAdmin = 'admin';
  static const String roleCoach = 'coach';
  static const String roleTrainee = 'trainee';
  static const String roleViewer = 'viewer';

  // User statuses
  static const String statusActive = 'active';
  static const String statusPending = 'pending';
  static const String statusRejected = 'rejected';
  static const String statusInactive = 'inactive';

  // Attendance types
  static const String attendanceGym = 'gym';
  static const String attendanceAbsent = 'absent';
  static const String attendanceRest = 'rest';

  // Training programs
  static const String progUL = 'UL';
  static const String progAP = 'AP';
  static const String progFB = 'FB';
  static const String progArnold = 'ARNOLD';
  static const String progPPL = 'PPL';
  static const String progCustom = 'CUSTOM';

  // Chat rooms
  static const String chatGeneral = 'general';
  static const String chatCoach = 'coach';
  static const String chatAnnouncements = 'announcements';
  static const String chatSupport = 'support';
  static const String chatAI = 'ai';

  // Theme names
  static const String themeDark = 'dark';
  static const String themeLight = 'light';
  static const String themeLuxury = 'luxury';
  static const String themeSports = 'sports';
  static const String themeFuture = 'future';

  // Sync interval
  static const int syncIntervalMs = 30000;

  // Meal types
  static const List<String> mealTypes = [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  ];

  // Evaluator labels
  static const String evS1 = 'ev_s1'; // ممتاز جدا جدا
  static const String evS2 = 'ev_s2'; // ممتاز جدا
  static const String evS3 = 'ev_s3'; // ممتاز
  static const String evRV = 'ev_rv'; // استعادة المستوى
  static const String evGD = 'ev_gd'; // جيد
  static const String evST = 'ev_st'; // ثبات
  static const String evWS = 'ev_ws'; // ثبات تحذير
  static const String evDN = 'ev_dn'; // انخفاض
  static const String evBEG = 'ev_beg'; // بداية
}
