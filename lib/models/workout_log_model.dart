class WorkoutSetLog {
  final int setNumber;
  final double weight;
  final int reps;
  final double? rpe;
  final double? epley1RM;
  final String? evaluation;

  const WorkoutSetLog({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.rpe,
    this.epley1RM,
    this.evaluation,
  });

  factory WorkoutSetLog.fromMap(Map<String, dynamic> map) {
    return WorkoutSetLog(
      setNumber: (map['set'] as num?)?.toInt() ?? 0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      reps: (map['reps'] as num?)?.toInt() ?? 0,
      rpe: (map['rpe'] as num?)?.toDouble(),
      epley1RM: (map['epley'] as num?)?.toDouble(),
      evaluation: map['evaluation']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'set': setNumber,
        'weight': weight,
        'reps': reps,
        if (rpe != null) 'rpe': rpe,
        if (epley1RM != null) 'epley': epley1RM,
        if (evaluation != null) 'evaluation': evaluation,
      };

  double get volume => weight * reps;
  double get calculatedEpley => reps > 1 ? weight * (1 + reps / 30) : weight;
}

class ExerciseLog {
  final String name;
  final List<WorkoutSetLog> sets;
  final String? note;
  final bool isPR;

  const ExerciseLog({
    required this.name,
    required this.sets,
    this.note,
    this.isPR = false,
  });

  factory ExerciseLog.fromMap(Map<String, dynamic> map) {
    final setsList = (map['sets'] as List? ?? [])
        .map((s) => WorkoutSetLog.fromMap(s as Map<String, dynamic>))
        .toList();
    return ExerciseLog(
      name: map['name']?.toString() ?? '',
      sets: setsList,
      note: map['note']?.toString(),
      isPR: map['isPR'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'sets': sets.map((s) => s.toMap()).toList(),
        if (note != null) 'note': note,
        'isPR': isPR,
      };

  double get totalVolume => sets.fold(0, (sum, s) => sum + s.volume);
  double get bestWeight => sets.isEmpty
      ? 0
      : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  double get best1RM => sets.isEmpty
      ? 0
      : sets.map((s) => s.calculatedEpley).reduce((a, b) => a > b ? a : b);
}

class WorkoutLogModel {
  final String id;
  final String uid;
  final String date;
  final String sessionName;
  final String programId;
  final List<ExerciseLog> exercises;
  final int? durationMinutes;
  final String? note;
  final DateTime timestamp;

  const WorkoutLogModel({
    required this.id,
    required this.uid,
    required this.date,
    required this.sessionName,
    required this.programId,
    required this.exercises,
    this.durationMinutes,
    this.note,
    required this.timestamp,
  });

  factory WorkoutLogModel.fromMap(Map<String, dynamic> map) {
    final exercisesList = (map['exercises'] as List? ?? [])
        .map((e) => ExerciseLog.fromMap(e as Map<String, dynamic>))
        .toList();
    return WorkoutLogModel(
      id: map['id']?.toString() ?? '',
      uid: map['uid']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      sessionName: map['sessionName']?.toString() ?? '',
      programId: map['programId']?.toString() ?? '',
      exercises: exercisesList,
      durationMinutes: (map['duration'] as num?)?.toInt(),
      note: map['note']?.toString(),
      timestamp: map['ts'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['ts'] as num).toInt())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'date': date,
        'sessionName': sessionName,
        'programId': programId,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        if (durationMinutes != null) 'duration': durationMinutes,
        if (note != null) 'note': note,
        'ts': timestamp.millisecondsSinceEpoch,
      };

  double get totalVolume =>
      exercises.fold(0, (sum, e) => sum + e.totalVolume);
  bool get hasPR => exercises.any((e) => e.isPR);
}
