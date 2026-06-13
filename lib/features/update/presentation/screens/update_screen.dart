import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/version_model.dart';

class UpdateScreen extends StatelessWidget {
  final UpdateState state;
  final VersionInfo info;
  final String currentVersion;
  final VoidCallback? onSkip;

  const UpdateScreen({
    super.key,
    required this.state,
    required this.info,
    required this.currentVersion,
    this.onSkip,
  });

  bool get _canDismiss => state == UpdateState.optional;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = l.isArabic;

    return PopScope(
      canPop: _canDismiss,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Header ──────────────────────────────────────────
                const Spacer(flex: 1),
                _buildIcon(context).animate().scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 32),

                // ── Title ───────────────────────────────────────────
                Text(
                  _title(l, isAr),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),

                // ── Body message ────────────────────────────────────
                Text(
                  _body(l, isAr),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.72),
                    height: 1.7,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 28),

                // ── Version badge ────────────────────────────────────
                if (state != UpdateState.maintenance)
                  _VersionBadge(
                    current: currentVersion,
                    latest: info.latestVersion,
                    isAr: isAr,
                  ).animate().fadeIn(delay: 400.ms),

                const Spacer(flex: 2),

                // ── Download button ──────────────────────────────────
                if (state != UpdateState.maintenance &&
                    info.downloadUrl.isNotEmpty)
                  _DownloadButton(
                    url: info.downloadUrl,
                    label: isAr ? 'تحميل التحديث' : 'Download Update',
                  ).animate().slideY(
                        begin: 0.3,
                        delay: 500.ms,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),

                // ── Contact button (blocked) ─────────────────────────
                if (state == UpdateState.blocked && info.contactUrl.isNotEmpty)
                  ...[
                  const SizedBox(height: 12),
                  _ContactButton(
                    url: info.contactUrl,
                    label: isAr ? 'تواصل مع الدعم' : 'Contact Support',
                  ).animate().fadeIn(delay: 600.ms),
                ],

                // ── Skip button (optional only) ──────────────────────
                if (_canDismiss && onSkip != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      isAr ? 'لاحقاً' : 'Maybe Later',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    switch (state) {
      case UpdateState.optional:
        return _CircleIcon(
          icon: Icons.system_update_rounded,
          color: AppColors.primary,
        );
      case UpdateState.required:
        return _CircleIcon(
          icon: Icons.upgrade_rounded,
          color: AppColors.warning,
        );
      case UpdateState.blocked:
        return _CircleIcon(
          icon: Icons.block_rounded,
          color: AppColors.error,
        );
      case UpdateState.maintenance:
        return _CircleIcon(
          icon: Icons.build_circle_rounded,
          color: AppColors.info,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _title(AppLocalizations l, bool isAr) {
    switch (state) {
      case UpdateState.optional:
        return isAr ? 'تحديث متوفر ✨' : 'Update Available ✨';
      case UpdateState.required:
        return isAr ? 'تحديث إجباري 🔄' : 'Update Required 🔄';
      case UpdateState.blocked:
        return isAr ? 'نسخة غير مدعومة ⛔' : 'Version Not Supported ⛔';
      case UpdateState.maintenance:
        return isAr ? 'صيانة مجدولة 🔧' : 'Scheduled Maintenance 🔧';
      default:
        return '';
    }
  }

  String _body(AppLocalizations l, bool isAr) {
    // Custom message from GAS has priority
    final custom = isAr ? info.messageAr : info.messageEn;
    if (custom.isNotEmpty) return custom;

    switch (state) {
      case UpdateState.optional:
        return isAr
            ? 'يوجد إصدار جديد من التطبيق. يُنصح بالتحديث للحصول على أحدث المميزات وأفضل أداء.'
            : 'A new version is available. Update now to enjoy the latest features and improvements.';
      case UpdateState.required:
        return isAr
            ? 'يستلزم الإصدار الحالي التحديث للاستمرار في استخدام التطبيق. يرجى تحديث التطبيق الآن.'
            : 'This version requires an update to continue. Please update the app to proceed.';
      case UpdateState.blocked:
        return isAr
            ? 'إصدارك قديم جداً ولم يعد مدعوماً. يرجى تحميل أحدث إصدار أو التواصل مع الدعم الفني.'
            : 'Your version is too old and is no longer supported. Download the latest version or contact support.';
      case UpdateState.maintenance:
        return isAr ? info.maintenanceAr : info.maintenanceEn;
      default:
        return '';
    }
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _CircleIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Icon(icon, size: 52, color: color),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  final String current;
  final String latest;
  final bool isAr;
  const _VersionBadge(
      {required this.current, required this.latest, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tag(isAr ? 'الحالية' : 'Current', current, AppColors.textGrey),
          Container(
            width: 1,
            height: 32,
            color: AppColors.darkBorder,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _tag(isAr ? 'المتوفرة' : 'Available', latest, AppColors.primary),
        ],
      ),
    );
  }

  Widget _tag(String label, String version, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: Colors.white.withOpacity(0.5))),
        const SizedBox(height: 4),
        Text(version,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final String url;
  final String label;
  const _DownloadButton({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _launch(url),
        icon: const Icon(Icons.download_rounded, size: 22),
        label: Text(label,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) await launchUrl(uri,
        mode: LaunchMode.externalApplication);
  }
}

class _ContactButton extends StatelessWidget {
  final String url;
  final String label;
  const _ContactButton({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.support_agent_rounded, size: 20),
        label: Text(label,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 15)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.info,
          side: BorderSide(color: AppColors.info.withOpacity(0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
