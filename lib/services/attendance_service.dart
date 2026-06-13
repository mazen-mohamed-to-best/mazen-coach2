import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/local_db/database_helper.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:uuid/uuid.dart';

class AttendanceRecord {
  final String id;
  final String uid;
  final String date;
  final String type; // gym, absent, rest

  const AttendanceRecord({required this.id, required this.uid, required this.date, required this.type});

  factory AttendanceRecord.fromMap(Map<String, dynamic> m) =>
      AttendanceRecord(id: m['id']?.toString() ?? '', uid: m['uid']?.toString() ?? '', date: m['date']?.toString() ?? '', type: m['type']?.toString() ?? AppConstants.attendanceRest);
}

class AttendanceService {
  final DatabaseHelper _db;
  final SyncService _sync;
  final _uuid = const Uuid();

  AttendanceService(this._db, this._sync);

  Future<List<AttendanceRecord>> getMonthAttendance(String uid, String month) async {
    final data = await _db.getAttendance(uid, month: month);
    return data.map(AttendanceRecord.fromMap).toList();
  }

  Future<AttendanceRecord?> getTodayAttendance(String uid) async {
    final today = _todayStr();
    final data = await _db.getAttendanceByDate(uid, today);
    if (data == null) return null;
    return AttendanceRecord.fromMap(data);
  }

  Future<bool> markAttendance(String uid, String date, String type) async {
    final id = '${uid}_$date';
    await _db.upsertAttendance(id, uid, date, type);
    return await _sync.queueOrPush(
        'SAVE_ATTENDANCE', 'att_$id', {'id': id, 'uid': uid, 'date': date, 'type': type}, uid);
  }

  Future<Map<String, dynamic>> getMonthStats(String uid, String month) async {
    final records = await getMonthAttendance(uid, month);
    int gym = 0, absent = 0, rest = 0;
    for (final r in records) {
      if (r.type == AppConstants.attendanceGym) gym++;
      else if (r.type == AppConstants.attendanceAbsent) absent++;
      else rest++;
    }
    final total = gym + absent;
    final commitment = total > 0 ? (gym / total * 100).round() : 0;
    return {'gym': gym, 'absent': absent, 'rest': rest, 'commitment': commitment};
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}
