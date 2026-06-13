import 'package:to_best/core/constants/api_actions.dart';
import 'package:to_best/core/local_db/database_helper.dart';
import 'package:to_best/models/workout_log_model.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:uuid/uuid.dart';

class WorkoutService {
  final DatabaseHelper _db;
  final SyncService _sync;
  final _uuid = const Uuid();

  WorkoutService(this._db, this._sync);

  Future<List<WorkoutLogModel>> getWorkoutHistory(String uid, {String? date}) async {
    final logs = await _db.getWorkoutLogs(uid, date: date);
    return logs.map(WorkoutLogModel.fromMap).toList();
  }

  Future<WorkoutLogModel?> getTodayLog(String uid) async {
    final today = _todayStr();
    final data = await _db.getWorkoutLogByDate(uid, today);
    if (data == null) return null;
    return WorkoutLogModel.fromMap(data);
  }

  Future<bool> saveWorkoutLog(String uid, WorkoutLogModel log) async {
    final id = log.id.isNotEmpty ? log.id : _uuid.v4();
    final data = log.toMap()..['id'] = id;

    await _db.upsertWorkoutLog(
      id,
      uid,
      log.date,
      log.sessionName,
      data,
    );

    return await _sync.queueOrPush(
      'SAVE_WORKOUT_LOG',
      'workout_$id',
      data,
      uid,
    );
  }

  Future<Map<String, double>> getPersonalRecords(String uid) async {
    final logs = await _db.getWorkoutLogs(uid);
    final Map<String, double> prs = {};
    for (final logData in logs) {
      final log = WorkoutLogModel.fromMap(logData);
      for (final ex in log.exercises) {
        final best1RM = ex.best1RM;
        if (best1RM > 0) {
          if (!prs.containsKey(ex.name) || prs[ex.name]! < best1RM) {
            prs[ex.name] = best1RM;
          }
        }
      }
    }
    return prs;
  }

  Future<List<WorkoutLogModel>> getExerciseHistory(
      String uid, String exerciseName, {int limit = 10}) async {
    final logs = await _db.getWorkoutLogs(uid);
    final result = <WorkoutLogModel>[];
    for (final logData in logs) {
      final log = WorkoutLogModel.fromMap(logData);
      if (log.exercises.any((e) => e.name == exerciseName)) {
        result.add(log);
        if (result.length >= limit) break;
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> getProgressStats(String uid) async {
    final logs = await _db.getWorkoutLogs(uid);
    final totalSessions = logs.length;

    // Calculate streak
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = _dateStr(date);
      final hasLog = logs.any((l) => l['date'] == dateStr);
      if (hasLog) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    // Last workout
    String? lastWorkout;
    if (logs.isNotEmpty) {
      lastWorkout = logs.first['date']?.toString();
    }

    // Total volume
    double totalVolume = 0;
    for (final logData in logs) {
      final log = WorkoutLogModel.fromMap(logData);
      totalVolume += log.totalVolume;
    }

    return {
      'totalSessions': totalSessions,
      'streak': streak,
      'lastWorkout': lastWorkout,
      'totalVolume': totalVolume,
    };
  }

  String _todayStr() => _dateStr(DateTime.now());
  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// Progress evaluator
String evaluateProgress(double current, double previous) {
  if (previous == 0) return 'ev_beg';
  final diff = current - previous;
  final pct = diff / previous * 100;
  if (pct >= 10) return 'ev_s1';
  if (pct >= 5) return 'ev_s2';
  if (pct >= 2.5) return 'ev_s3';
  if (pct > 0) return 'ev_gd';
  if (pct == 0) return 'ev_st';
  if (pct > -5) return 'ev_ws';
  if (pct <= -5) return 'ev_dn';
  return 'ev_rv';
}
