import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<void> initialize() async {
    _db = await _initDb();
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'to_best_cache.db');
    return openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE users (uid TEXT PRIMARY KEY, data TEXT NOT NULL, updated_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE workout_logs (id TEXT PRIMARY KEY, uid TEXT NOT NULL, date TEXT NOT NULL, session_name TEXT NOT NULL, data TEXT NOT NULL, synced INTEGER DEFAULT 0, updated_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE food_logs (id TEXT PRIMARY KEY, uid TEXT NOT NULL, date TEXT NOT NULL, meal_type TEXT NOT NULL, data TEXT NOT NULL, synced INTEGER DEFAULT 0, updated_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE attendance (id TEXT PRIMARY KEY, uid TEXT NOT NULL, date TEXT NOT NULL, type TEXT NOT NULL, synced INTEGER DEFAULT 0, updated_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE sync_queue (id INTEGER PRIMARY KEY AUTOINCREMENT, action TEXT NOT NULL, key_name TEXT NOT NULL, data TEXT NOT NULL, uid TEXT NOT NULL, created_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE kv_store (key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE chat_messages (id TEXT PRIMARY KEY, room_id TEXT NOT NULL, data TEXT NOT NULL, cached_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE custom_exercises (id TEXT PRIMARY KEY, uid TEXT NOT NULL, data TEXT NOT NULL, synced INTEGER DEFAULT 0, updated_at INTEGER NOT NULL)''');
    await db.execute('CREATE INDEX idx_wl_uid_date ON workout_logs(uid, date)');
    await db.execute('CREATE INDEX idx_fl_uid_date ON food_logs(uid, date)');
    await db.execute('CREATE INDEX idx_att_uid_date ON attendance(uid, date)');
    await db.execute('CREATE INDEX idx_chat_room ON chat_messages(room_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      try { await db.execute('CREATE TABLE IF NOT EXISTS custom_exercises (id TEXT PRIMARY KEY, uid TEXT NOT NULL, data TEXT NOT NULL, synced INTEGER DEFAULT 0, updated_at INTEGER NOT NULL)'); } catch(_) {}
    }
  }

  // ── KV Store ──
  Future<void> setKV(String key, String value) async {
    final db = await database;
    await db.insert('kv_store', {'key': key, 'value': value, 'updated_at': _now()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<String?> getKV(String key) async {
    final db = await database;
    final rows = await db.query('kv_store', where: 'key = ?', whereArgs: [key]);
    return rows.isNotEmpty ? rows.first['value'] as String : null;
  }
  Future<void> deleteKV(String key) async {
    final db = await database;
    await db.delete('kv_store', where: 'key = ?', whereArgs: [key]);
  }

  // ── Users ──
  Future<void> upsertUser(String uid, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('users', {'uid': uid, 'data': jsonEncode(data), 'updated_at': _now()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final db = await database;
    final rows = await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['data'] as String) as Map<String, dynamic>;
  }
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    final rows = await db.query('users', orderBy: 'updated_at DESC');
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }
  Future<void> deleteUser(String uid) async {
    final db = await database;
    await db.delete('users', where: 'uid = ?', whereArgs: [uid]);
  }

  // ── Workout Logs ──
  Future<void> upsertWorkoutLog(String id, String uid, String date, String sessionName, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('workout_logs', {'id': id, 'uid': uid, 'date': date, 'session_name': sessionName, 'data': jsonEncode(data), 'synced': 0, 'updated_at': _now()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Map<String, dynamic>>> getWorkoutLogs(String uid, {String? date}) async {
    final db = await database;
    final where = date != null ? 'uid = ? AND date = ?' : 'uid = ?';
    final args = date != null ? [uid, date] : [uid];
    final rows = await db.query('workout_logs', where: where, whereArgs: args, orderBy: 'date DESC');
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }
  Future<Map<String, dynamic>?> getWorkoutLogByDate(String uid, String date) async {
    final db = await database;
    final rows = await db.query('workout_logs', where: 'uid = ? AND date = ?', whereArgs: [uid, date]);
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['data'] as String) as Map<String, dynamic>;
  }

  // ── Food Logs ──
  Future<void> upsertFoodLog(String id, String uid, String date, String mealType, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('food_logs', {'id': id, 'uid': uid, 'date': date, 'meal_type': mealType, 'data': jsonEncode(data), 'synced': 0, 'updated_at': _now()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Map<String, dynamic>>> getFoodLogs(String uid, {String? date}) async {
    final db = await database;
    final where = date != null ? 'uid = ? AND date = ?' : 'uid = ?';
    final args = date != null ? [uid, date] : [uid];
    final rows = await db.query('food_logs', where: where, whereArgs: args, orderBy: 'updated_at DESC');
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }
  Future<void> deleteFoodLog(String id) async {
    final db = await database;
    await db.delete('food_logs', where: 'id = ?', whereArgs: [id]);
  }

  // ── Attendance ──
  Future<void> upsertAttendance(String id, String uid, String date, String type) async {
    final db = await database;
    await db.insert('attendance', {'id': id, 'uid': uid, 'date': date, 'type': type, 'synced': 0, 'updated_at': _now()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Map<String, dynamic>>> getAttendance(String uid, {String? month}) async {
    final db = await database;
    final where = month != null ? 'uid = ? AND date LIKE ?' : 'uid = ?';
    final args = month != null ? [uid, '$month%'] : [uid];
    final rows = await db.query('attendance', where: where, whereArgs: args, orderBy: 'date ASC');
    return rows.map((r) => {'id': r['id'], 'uid': r['uid'], 'date': r['date'], 'type': r['type']}).toList();
  }
  Future<Map<String, dynamic>?> getAttendanceByDate(String uid, String date) async {
    final db = await database;
    final rows = await db.query('attendance', where: 'uid = ? AND date = ?', whereArgs: [uid, date]);
    if (rows.isEmpty) return null;
    return {'id': rows.first['id'], 'uid': rows.first['uid'], 'date': rows.first['date'], 'type': rows.first['type']};
  }

  // ── Sync Queue ──
  Future<void> addToSyncQueue(String action, String key, Map<String, dynamic> data, String uid) async {
    final db = await database;
    await db.insert('sync_queue', {'action': action, 'key_name': key, 'data': jsonEncode(data), 'uid': uid, 'created_at': _now()});
  }
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    final rows = await db.query('sync_queue', orderBy: 'created_at ASC');
    return rows.map((r) => {'id': r['id'], 'action': r['action'], 'key': r['key_name'], 'data': jsonDecode(r['data'] as String), 'uid': r['uid']}).toList();
  }
  Future<void> removeFromSyncQueue(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  // ── Chat Cache ──
  Future<void> cacheMessages(String roomId, List<Map<String, dynamic>> messages) async {
    final db = await database;
    final batch = db.batch();
    for (final msg in messages) {
      batch.insert('chat_messages', {'id': msg['id']?.toString() ?? msg['ts'].toString(), 'room_id': roomId, 'data': jsonEncode(msg), 'cached_at': _now()}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
  Future<List<Map<String, dynamic>>> getCachedMessages(String roomId, {int limit = 60}) async {
    final db = await database;
    final rows = await db.query('chat_messages', where: 'room_id = ?', whereArgs: [roomId], orderBy: 'cached_at DESC', limit: limit);
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList().reversed.toList();
  }
  Future<void> deleteMessage(String roomId, String msgId) async {
    final db = await database;
    await db.delete('chat_messages', where: 'room_id = ? AND id = ?', whereArgs: [roomId, msgId]);
  }

  // ── Custom Exercises ──
  Future<void> upsertCustomExercise(String id, String uid, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('custom_exercises', {'id': id, 'uid': uid, 'data': jsonEncode(data), 'synced': 0, 'updated_at': _now()}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Map<String, dynamic>>> getCustomExercises(String uid) async {
    final db = await database;
    final rows = await db.query('custom_exercises', where: 'uid = ?', whereArgs: [uid]);
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }

  // ── Utilities ──
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('workout_logs');
    await db.delete('food_logs');
    await db.delete('attendance');
    await db.delete('kv_store');
    await db.delete('chat_messages');
    await db.delete('custom_exercises');
  }

  int _now() => DateTime.now().millisecondsSinceEpoch;
}
