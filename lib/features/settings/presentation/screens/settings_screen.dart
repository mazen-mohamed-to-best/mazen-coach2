import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final isAr = locale?.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          _sectionHeader(loc.appearance, Icons.palette_outlined).animate().fadeIn(),
          _card([
            _switchTile(
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              label: loc.darkMode,
              value: isDark,
              onChanged: (v) async {
                final mode = v ? ThemeMode.dark : ThemeMode.light;
                ref.read(themeModeProvider.notifier).state = mode;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(AppConstants.keyTheme, v ? AppConstants.themeDark : AppConstants.themeLight);
              },
            ),
            const Divider(height: 1),
            _switchTile(
              icon: Icons.language,
              label: loc.language,
              value: isAr,
              onChanged: (v) async {
                final newLocale = v ? const Locale('ar') : const Locale('en');
                ref.read(localeProvider.notifier).state = newLocale;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(AppConstants.keyLanguage, v ? 'ar' : 'en');
              },
              subtitle: isAr ? 'العربية' : 'English',
            ),
            const Divider(height: 1),
            _switchTile(
              icon: Icons.swap_horiz,
              label: loc.leftHandMode,
              value: settings.leftHandMode,
              onChanged: (v) => ref.read(settingsProvider.notifier).update(settings.copyWith(leftHandMode: v)),
            ),
          ]).animate().fadeIn(delay: 50.ms),

          const SizedBox(height: 16),

          // Workout settings
          _sectionHeader(loc.workoutSettings, Icons.fitness_center_outlined).animate().fadeIn(delay: 100.ms),
          _card([
            _switchTile(icon: Icons.history_rounded, label: loc.showOldValues, value: settings.showOldValues, onChanged: (v) => ref.read(settingsProvider.notifier).update(settings.copyWith(showOldValues: v))),
            const Divider(height: 1),
            _switchTile(icon: Icons.calculate_outlined, label: 'إظهار الـ 1RM (Epley)', value: settings.showEpley, onChanged: (v) => ref.read(settingsProvider.notifier).update(settings.copyWith(showEpley: v))),
            const Divider(height: 1),
            _switchTile(icon: Icons.speed_outlined, label: 'إظهار RPE', value: settings.showRPE, onChanged: (v) => ref.read(settingsProvider.notifier).update(settings.copyWith(showRPE: v))),
            const Divider(height: 1),
            _switchTile(icon: Icons.star_outline, label: 'اقتراح التكرارات', value: settings.showRepSuggest, onChanged: (v) => ref.read(settingsProvider.notifier).update(settings.copyWith(showRepSuggest: v))),
            const Divider(height: 1),
            _switchTile(icon: Icons.screen_lock_portrait_outlined, label: loc.wakeLock, value: settings.wakeLock, onChanged: (v) => ref.read(settingsProvider.notifier).update(settings.copyWith(wakeLock: v))),
          ]).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 16),

          // Nutrition settings
          _sectionHeader('التغذية', Icons.restaurant_menu_outlined).animate().fadeIn(delay: 200.ms),
          _card([
            _sliderTile(
              icon: Icons.water_drop_outlined,
              label: loc.waterGoal,
              value: settings.waterGoalLiters,
              min: 1.0,
              max: 5.0,
              divisions: 16,
              suffix: 'L',
              onChanged: (v) => ref.read(settingsProvider.notifier).update(settings.copyWith(waterGoalLiters: v)),
            ),
          ]).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 16),

          // Connection
          _sectionHeader(loc.connectionSettings, Icons.link_rounded).animate().fadeIn(delay: 300.ms),
          _card([
            ListTile(
              leading: const Icon(Icons.link, color: AppColors.primary),
              title: Text(loc.googleSheets, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => context.push('/setup'),
            ),
          ]).animate().fadeIn(delay: 350.ms),

          const SizedBox(height: 16),

          // About
          _sectionHeader(loc.about, Icons.info_outline).animate().fadeIn(delay: 400.ms),
          _card([
            ListTile(
              leading: const Icon(Icons.app_settings_alt_outlined, color: AppColors.primary),
              title: const Text('TO Best', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text(AppConstants.appVersion, style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
            ),
          ]).animate().fadeIn(delay: 450.ms),

          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () async {
                await ref.read(authServiceProvider).logout();
                ref.read(currentUserProvider.notifier).state = null;
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: Text(loc.logout, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    );
  }

  Widget _card(List<Widget> children) {
    return Builder(builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(children: children),
    ));
  }

  Widget _switchTile({required IconData icon, required String label, required bool value, required ValueChanged<bool> onChanged, String? subtitle}) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)) : null,
      value: value,
      onChanged: onChanged,
      dense: true,
    );
  }

  Widget _sliderTile({required IconData icon, required String label, required double value, required double min, required double max, required int divisions, required String suffix, required ValueChanged<double> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
          const Spacer(),
          Text('${value.toStringAsFixed(1)} $suffix', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
        Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged),
      ]),
    );
  }
}
