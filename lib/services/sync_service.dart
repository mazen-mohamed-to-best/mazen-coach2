import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:to_best/core/constants/api_actions.dart';
import 'package:to_best/core/network/api_service.dart';
import 'package:to_best/core/local_db/database_helper.dart';

class SyncService {
  final ApiService _api;
  final DatabaseHelper _db;
  Timer? _syncTimer;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  SyncService(this._api, this._db);

  void startAutoSync({Duration interval = const Duration(seconds: 30)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => flushQueue());
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        flushQueue();
      }
    });
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
    _connectivitySub?.cancel();
    _isSyncing = false;
  }

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<int> flushQueue() async {
    if (_isSyncing) return 0;
    if (!await isOnline() || !_api.isConfigured) return 0;
    _isSyncing = true;
    try {
      final queue = await _db.getSyncQueue();
      if (queue.isEmpty) return 0;
      int failed = 0;
      for (final item in queue) {
        final ok = await _pushItem(item);
        if (ok) {
          await _db.removeFromSyncQueue(item['id'] as int);
        } else {
          failed++;
        }
      }
      return failed;
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _pushItem(Map<String, dynamic> item) async {
    try {
      final res = await _api.call({
        'action': item['action'],
        'key': item['key'],
        'data': item['data'],
        'uid': item['uid'],
      });
      return res?['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> syncUserData(String uid) async {
    if (!await isOnline() || !_api.isConfigured) return false;
    try {
      final res = await _api.call({
        'action': ApiActions.fullSyncPull,
        'uid': uid,
      });
      if (res?['ok'] != true) {
        // fallback to basic user data
        final res2 = await _api.call({
          'action': ApiActions.fetchUserData,
          'uid': uid,
        });
        if (res2?['ok'] == true && res2?['data'] != null) {
          await _db.upsertUser(uid, res2!['data'] as Map<String, dynamic>);
          return true;
        }
        return false;
      }
      final data = res!['data'] as Map<String, dynamic>;
      await _seedFromCloud(uid, data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _seedFromCloud(String uid, Map<String, dynamic> data) async {
    // Store user profile
    if (data['user'] != null) {
      await _db.upsertUser(uid, data['user'] as Map<String, dynamic>);
    } else {
      await _db.upsertUser(uid, data);
    }

    // Store workout logs
    final logs = data['workoutLogs'] as List? ?? [];
    for (final log in logs) {
      final m = log as Map<String, dynamic>;
      await _db.upsertWorkoutLog(
        m['id']?.toString() ?? '${uid}_${m['date']}',
        uid,
        m['date']?.toString() ?? '',
        m['sessionName']?.toString() ?? '',
        m,
      );
    }

    // Store food logs
    final foodLogs = data['foodLogs'] as List? ?? [];
    for (final fl in foodLogs) {
      final m = fl as Map<String, dynamic>;
      await _db.upsertFoodLog(
        m['id']?.toString() ?? '${uid}_${m['date']}_${m['mealType']}',
        uid,
        m['date']?.toString() ?? '',
        m['mealType']?.toString() ?? 'snack',
        m,
      );
    }

    // Store attendance
    final attendance = data['attendance'] as List? ?? [];
    for (final att in attendance) {
      final m = att as Map<String, dynamic>;
      await _db.upsertAttendance(
        m['id']?.toString() ?? '${uid}_${m['date']}',
        uid,
        m['date']?.toString() ?? '',
        m['type']?.toString() ?? 'rest',
      );
    }
  }

  Future<bool> pushSnapshot(String uid, Map<String, dynamic> snapshot) async {
    if (!await isOnline() || !_api.isConfigured) return false;
    final res = await _api.call({
      'action': ApiActions.updateUserSheet,
      'uid': uid,
      'snapshot': snapshot,
    });
    return res?['ok'] == true;
  }

  Future<bool> queueOrPush(
    String action,
    String key,
    Map<String, dynamic> data,
    String uid,
  ) async {
    final online = await isOnline();
    if (online && _api.isConfigured) {
      final res = await _api.call({
        'action': action,
        'key': key,
        'data': data,
        'uid': uid,
      });
      if (res?['ok'] == true) return true;
    }
    // Queue for later
    await _db.addToSyncQueue(action, key, data, uid);
    return false;
  }
}
