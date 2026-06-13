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
import 'package:to_best/features/auth/presentation/widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (!mounted) return;
      if (result.ok && result.user != null) {
        ref.read(currentUserProvider.notifier).state = result.user;
        context.go('/');
      } else {
        setState(() { _error = _mapError(result.error); });
      }
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  String _mapError(String? err) {
    final loc = AppLocalizations.of(context)!;
    switch (err) {
      case 'not_configured': return 'الرجاء إعداد رابط الخادم أولاً في الإعدادات';
      case 'network': return loc.connFail;
      case 'invalid_credentials': return 'بيانات الدخول غير صحيحة';
      case 'banned': return 'تم حظر هذا الحساب';
      default: return loc.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF0D1A0D)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              : const LinearGradient(colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF), Color(0xFFE8F5E9)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const AuthHeader().animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: loc.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: loc.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.error.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13, fontFamily: 'Cairo'))),
                            ],
                          ),
                        ).animate().fadeIn().shake(),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Text(loc.loginBtn),
                        ),
                      ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => context.push('/register'),
                          child: Text(loc.register),
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.push('/setup'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.settings_outlined, size: 16),
                            const SizedBox(width: 6),
                            Text(loc.googleSheets, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
