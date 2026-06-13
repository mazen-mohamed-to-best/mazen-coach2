import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:to_best/core/local_db/database_helper.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/core/utils/router.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/version_model.dart';
import 'package:to_best/providers/app_providers.dart';
import 'package:to_best/providers/version_provider.dart';
import 'package:to_best/features/update/presentation/screens/update_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await DatabaseHelper.instance.initialize();
  runApp(const ProviderScope(child: ToBestApp()));
}

class ToBestApp extends ConsumerWidget {
  const ToBestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TO Best',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final isArabic = locale?.languageCode == 'ar';
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: _VersionGate(child: child ?? const SizedBox()),
        );
      },
    );
  }
}

/// Wraps the entire app — intercepts navigation if update/block is needed.
class _VersionGate extends ConsumerWidget {
  final Widget child;
  const _VersionGate({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(versionCheckProvider);
    final dismissed = ref.watch(updateDismissedProvider);

    return versionAsync.when(
      // ── Loading: show splash while checking ─────────────────────────
      loading: () => const _SplashLoader(),

      // ── Error: treat as offline → allow app to run ───────────────────
      error: (_, __) => child,

      // ── Result ──────────────────────────────────────────────────────
      data: (result) {
        switch (result.state) {
          // Blocked or maintenance: full-screen, NO back navigation
          case UpdateState.blocked:
          case UpdateState.maintenance:
            return UpdateScreen(
              state: result.state,
              info: result.info,
              currentVersion: result.currentVersion,
            );

          // Required: full-screen forced, cannot dismiss
          case UpdateState.required:
            return UpdateScreen(
              state: result.state,
              info: result.info,
              currentVersion: result.currentVersion,
            );

          // Optional: show update screen until user taps "Later"
          case UpdateState.optional:
            if (dismissed) return child;
            return UpdateScreen(
              state: result.state,
              info: result.info,
              currentVersion: result.currentVersion,
              onSkip: () =>
                  ref.read(updateDismissedProvider.notifier).state = true,
            );

          // Up-to-date: normal app
          case UpdateState.upToDate:
            return child;
        }
      },
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.fitness_center_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 24),
            const Text(
              'TO Best',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
