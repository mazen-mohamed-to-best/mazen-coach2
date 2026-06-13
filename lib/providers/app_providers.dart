import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/local_db/database_helper.dart';
import 'package:to_best/core/network/api_service.dart';
import 'package:to_best/core/utils/router.dart';
import 'package:to_best/core/utils/secure_settings.dart';
import 'package:to_best/models/user_model.dart';
import 'package:to_best/services/admin_service.dart';
import 'package:to_best/services/attendance_service.dart';
import 'package:to_best/services/auth_service.dart';
import 'package:to_best/services/chat_service.dart';
import 'package:to_best/services/nutrition_service.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:to_best/services/workout_service.dart';

// ── Infrastructure ──────────────────────────────────────────────────────
final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final secureSettingsProvider = Provider<SecureSettings>((ref) => SecureSettings.instance);

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());

// ── Services ────────────────────────────────────────────────────────────
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.read(apiServiceProvider), ref.read(databaseHelperProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiServiceProvider), ref.read(databaseHelperProvider));
});

final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService(ref.read(databaseHelperProvider), ref.read(syncServiceProvider));
});

final nutritionServiceProvider = Provider<NutritionService>((ref) {
  return NutritionService(ref.read(databaseHelperProvider), ref.read(syncServiceProvider));
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(ref.read(databaseHelperProvider), ref.read(syncServiceProvider));
});

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.read(apiServiceProvider));
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref.read(apiServiceProvider), ref.read(databaseHelperProvider));
});

// ── App State ────────────────────────────────────────────────────────────
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// ── Theme ────────────────────────────────────────────────────────────────
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark;
});

final themeNameProvider = StateProvider<String>((ref) => AppConstants.themeDark);

// ── Locale ───────────────────────────────────────────────────────────────
final localeProvider = StateProvider<Locale?>((ref) => const Locale('ar'));

final isArabicProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return locale?.languageCode == 'ar';
});

// ── Settings ─────────────────────────────────────────────────────────────
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class AppSettings {
  final bool showOldValues;
  final bool showEpley;
  final bool showRPE;
  final bool showRepSuggest;
  final bool wakeLock;
  final String restTimerSound;
  final String accentColor;
  final bool leftHandMode;
  final double waterGoalLiters;

  const AppSettings({
    this.showOldValues = true,
    this.showEpley = true,
    this.showRPE = true,
    this.showRepSuggest = true,
    this.wakeLock = true,
    this.restTimerSound = 'bell',
    this.accentColor = '#4CAF50',
    this.leftHandMode = false,
    this.waterGoalLiters = 3.0,
  });

  AppSettings copyWith({
    bool? showOldValues,
    bool? showEpley,
    bool? showRPE,
    bool? showRepSuggest,
    bool? wakeLock,
    String? restTimerSound,
    String? accentColor,
    bool? leftHandMode,
    double? waterGoalLiters,
  }) {
    return AppSettings(
      showOldValues: showOldValues ?? this.showOldValues,
      showEpley: showEpley ?? this.showEpley,
      showRPE: showRPE ?? this.showRPE,
      showRepSuggest: showRepSuggest ?? this.showRepSuggest,
      wakeLock: wakeLock ?? this.wakeLock,
      restTimerSound: restTimerSound ?? this.restTimerSound,
      accentColor: accentColor ?? this.accentColor,
      leftHandMode: leftHandMode ?? this.leftHandMode,
      waterGoalLiters: waterGoalLiters ?? this.waterGoalLiters,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      showOldValues: prefs.getBool(AppConstants.keyShowOldValues) ?? true,
      showEpley: prefs.getBool(AppConstants.keyShowEpley) ?? true,
      showRPE: prefs.getBool(AppConstants.keyShowRPE) ?? true,
      showRepSuggest: prefs.getBool(AppConstants.keyShowRepSuggest) ?? true,
      wakeLock: prefs.getBool(AppConstants.keyWakeLock) ?? true,
      restTimerSound: prefs.getString(AppConstants.keyRestTimerSound) ?? 'bell',
      accentColor: prefs.getString(AppConstants.keyAccentColor) ?? '#4CAF50',
      leftHandMode: prefs.getBool(AppConstants.keyHandMode) ?? false,
    );
  }

  Future<void> update(AppSettings newSettings) async {
    state = newSettings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyShowOldValues, newSettings.showOldValues);
    await prefs.setBool(AppConstants.keyShowEpley, newSettings.showEpley);
    await prefs.setBool(AppConstants.keyShowRPE, newSettings.showRPE);
    await prefs.setBool(AppConstants.keyShowRepSuggest, newSettings.showRepSuggest);
    await prefs.setBool(AppConstants.keyWakeLock, newSettings.wakeLock);
    await prefs.setString(AppConstants.keyRestTimerSound, newSettings.restTimerSound);
    await prefs.setString(AppConstants.keyAccentColor, newSettings.accentColor);
    await prefs.setBool(AppConstants.keyHandMode, newSettings.leftHandMode);
  }
}

// ── Connection state ──────────────────────────────────────────────────────
final isConfiguredProvider = Provider<bool>((ref) => ApiService().isConfigured);

// ── Router ────────────────────────────────────────────────────────────────
final routerProvider = Provider<dynamic>((ref) {
  final user = ref.watch(currentUserProvider);
  return createRouter(user);
});
