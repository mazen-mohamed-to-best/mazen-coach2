import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/food_log_model.dart';
import 'package:to_best/providers/app_providers.dart';
import 'package:to_best/features/nutrition/presentation/widgets/add_food_sheet.dart';
import 'package:to_best/features/nutrition/presentation/widgets/water_tracker_widget.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});
  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  DailyNutritionSummary? _summary;
  bool _loading = true;
  Map<String, dynamic>? _targets;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final nutritionSvc = ref.read(nutritionServiceProvider);
    final summary = await nutritionSvc.getDailySummary(user.uid);
    final userData = await ref.read(databaseHelperProvider).getUser(user.uid);
    if (mounted) {
      setState(() {
        _summary = summary;
        _targets = userData?['nutritionTargets'] as Map<String, dynamic>?;
        _loading = false;
      });
    }
  }

  double get _targetCals => (_targets?['calories'] as num?)?.toDouble() ?? 2000;
  double get _targetProtein => (_targets?['protein'] as num?)?.toDouble() ?? 150;
  double get _targetCarbs => (_targets?['carbs'] as num?)?.toDouble() ?? 250;
  double get _targetFat => (_targets?['fat'] as num?)?.toDouble() ?? 65;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final summary = _summary!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.nutrition)),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calories ring
              _buildCaloriesCard(summary, loc),
              const SizedBox(height: 16),
              // Macros
              _buildMacrosRow(summary, loc),
              const SizedBox(height: 16),
              // Water tracker
              WaterTrackerWidget(onUpdate: _loadData),
              const SizedBox(height: 16),
              // Meal sections
              ...['breakfast', 'lunch', 'dinner', 'snack'].map((meal) => _buildMealSection(context, meal, summary, loc)),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFood(context),
        icon: const Icon(Icons.add),
        label: Text(loc.addFood),
      ),
    );
  }

  Widget _buildCaloriesCard(DailyNutritionSummary summary, AppLocalizations loc) {
    final pct = (_targetCals > 0 ? summary.totalCalories / _targetCals : 0).clamp(0.0, 1.0);
    final remaining = (_targetCals - summary.totalCalories).clamp(0, double.infinity);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 55,
            lineWidth: 8,
            percent: pct,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(summary.totalCalories.toStringAsFixed(0), style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(loc.calories, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70)),
              ],
            ),
            progressColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(width: 20),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _calRow(loc.target, _targetCals),
              const SizedBox(height: 8),
              _calRow(loc.consumed, summary.totalCalories),
              const SizedBox(height: 8),
              _calRow(loc.remaining, remaining),
            ],
          )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _calRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70)),
        Text('${value.toStringAsFixed(0)} kcal', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }

  Widget _buildMacrosRow(DailyNutritionSummary summary, AppLocalizations loc) {
    return Row(
      children: [
        Expanded(child: _macroCard(loc.protein, summary.totalProtein, _targetProtein, AppColors.info, loc)),
        const SizedBox(width: 10),
        Expanded(child: _macroCard(loc.carbs, summary.totalCarbs, _targetCarbs, AppColors.warning, loc)),
        const SizedBox(width: 10),
        Expanded(child: _macroCard(loc.fat, summary.totalFat, _targetFat, AppColors.error, loc)),
      ],
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _macroCard(String label, double current, double target, Color color, AppLocalizations loc) {
    final pct = (target > 0 ? current / target : 0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: pct, backgroundColor: color.withOpacity(0.15), color: color, minHeight: 6, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 6),
          Text('${current.toStringAsFixed(0)}/${target.toStringAsFixed(0)}g', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildMealSection(BuildContext context, String mealType, DailyNutritionSummary summary, AppLocalizations loc) {
    final mealEntries = summary.entries.where((e) => e.mealType == mealType).toList();
    final mealNames = {'breakfast': loc.breakfast, 'lunch': loc.lunch, 'dinner': loc.dinner, 'snack': loc.snack};
    final mealIcons = {'breakfast': Icons.wb_sunny_outlined, 'lunch': Icons.restaurant_outlined, 'dinner': Icons.nightlight_outlined, 'snack': Icons.apple_outlined};
    final mealCals = mealEntries.fold(0.0, (s, e) => s + e.calories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(mealIcons[mealType] ?? Icons.food_bank_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(mealNames[mealType] ?? mealType, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${mealCals.toStringAsFixed(0)} kcal', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
            IconButton(icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary), onPressed: () => _showAddFood(context, preselectedMeal: mealType), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ],
        ),
        if (mealEntries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 26),
            child: Text(loc.noFoodToday, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
          )
        else
          ...mealEntries.map((entry) => _buildFoodEntry(entry)),
        const Divider(),
        const SizedBox(height: 4),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFoodEntry(FoodLogEntry entry) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), color: AppColors.error.withOpacity(0.1), child: const Icon(Icons.delete_outline, color: AppColors.error)),
      onDismissed: (_) async {
        final user = ref.read(currentUserProvider);
        if (user == null) return;
        await ref.read(nutritionServiceProvider).deleteFoodEntry(user.uid, entry.id);
        await _loadData();
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 26, bottom: 6),
        child: Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.foodName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${entry.amount.toStringAsFixed(0)}g', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGrey)),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${entry.calories.toStringAsFixed(0)} kcal', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text('P:${entry.protein.toStringAsFixed(0)} C:${entry.carbs.toStringAsFixed(0)} F:${entry.fat.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textGrey)),
            ]),
          ],
        ),
      ),
    );
  }

  void _showAddFood(BuildContext context, {String? preselectedMeal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AddFoodSheet(preselectedMeal: preselectedMeal, onAdded: _loadData),
    );
  }
}
