import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/network/api_service.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/core/utils/secure_settings.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/providers/app_providers.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});
  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _urlCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  bool _loading = false;
  bool _testing = false;
  String? _msg;
  bool _msgOk = false;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(AppConstants.keyWebAppUrl) ?? '';
    final key = await SecureSettings.instance.getSecretKey();
    _urlCtrl.text = url;
    _keyCtrl.text = key;
    if (url.isNotEmpty) {
      ApiService().configure(url, prefs.getString(AppConstants.keySessionToken) ?? '');
    }
  }

  Future<void> _save() async {
    setState(() { _loading = true; _msg = null; });
    try {
      final url = _urlCtrl.text.trim();
      final key = _keyCtrl.text.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyWebAppUrl, url);
      await SecureSettings.instance.setSecretKey(key);
      ApiService().configure(url, prefs.getString(AppConstants.keySessionToken) ?? '');
      setState(() { _msg = 'تم الحفظ بنجاح ✓'; _msgOk = true; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // BUG FIX: _test() now:
  //
  // 1. Validates that URL field is not empty before proceeding.
  //
  // 2. Pre-configures ApiService with the URL currently typed in the
  //    field (not just whatever was last saved to SharedPreferences).
  //    BEFORE: if user hadn't clicked Save first, ApiService._webAppUrl
  //    was still empty → isConfigured=false → call() returned null
  //    immediately without hitting the network at all.
  //
  // 3. Correctly compares the return value of testConnection() which
  //    now returns String? (null=ok, String=error message).
  //    BEFORE: testConnection() returned bool, but the code compared it
  //    to null — bool is NEVER null in Dart → always showed "فشل الاتصال".
  // ─────────────────────────────────────────────────────────────────────
  Future<void> _test() async {
    final url = _urlCtrl.text.trim();

    // Guard: don't even try if URL field is empty
    if (url.isEmpty) {
      setState(() {
        _msg = 'أدخل رابط Web App أولاً ثم اختبر الاتصال';
        _msgOk = false;
      });
      return;
    }

    setState(() { _testing = true; _msg = null; });
    try {
      // Pre-configure ApiService with the current URL so the test uses
      // what the user typed, not what was last persisted.
      // Note: we pass empty string for sessionToken — it's irrelevant for PING.
      ApiService().configure(url, '');

      final authSvc = ref.read(authServiceProvider);
      final err = await authSvc.testConnection(); // String? — null = success
      setState(() {
        _msg = err == null ? 'تم الاتصال بنجاح ✓' : 'فشل الاتصال: $err';
        _msgOk = err == null;
      });
    } finally {
      if (mounted) setState(() { _testing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.googleSheets)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text('أدخل رابط WebApp الخاص بـ Google Apps Script ومفتاح الأمان.', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13))),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: loc.webAppUrl, prefixIcon: const Icon(Icons.link), hintText: 'https://script.google.com/macros/s/.../exec'),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            TextFormField(
              controller: _keyCtrl,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                labelText: loc.secretKey,
                prefixIcon: const Icon(Icons.key_outlined),
                suffixIcon: IconButton(icon: Icon(_obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscureKey = !_obscureKey)),
              ),
            ).animate().fadeIn(delay: 200.ms),
            if (_msg != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_msgOk ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Icon(_msgOk ? Icons.check_circle_outline : Icons.error_outline, color: _msgOk ? AppColors.success : AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_msg!, style: TextStyle(fontFamily: 'Cairo', color: _msgOk ? AppColors.success : AppColors.error, fontSize: 13))),
                ]),
              ).animate().fadeIn().shake(hz: _msgOk ? 0 : 4),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(height: 52, child: OutlinedButton.icon(
                    onPressed: _testing ? null : _test,
                    icon: _testing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.wifi_find_outlined),
                    label: Text(loc.testConnection),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(height: 52, child: ElevatedButton.icon(
                    onPressed: _loading ? null : _save,
                    icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_outlined),
                    label: Text(loc.save),
                  )),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 52,
              child: TextButton(onPressed: () => context.pop(), child: Text(loc.back)),
            ),
          ],
        ),
      ),
    );
  }
}
