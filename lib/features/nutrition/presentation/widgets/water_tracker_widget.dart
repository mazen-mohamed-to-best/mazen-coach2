import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/providers/app_providers.dart';

class WaterTrackerWidget extends ConsumerStatefulWidget {
  final VoidCallback? onUpdate;
  const WaterTrackerWidget({super.key, this.onUpdate});
  @override
  ConsumerState<WaterTrackerWidget> createState() => _WaterTrackerWidgetState();
}

class _WaterTrackerWidgetState extends ConsumerState<WaterTrackerWidget> {
  double _current = 0;
  double _goal = 3.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final nutritionSvc = ref.read(nutritionServiceProvider);
    final water = await nutritionSvc.getWaterIntake(user.uid);
    if (mounted) setState(() => _current = water);
  }

  Future<void> _add(double amount) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final newAmount = (_current + amount).clamp(0, _goal + 2).toDouble();
    await ref.read(nutritionServiceProvider).setWaterIntake(user.uid, newAmount);
    if (mounted) { setState(() => _current = newAmount); widget.onUpdate?.call(); }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final pct = (_current / _goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text(loc.waterTracker, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.info)),
              const Spacer(),
              Text('${_current.toStringAsFixed(1)} / ${_goal.toStringAsFixed(1)} L', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: pct, backgroundColor: AppColors.info.withOpacity(0.15), color: AppColors.info, minHeight: 8, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 10),
          Row(
            children: [0.25, 0.5, 0.75, 1.0].map((amt) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: OutlinedButton(
                  onPressed: () => _add(amt),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: const BorderSide(color: AppColors.info, width: 1),
                    minimumSize: const Size(0, 36),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('+${amt}L', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
