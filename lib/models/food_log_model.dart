class FoodItemModel {
  final String name;
  final String nameEn;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double per100g;

  const FoodItemModel({
    required this.name,
    required this.nameEn,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.per100g = 100,
  });

  factory FoodItemModel.fromMap(Map<String, dynamic> map) {
    return FoodItemModel(
      name: map['name']?.toString() ?? '',
      nameEn: map['nameEn']?.toString() ?? map['name']?.toString() ?? '',
      calories: (map['cal'] ?? map['calories'] as num?)?.toDouble() ?? 0,
      protein: (map['pro'] ?? map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carb'] ?? map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      fiber: (map['fib'] ?? map['fiber'] as num?)?.toDouble() ?? 0,
      per100g: (map['per100g'] as num?)?.toDouble() ?? 100,
    );
  }

  FoodItemModel withAmount(double grams) {
    final factor = grams / per100g;
    return FoodItemModel(
      name: name,
      nameEn: nameEn,
      calories: calories * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      fiber: fiber * factor,
      per100g: grams,
    );
  }
}

class FoodLogEntry {
  final String id;
  final String uid;
  final String date;
  final String mealType;
  final String foodName;
  final double amount;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final DateTime timestamp;

  const FoodLogEntry({
    required this.id,
    required this.uid,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.amount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    required this.timestamp,
  });

  factory FoodLogEntry.fromMap(Map<String, dynamic> map) {
    return FoodLogEntry(
      id: map['id']?.toString() ?? '',
      uid: map['uid']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      mealType: map['mealType']?.toString() ?? 'snack',
      foodName: map['foodName']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0,
      timestamp: map['ts'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['ts'] as num).toInt())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'date': date,
        'mealType': mealType,
        'foodName': foodName,
        'amount': amount,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'ts': timestamp.millisecondsSinceEpoch,
      };
}

class DailyNutritionSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double totalWater;
  final List<FoodLogEntry> entries;

  const DailyNutritionSummary({
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.totalFiber = 0,
    this.totalWater = 0,
    this.entries = const [],
  });

  factory DailyNutritionSummary.fromEntries(List<FoodLogEntry> entries, {double water = 0}) {
    return DailyNutritionSummary(
      totalCalories: entries.fold(0, (s, e) => s + e.calories),
      totalProtein: entries.fold(0, (s, e) => s + e.protein),
      totalCarbs: entries.fold(0, (s, e) => s + e.carbs),
      totalFat: entries.fold(0, (s, e) => s + e.fat),
      totalFiber: entries.fold(0, (s, e) => s + e.fiber),
      totalWater: water,
      entries: entries,
    );
  }
}
