import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/providers/app_providers.dart';
import 'package:to_best/features/auth/presentation/widgets/auth_header.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confirmPassCtrl.dispose(); _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; _success = null; });
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.register({
        'fullName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'password': _passCtrl.text.trim(),
        if (_referralCtrl.text.isNotEmpty) 'referralCode': _referralCtrl.text.trim(),
      });
      if (!mounted) return;
      if (result.ok) {
        setState(() { _success = 'تم إنشاء الحساب! في انتظار موافقة المدرب.'; });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/login');
      } else {
        setState(() { _error = _mapError(result.error); });
      }
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  String _mapError(String? err) {
    switch (err) {
      case 'not_configured': return 'الرجاء إعداد رابط الخادم أولاً';
      case 'network': return 'خطأ في الاتصال. تحقق من الإنترنت.';
      case 'email_exists': return 'البريد الإلكتروني مستخدم بالفعل';
      default: return 'حدث خطأ. حاول مرة أخرى.';
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
              ? const LinearGradient(colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              : const LinearGradient(colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios)),
                    const Spacer(),
                  ],
                ),
                const AuthHeader().animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(controller: _nameCtrl, label: loc.fullName, icon: Icons.person_outline, action: TextInputAction.next),
                      const SizedBox(height: 12),
                      _buildField(controller: _emailCtrl, label: loc.email, icon: Icons.email_outlined, type: TextInputType.emailAddress, action: TextInputAction.next),
                      const SizedBox(height: 12),
                      _buildField(controller: _phoneCtrl, label: loc.phone, icon: Icons.phone_outlined, type: TextInputType.phone, action: TextInputAction.next),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: loc.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure)),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'كلمة المرور قصيرة' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPassCtrl,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: loc.confirmPass,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                        ),
                        validator: (v) => v != _passCtrl.text ? 'كلمات المرور غير متطابقة' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildField(controller: _referralCtrl, label: 'كود الإحالة (اختياري)', icon: Icons.card_giftcard_outlined, action: TextInputAction.done, required: false),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        _buildMessage(_error!, AppColors.error, Icons.error_outline),
                      ],
                      if (_success != null) ...[
                        const SizedBox(height: 12),
                        _buildMessage(_success!, AppColors.success, Icons.check_circle_outline),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text(loc.registerBtn),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text('لديك حساب؟ ${loc.login}'),
                      ),
                      const SizedBox(height: 24),
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

  Widget _buildField({required TextEditingController controller, required String label, required IconData icon, TextInputType type = TextInputType.text, TextInputAction action = TextInputAction.next, bool required = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      textInputAction: action,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'مطلوب' : null : null,
    );
  }

  Widget _buildMessage(String msg, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.4))),
      child: Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), Expanded(child: Text(msg, style: TextStyle(color: color, fontSize: 13, fontFamily: 'Cairo')))]),
    ).animate().fadeIn().shake();
  }
}
