import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:to_best/core/theme/app_theme.dart';

class HomeStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool loading;

  const HomeStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (loading) {
      return Shimmer.fromColors(
        baseColor: isDark ? AppColors.darkCard : Colors.grey[300]!,
        highlightColor: isDark ? AppColors.darkBorder : Colors.grey[100]!,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(unit, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textGrey)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
