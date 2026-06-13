import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/food_log_model.dart';
import 'package:to_best/providers/app_providers.dart';
import 'package:uuid/uuid.dart';

class AddFoodSheet extends ConsumerStatefulWidget {
  final String? preselectedMeal;
  final VoidCallback? onAdded;
  const AddFoodSheet({super.key, this.preselectedMeal, this.onAdded});

  @override
  ConsumerState<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<AddFoodSheet> {
  final _searchCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '100');
  String _selectedMeal = 'breakfast';
  FoodItemModel? _selectedFood;
  bool _saving = false;
  final _uuid = const Uuid();

  // Simple food database (subset)
  static const List<Map<String, dynamic>> _foodDb = [
    {'name': 'بيض مسلوق', 'nameEn': 'Boiled Egg', 'cal': 155, 'pro': 13, 'carb': 1.1, 'fat': 11, 'fib': 0},
    {'name': 'صدر دجاج مشوي', 'nameEn': 'Grilled Chicken Breast', 'cal': 165, 'pro': 31, 'carb': 0, 'fat': 3.6, 'fib': 0},
    {'name': 'أرز أبيض مطبوخ', 'nameEn': 'Cooked White Rice', 'cal': 130, 'pro': 2.7, 'carb': 28, 'fat': 0.3, 'fib': 0.4},
    {'name': 'خبز أبيض', 'nameEn': 'White Bread', 'cal': 265, 'pro': 9, 'carb': 49, 'fat': 3.2, 'fib': 2.7},
    {'name': 'حليب كامل الدسم', 'nameEn': 'Whole Milk', 'cal': 61, 'pro': 3.2, 'carb': 4.8, 'fat': 3.3, 'fib': 0},
    {'name': 'موز', 'nameEn': 'Banana', 'cal': 89, 'pro': 1.1, 'carb': 23, 'fat': 0.3, 'fib': 2.6},
    {'name': 'تفاحة', 'nameEn': 'Apple', 'cal': 52, 'pro': 0.3, 'carb': 14, 'fat': 0.2, 'fib': 2.4},
    {'name': 'لوز', 'nameEn': 'Almonds', 'cal': 579, 'pro': 21, 'carb': 22, 'fat': 50, 'fib': 12.5},
    {'name': 'تونة مسلوقة', 'nameEn': 'Canned Tuna', 'cal': 116, 'pro': 26, 'carb': 0, 'fat': 1, 'fib': 0},
    {'name': 'عدس مطبوخ', 'nameEn': 'Cooked Lentils', 'cal': 116, 'pro': 9, 'carb': 20, 'fat': 0.4, 'fib': 8},
    {'name': 'بطاطس مسلوقة', 'nameEn': 'Boiled Potato', 'cal': 77, 'pro': 2, 'carb': 17, 'fat': 0.1, 'fib': 1.8},
    {'name': 'زبادي يوناني', 'nameEn': 'Greek Yogurt', 'cal': 59, 'pro': 10, 'carb': 3.6, 'fat': 0.4, 'fib': 0},
    {'name': 'شوفان', 'nameEn': 'Oats', 'cal': 379, 'pro': 13, 'carb': 67, 'fat': 7, 'fib': 10},
    {'name': 'بروتين واي', 'nameEn': 'Whey Protein', 'cal': 400, 'pro': 80, 'carb': 10, 'fat': 5, 'fib': 0},
    {'name': 'سلطة خضراء', 'nameEn': 'Green Salad', 'cal': 20, 'pro': 1.5, 'carb': 3.5, 'fat': 0.2, 'fib': 2},
    {'name': 'قهوة سوداء', 'nameEn': 'Black Coffee', 'cal': 2, 'pro': 0.3, 'carb': 0, 'fat': 0, 'fib': 0},
    {'name': 'زيت زيتون', 'nameEn': 'Olive Oil', 'cal': 884, 'pro': 0, 'carb': 0, 'fat': 100, 'fib': 0},
    {'name': 'جبنة قريش', 'nameEn': 'Cottage Cheese', 'cal': 98, 'pro': 11, 'carb': 3.4, 'fat': 4.3, 'fib': 0},
  ];

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _foodDb;
    return _foodDb.where((f) => f['name'].toString().contains(q) || f['nameEn'].toString().toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.preselectedMeal ?? 'breakfast';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedFood == null) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final amount = double.tryParse(_amountCtrl.text) ?? 100;
      final item = _selectedFood!.withAmount(amount);
      final today = _todayStr();
      final entry = FoodLogEntry(
        id: _uuid.v4(),
        uid: user.uid,
        date: today,
        mealType: _selectedMeal,
        foodName: item.name,
        amount: amount,
        calories: item.calories,
        protein: item.protein,
        carbs: item.carbs,
        fat: item.fat,
        fiber: item.fiber,
        timestamp: DateTime.now(),
      );
      await ref.read(nutritionServiceProvider).addFoodEntry(user.uid, entry);
      widget.onAdded?.call();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scroll) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textGrey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(loc.addFood, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            // Meal selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButtonFormField<String>(
                value: _selectedMeal,
                decoration: InputDecoration(labelText: loc.mealTime, isDense: true),
                items: [
                  DropdownMenuItem(value: 'breakfast', child: Text(loc.breakfast)),
                  DropdownMenuItem(value: 'lunch', child: Text(loc.lunch)),
                  DropdownMenuItem(value: 'dinner', child: Text(loc.dinner)),
                  DropdownMenuItem(value: 'snack', child: Text(loc.snack)),
                ],
                onChanged: (v) => setState(() => _selectedMeal = v!),
              ),
            ),
            const SizedBox(height: 12),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(labelText: loc.searchFood, prefixIcon: const Icon(Icons.search), isDense: true),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            // Selected food + amount
            if (_selectedFood != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_selectedFood!.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: loc.amount, isDense: true, suffixText: 'g'),
                        onChanged: (_) => setState(() {}),
                      )),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${(_selectedFood!.calories * (double.tryParse(_amountCtrl.text) ?? 100) / 100).toStringAsFixed(0)} kcal', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        Text('P:${(_selectedFood!.protein * (double.tryParse(_amountCtrl.text) ?? 100) / 100).toStringAsFixed(0)}g', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGrey)),
                      ]),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(loc.save)),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Divider(),
            Expanded(child: ListView.builder(
              controller: scroll,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final food = _filtered[i];
                final item = FoodItemModel.fromMap(food);
                final isSelected = _selectedFood?.name == item.name;
                return ListTile(
                  title: Text(item.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('${item.calories.toStringAsFixed(0)} kcal • P:${item.protein.toStringAsFixed(0)} C:${item.carbs.toStringAsFixed(0)} F:${item.fat.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                  trailing: Icon(isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline, color: isSelected ? AppColors.success : AppColors.primary),
                  selected: isSelected,
                  selectedTileColor: AppColors.primary.withOpacity(0.05),
                  onTap: () => setState(() { _selectedFood = item; if (_amountCtrl.text.isEmpty) _amountCtrl.text = '100'; }),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
