import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/providers/app_providers.dart';

class PRListWidget extends ConsumerStatefulWidget {
  final String uid;
  const PRListWidget({super.key, required this.uid});

  @override
  ConsumerState<PRListWidget> createState() => _PRListWidgetState();
}

class _PRListWidgetState extends ConsumerState<PRListWidget> {
  Map<String, double> _prs = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPRs();
  }

  Future<void> _loadPRs() async {
    try {
      final workoutSvc = ref.read(workoutServiceProvider);
      final prs = await workoutSvc.getPersonalRecords(widget.uid);
      if (mounted) setState(() { _prs = prs; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    }

    if (_prs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, color: AppColors.textGrey, size: 20),
            SizedBox(width: 8),
            Text('لا توجد أرقام قياسية بعد — ابدأ تدريبك!', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey)),
          ],
        ),
      );
    }

    final topPRs = _prs.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        children: topPRs.take(5).toList().asMap().entries.map((entry) {
          final i = entry.key;
          final pr = entry.value;
          final medal = i == 0 ? AppColors.gold : i == 1 ? AppColors.silver : i == 2 ? AppColors.bronze : AppColors.textGrey;
          return Column(
            children: [
              if (i > 0) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: medal, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(pr.key, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                    Text('${pr.value.toStringAsFixed(1)} kg', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(width: 4),
                    Text('1RM', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textGrey)),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
