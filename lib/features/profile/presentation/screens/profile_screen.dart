import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/user_model.dart';
import 'package:to_best/providers/app_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl.text = user?.name ?? '';
    _phoneCtrl.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadPicture() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final bytes = await File(file.path).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final result = await ref.read(adminServiceProvider).saveProfilePicture(user.uid, base64Image);
      if (result['ok'] == true && mounted) {
        final newPicUrl = result['url']?.toString();
        final updated = user.copyWith(pictureUrl: newPicUrl);
        ref.read(currentUserProvider.notifier).state = updated;
        await ref.read(databaseHelperProvider).upsertUser(user.uid, updated.toMap());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الصورة'), backgroundColor: AppColors.success));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final ok = await ref.read(adminServiceProvider).updateUser(user.uid, {'name': _nameCtrl.text.trim(), 'phone': _phoneCtrl.text.trim()});
      if (ok && mounted) {
        final updated = user.copyWith(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim());
        ref.read(currentUserProvider.notifier).state = updated;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ'), backgroundColor: AppColors.success));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _uploadPicture,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      backgroundImage: user?.pictureUrl != null ? NetworkImage(user!.pictureUrl!) : null,
                      child: user?.pictureUrl == null
                          ? Text(user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : '?', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primary, fontFamily: 'Cairo'))
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: _uploading ? const Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
            Text(user?.displayName ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700)).animate().fadeIn(delay: 200.ms),
            Text(user?.email ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey)).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 4),
            _buildRoleBadge(user),
            const SizedBox(height: 28),
            // Fields
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline)),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone_outlined)),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: user?.programId ?? '-',
              enabled: false,
              decoration: const InputDecoration(labelText: 'البرنامج التدريبي', prefixIcon: Icon(Icons.folder_special_outlined)),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 28),
            // Subscription info
            if (user?.subscriptionInfo != null) _buildSubscriptionCard(user!, loc),
            // Referral
            if (user?.referralCode != null) _buildReferralCard(user!, loc),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveProfile,
                child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(loc.save),
              ),
            ).animate().fadeIn(delay: 450.ms),
            const SizedBox(height: 16),
            // Change password
            SizedBox(
              width: double.infinity, height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock_outline, size: 16),
                label: Text(loc.changePassword),
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserModel? user) {
    final roleNames = {'superadmin': 'سوبر أدمن', 'admin': 'أدمن', 'coach': 'مدرب', 'trainee': 'متدرب', 'viewer': 'مشاهد'};
    final roleColors = {'superadmin': AppColors.gold, 'admin': AppColors.warning, 'coach': AppColors.info, 'trainee': AppColors.primary, 'viewer': AppColors.textGrey};
    final role = user?.role ?? 'trainee';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: (roleColors[role] ?? AppColors.primary).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
      child: Text(roleNames[role] ?? role, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: roleColors[role] ?? AppColors.primary)),
    ).animate().fadeIn(delay: 280.ms);
  }

  Widget _buildSubscriptionCard(UserModel user, AppLocalizations loc) {
    final sub = user.subscriptionInfo!;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.card_membership_outlined, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text('الاشتراك', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Text(sub['plan']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
        if (sub['expiry'] != null) Text('ينتهي: ${sub['expiry']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
      ]),
    ).animate().fadeIn(delay: 420.ms);
  }

  Widget _buildReferralCard(UserModel user, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.card_giftcard_outlined, color: AppColors.gold, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('كود الإحالة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
          Text(user.referralCode!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 2)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Text('${user.referralCoins} نقطة', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold)),
        ),
      ]),
    ).animate().fadeIn(delay: 440.ms);
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تغيير كلمة المرور', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'القديمة')),
          const SizedBox(height: 8),
          TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'الجديدة')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(onPressed: () async {
            final user = ref.read(currentUserProvider);
            if (user == null) return;
            final ok = await ref.read(authServiceProvider).changePassword(user.uid, oldCtrl.text, newCtrl.text);
            if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'تم تغيير كلمة المرور' : 'فشل'), backgroundColor: ok ? AppColors.success : AppColors.error)); }
          }, child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo'))),
        ],
      ),
    );
  }
}
