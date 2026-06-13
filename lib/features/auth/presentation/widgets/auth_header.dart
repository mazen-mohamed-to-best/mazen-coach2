import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';

class AuthHeader extends ConsumerWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: isDark
                ? Image.asset('assets/icons/icon_dark.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildFallbackIcon())
                : Image.asset('assets/icons/icon_light.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildFallbackIcon()),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'TO Best',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          loc.tagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: AppColors.primary,
      child: const Center(
        child: Text('TB', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
      ),
    );
  }
}
