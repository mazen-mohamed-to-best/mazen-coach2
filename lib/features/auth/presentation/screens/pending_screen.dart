import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/providers/app_providers.dart';
import 'package:to_best/services/sync_service.dart';

class PendingScreen extends ConsumerStatefulWidget {
  const PendingScreen({super.key});
  @override
  ConsumerState<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends ConsumerState<PendingScreen> {
  bool _checking = false;

  Future<void> _checkStatus() async {
    setState(() => _checking = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final sync = ref.read(syncServiceProvider);
      final ok = await sync.syncUserData(user.uid);
      if (ok && mounted) {
        final updatedData = await ref.read(databaseHelperProvider).getUser(user.uid);
        if (updatedData != null && mounted) {
          final updatedUser = user.copyWith(status: updatedData['status']?.toString());
          ref.read(currentUserProvider.notifier).state = updatedUser;
          if (updatedUser.isActive) context.go('/');
        }
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final isRejected = user?.isRejected ?? false;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: (isRejected ? AppColors.error : AppColors.warning).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(isRejected ? Icons.cancel_outlined : Icons.hourglass_top_rounded, size: 60, color: isRejected ? AppColors.error : AppColors.warning),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 32),
              Text(
                isRejected ? loc.rejected : loc.pendingApproval,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w700),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                isRejected ? loc.rejectedDesc : loc.pendingDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textGrey),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 48),
              if (!isRejected)
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _checking ? null : _checkStatus,
                    icon: _checking ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.refresh),
                    label: Text(_checking ? loc.loading : 'تحقق من الحالة'),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).logout();
                  ref.read(currentUserProvider.notifier).state = null;
                  if (context.mounted) context.go('/login');
                },
                child: Text(loc.logout, style: const TextStyle(color: AppColors.error)),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
