import 'package:to_best/core/local_db/database_helper.dart';
import 'package:to_best/models/food_log_model.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:uuid/uuid.dart';

class NutritionService {
  final DatabaseHelper _db;
  final SyncService _sync;
  final _uuid = const Uuid();

  NutritionService(this._db, this._sync);

  Future<List<FoodLogEntry>> getTodayLogs(String uid) async {
    final today = _todayStr();
    final data = await _db.getFoodLogs(uid, date: today);
    return data.map(FoodLogEntry.fromMap).toList();
  }

  Future<List<FoodLogEntry>> getLogsForDate(String uid, String date) async {
    final data = await _db.getFoodLogs(uid, date: date);
    return data.map(FoodLogEntry.fromMap).toList();
  }

  Future<bool> addFoodEntry(String uid, FoodLogEntry entry) async {
    final id = entry.id.isNotEmpty ? entry.id : _uuid.v4();
    final data = entry.toMap()..['id'] = id;
    await _db.upsertFoodLog(id, uid, entry.date, entry.mealType, data);
    return await _sync.queueOrPush('SAVE_FOOD_LOG', 'food_$id', data, uid);
  }

  Future<bool> deleteFoodEntry(String uid, String entryId) async {
    await _db.deleteFoodLog(entryId);
    return await _sync.queueOrPush(
        'DELETE_FOOD_LOG', 'food_$entryId', {'id': entryId}, uid);
  }

  Future<DailyNutritionSummary> getDailySummary(String uid, {String? date}) async {
    final d = date ?? _todayStr();
    final entries = await getLogsForDate(uid, d);
    final waterStr = await _db.getKV('water_${uid}_$d');
    final water = double.tryParse(waterStr ?? '0') ?? 0;
    return DailyNutritionSummary.fromEntries(entries, water: water);
  }

  Future<void> setWaterIntake(String uid, double liters) async {
    final today = _todayStr();
    await _db.setKV('water_${uid}_$today', liters.toString());
    await _sync.queueOrPush(
        'SAVE_WATER', 'water_${uid}_$today', {'uid': uid, 'date': today, 'water': liters}, uid);
  }

  Future<double> getWaterIntake(String uid) async {
    final today = _todayStr();
    final v = await _db.getKV('water_${uid}_$today');
    return double.tryParse(v ?? '0') ?? 0;
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}
