import 'package:to_best/l10n/app_localizations.dart';

class TrainingProgram {
  final String id;
  final String name;
  final String nameEn;
  final List<int> daysOptions;
  final Map<int, List<String>> sessions;
  final String description;
  final String descEn;

  const TrainingProgram({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.daysOptions,
    required this.sessions,
    this.description = '',
    this.descEn = '',
  });
}

class ExerciseDef {
  final String name;
  final bool primary;
  final String warmupSets;
  final int sets;
  final String reps;
  final String rest;
  final String muscle;
  final String alt1;
  final String alt2;
  final String note;

  const ExerciseDef({
    required this.name,
    required this.primary,
    required this.warmupSets,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.muscle,
    this.alt1 = '',
    this.alt2 = '',
    this.note = '',
  });
}

class WarmupExercise {
  final String name;
  final String reps;
  final bool hasWeight;
  final String note;
  const WarmupExercise({required this.name, required this.reps, required this.hasWeight, required this.note});
}

class TrainingConfig {
  static const List<WarmupExercise> warmup = [
    WarmupExercise(name: 'Pallof Press', reps: '10/side', hasWeight: true, note: 'ثبّت جسمك وحرك ذراعك فقط'),
    WarmupExercise(name: 'Pallof Rotation', reps: '10/side', hasWeight: true, note: 'حوضك ثابت'),
    WarmupExercise(name: 'External Rotation', reps: '10 reps', hasWeight: true, note: 'من الكتف فقط'),
    WarmupExercise(name: 'Scapula Push Plus', reps: '10 reps', hasWeight: true, note: 'من لوح الكتف — وزن خفيف'),
    WarmupExercise(name: 'Neck Extension', reps: '12 reps', hasWeight: true, note: 'وزن خفيف جداً — أسفل الرأس'),
    WarmupExercise(name: 'Neck Flexion', reps: '12 reps', hasWeight: true, note: 'وزن خفيف — الذقن للصدر'),
  ];

  static const Map<String, TrainingProgram> programs = {
    'UL': TrainingProgram(id: 'UL', name: 'Upper / Lower', nameEn: 'Upper / Lower', daysOptions: [4], description: 'تقسيم جسم علوي وسفلي', descEn: 'Upper/Lower body split', sessions: {4: ['Upper A', 'Lower A', 'Upper B', 'Lower B']}),
    'AP': TrainingProgram(id: 'AP', name: 'Anterior / Posterior', nameEn: 'Anterior / Posterior', daysOptions: [4], description: 'نظام أمامي-خلفي', descEn: 'Anterior-Posterior split', sessions: {4: ['Anterior A', 'Posterior A', 'Anterior B', 'Posterior B']}),
    'FB': TrainingProgram(id: 'FB', name: 'Full Body', nameEn: 'Full Body', daysOptions: [3], description: 'جسم كامل', descEn: 'Full Body training', sessions: {3: ['Full Body #1', 'Full Body #2', 'Full Body #3']}),
    'ARNOLD': TrainingProgram(id: 'ARNOLD', name: 'Arnold', nameEn: 'Arnold', daysOptions: [5], description: 'برنامج أرنولد الكلاسيكي', descEn: 'Classic Arnold program', sessions: {5: ['Chest & Back', 'Shoulders & Arms', 'Lower A', 'Upper', 'Lower B']}),
    'PPL': TrainingProgram(id: 'PPL', name: 'Push / Pull / Legs', nameEn: 'Push / Pull / Legs', daysOptions: [5], description: 'ضغط-شد-أرجل', descEn: 'Push-Pull-Legs', sessions: {5: ['PUSH', 'PULL', 'Lower A', 'Upper', 'Lower B']}),
    'CUSTOM': TrainingProgram(id: 'CUSTOM', name: 'برنامج مخصص', nameEn: 'Custom Program', daysOptions: [3, 4, 5, 6], description: 'أضف تمارينك وجلساتك بنفسك', descEn: 'Build your own program', sessions: {3: [], 4: [], 5: [], 6: []}),
  };

  static List<String> getSessions(String programId, int days) {
    final prog = programs[programId];
    if (prog == null) return [];
    return prog.sessions[days] ?? prog.sessions[prog.daysOptions.first] ?? [];
  }

  static String programName(String programId, AppLocalizations loc) {
    return programs[programId]?.name ?? programId;
  }

  // ── Full exercise database per session ─────────────────────────────────
  static const Map<String, List<ExerciseDef>> exercises = {

    // ── UL: Upper / Lower ──────────────────────────────────────────────
    'Upper A': [
      ExerciseDef(name: 'Smith High Incline Press', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '3~5', muscle: 'صدر عالي', alt1: 'DB High Incline Press', note: 'ضم ايدك لجوه عشان تحاكي اتجاه الياف الصدر العالي'),
      ExerciseDef(name: 'Machine Wide Grip Lat Pulldown', primary: true, warmupSets: '1~3', sets: 2, reps: '6~8', rest: '3~5', muscle: 'لاتس', alt1: 'Cable Wide Grip Lat', note: 'ركز في مسار كوعك وانك بتضم كتافك مش بتسحب من كتفك'),
      ExerciseDef(name: 'Chest Press Machine', primary: false, warmupSets: '1~2', sets: 2, reps: '6~10', rest: '3~5', muscle: 'صدر مستوي', alt1: 'DB Flat Press'),
      ExerciseDef(name: 'T Bar Row', primary: true, warmupSets: '1~2', sets: 2, reps: '5~7', rest: '3~5', muscle: 'ظهر علوي', alt1: 'Incline DB Row', alt2: 'Cable Row', note: 'افتح كيعانك لبره حاول تقرب من زاوية 90'),
      ExerciseDef(name: 'SA Tricep Pushdown', primary: false, warmupSets: '0', sets: 2, reps: '6~10', rest: '2~3', muscle: 'ترايسبس', alt1: 'Double Rope Pushdown'),
      ExerciseDef(name: 'DB Preacher Curl', primary: true, warmupSets: '0', sets: 2, reps: '6~10', rest: '2~3', muscle: 'بايسبس', alt1: 'Face Away Curl', alt2: 'DB Curls', note: 'بلاش مدى حركي زياده من الكتف ومتمرجحش جسمك'),
      ExerciseDef(name: 'Reverse Grip Curls', primary: false, warmupSets: '0', sets: 2, reps: '6~10', rest: '2~3', muscle: 'ساعد أمامي', alt1: 'DB Reverse Curl'),
    ],
    'Lower A': [
      ExerciseDef(name: 'Machine Lateral Raises', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '2~3', muscle: 'كتف جانبي', alt1: 'Cable Lateral Raises', alt2: 'DB Lateral Raises'),
      ExerciseDef(name: 'Leg Press Calf Raises', primary: false, warmupSets: '1~2', sets: 2, reps: '5~7', rest: '1~2', muscle: 'سمانة', alt1: 'Smith Calf Raises'),
      ExerciseDef(name: 'Hack Squat', primary: true, warmupSets: '1~3', sets: 1, reps: '5~8', rest: '3~5', muscle: 'رجل كوادز', alt1: 'Smith Squat', alt2: 'Leg Press', note: '120 درجه من ثني الركبه يكفي لاستهداف الكوادز'),
      ExerciseDef(name: 'SA Rear Delt Flies', primary: false, warmupSets: '0', sets: 1, reps: '6~10', rest: '2~3', muscle: 'كتف خلفي', alt1: 'Reverse Pec Dec'),
      ExerciseDef(name: 'Seated Leg Curl', primary: true, warmupSets: '1~2', sets: 1, reps: '8~12', rest: '2~3', muscle: 'رجل خلفيه', alt1: 'Lying Leg Curl'),
      ExerciseDef(name: 'Leg Extension', primary: true, warmupSets: '1~2', sets: 2, reps: '8~12', rest: '2~3', muscle: 'رجل أماميه'),
      ExerciseDef(name: 'Hip Adduction', primary: false, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '2~3', muscle: 'ضمه', alt1: 'Cable Hip Adduction'),
      ExerciseDef(name: 'Wrist Curls', primary: false, warmupSets: '0', sets: 3, reps: '6~10', rest: '1~2', muscle: 'ساعد خلفي'),
    ],
    'Upper B': [
      ExerciseDef(name: 'Chest Press Machine', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '3~5', muscle: 'صدر مستوي', alt1: 'DB Flat Press', alt2: 'Smith Flat Press'),
      ExerciseDef(name: 'T Bar Row', primary: true, warmupSets: '1~2', sets: 2, reps: '5~7', rest: '3~5', muscle: 'ظهر علوي', alt1: 'Incline DB Row', alt2: 'Cable Row'),
      ExerciseDef(name: 'Incline Chest Press Machine', primary: false, warmupSets: '1~2', sets: 1, reps: '6~10', rest: '3~5', muscle: 'صدر عالي', alt1: 'DB Incline Press'),
      ExerciseDef(name: 'SA Lat Row', primary: false, warmupSets: '0', sets: 1, reps: '6~10', rest: '2~3', muscle: 'لاتس', alt1: 'Cable SA Lat Row', alt2: 'DB SA Lat Row'),
      ExerciseDef(name: 'Face Away Curl', primary: true, warmupSets: '0', sets: 2, reps: '6~10', rest: '2~3', muscle: 'بايسبس', alt1: 'DB Preacher Curl', alt2: 'DB Curls'),
      ExerciseDef(name: 'Overhead Extension', primary: true, warmupSets: '0', sets: 2, reps: '6~10', rest: '2~3', muscle: 'ترايسبس', alt1: 'DB Skull Crusher'),
      ExerciseDef(name: 'Cable Shrugs', primary: false, warmupSets: '1', sets: 2, reps: '6~8', rest: '2~3', muscle: 'ترابيس', alt1: 'Smith Kelso Shrugs'),
    ],
    'Lower B': [
      ExerciseDef(name: 'Machine Lateral Raises', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '2~3', muscle: 'كتف جانبي', alt1: 'Cable Lateral Raises', alt2: 'DB Lateral Raises'),
      ExerciseDef(name: 'Smith Calf Raises', primary: false, warmupSets: '1~2', sets: 3, reps: '8~12', rest: '1~2', muscle: 'سمانة', alt1: 'Leg Press Calf Raises', note: 'حرك كامل مع توقف في الأعلى والأسفل'),
      ExerciseDef(name: 'Romanian Deadlift', primary: true, warmupSets: '1~3', sets: 2, reps: '6~8', rest: '3~5', muscle: 'هامسترينج / ظهر سفلي', alt1: 'Stiff Leg Deadlift', alt2: 'Cable RDL', note: 'حافظ على ظهرك مستقيم — الحركة من الحوض مش الظهر'),
      ExerciseDef(name: 'Lying Leg Curl', primary: true, warmupSets: '1~2', sets: 2, reps: '8~12', rest: '2~3', muscle: 'رجل خلفيه', alt1: 'Seated Leg Curl'),
      ExerciseDef(name: 'Leg Press', primary: true, warmupSets: '1~3', sets: 2, reps: '8~12', rest: '3~5', muscle: 'كوادز / جلوتس', alt1: 'Hack Squat', alt2: 'Smith Squat', note: 'ضع قدميك أعلى المنصة لتركيز أكثر على الجلوتس'),
      ExerciseDef(name: 'Hip Abduction', primary: false, warmupSets: '1', sets: 2, reps: '8~12', rest: '2~3', muscle: 'جانب الفخذ', alt1: 'Cable Hip Abduction'),
      ExerciseDef(name: 'SA Rear Delt Flies', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'كتف خلفي', alt1: 'Reverse Pec Dec'),
      ExerciseDef(name: 'Wrist Curls', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '1~2', muscle: 'ساعد خلفي'),
    ],

    // ── AP: Anterior / Posterior ──────────────────────────────────────
    'Anterior A': [
      ExerciseDef(name: 'Smith High Incline Press', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '3~5', muscle: 'صدر عالي', alt1: 'DB High Incline Press'),
      ExerciseDef(name: 'Hack Squat', primary: true, warmupSets: '1~3', sets: 2, reps: '5~8', rest: '3~5', muscle: 'كوادز', alt1: 'Leg Press', alt2: 'Smith Squat', note: '120 درجة ثني الركبة كافية'),
      ExerciseDef(name: 'Chest Press Machine', primary: false, warmupSets: '1~2', sets: 2, reps: '8~10', rest: '3~5', muscle: 'صدر مستوي', alt1: 'DB Flat Press'),
      ExerciseDef(name: 'Leg Extension', primary: true, warmupSets: '1~2', sets: 2, reps: '8~12', rest: '2~3', muscle: 'كوادز'),
      ExerciseDef(name: 'DB Preacher Curl', primary: true, warmupSets: '0', sets: 2, reps: '6~10', rest: '2~3', muscle: 'بايسبس', alt1: 'Face Away Curl'),
      ExerciseDef(name: 'Machine Lateral Raises', primary: false, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'كتف جانبي', alt1: 'Cable Lateral Raises'),
      ExerciseDef(name: 'Hip Adduction', primary: false, warmupSets: '1', sets: 2, reps: '8~12', rest: '2~3', muscle: 'ضمه', alt1: 'Cable Hip Adduction'),
      ExerciseDef(name: 'Leg Press Calf Raises', primary: false, warmupSets: '1', sets: 2, reps: '6~8', rest: '1~2', muscle: 'سمانة', alt1: 'Smith Calf Raises'),
    ],
    'Posterior A': [
      ExerciseDef(name: 'Machine Wide Grip Lat Pulldown', primary: true, warmupSets: '1~3', sets: 2, reps: '6~8', rest: '3~5', muscle: 'لاتس', alt1: 'Cable Wide Grip Lat'),
      ExerciseDef(name: 'Romanian Deadlift', primary: true, warmupSets: '1~3', sets: 2, reps: '6~8', rest: '3~5', muscle: 'هامسترينج', alt1: 'Stiff Leg Deadlift', note: 'الحركة من الحوض — ظهر مستقيم'),
      ExerciseDef(name: 'T Bar Row', primary: true, warmupSets: '1~2', sets: 2, reps: '5~7', rest: '3~5', muscle: 'ظهر علوي', alt1: 'Cable Row', alt2: 'DB Row'),
      ExerciseDef(name: 'Seated Leg Curl', primary: true, warmupSets: '1~2', sets: 2, reps: '8~12', rest: '2~3', muscle: 'هامسترينج', alt1: 'Lying Leg Curl'),
      ExerciseDef(name: 'SA Tricep Pushdown', primary: false, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'ترايسبس', alt1: 'Double Rope Pushdown'),
      ExerciseDef(name: 'SA Rear Delt Flies', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'كتف خلفي', alt1: 'Reverse Pec Dec'),
      ExerciseDef(name: 'Hip Abduction', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'جانب الفخذ'),
    ],
    'Anterior B': [
      ExerciseDef(name: 'Chest Press Machine', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '3~5', muscle: 'صدر مستوي', alt1: 'DB Flat Press', alt2: 'Smith Flat Press'),
      ExerciseDef(name: 'Leg Press', primary: true, warmupSets: '1~3', sets: 2, reps: '8~12', rest: '3~5', muscle: 'كوادز / جلوتس', alt1: 'Hack Squat'),
      ExerciseDef(name: 'Incline Chest Press Machine', primary: false, warmupSets: '1~2', sets: 1, reps: '8~12', rest: '3~5', muscle: 'صدر عالي', alt1: 'DB Incline Press'),
      ExerciseDef(name: 'Leg Extension', primary: true, warmupSets: '1~2', sets: 2, reps: '10~15', rest: '2~3', muscle: 'كوادز'),
      ExerciseDef(name: 'Face Away Curl', primary: true, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'بايسبس', alt1: 'DB Preacher Curl'),
      ExerciseDef(name: 'Machine Lateral Raises', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'كتف جانبي', alt1: 'Cable Lateral Raises'),
      ExerciseDef(name: 'Leg Press Calf Raises', primary: false, warmupSets: '1', sets: 2, reps: '8~12', rest: '1~2', muscle: 'سمانة', alt1: 'Smith Calf Raises'),
    ],
    'Posterior B': [
      ExerciseDef(name: 'SA Lat Row', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '3~5', muscle: 'لاتس', alt1: 'Cable Wide Grip Lat', alt2: 'Machine Lat Pulldown'),
      ExerciseDef(name: 'Stiff Leg Deadlift', primary: true, warmupSets: '1~3', sets: 2, reps: '6~8', rest: '3~5', muscle: 'هامسترينج', alt1: 'Romanian Deadlift', note: 'ركبة مقفولة أو نصف مثنية — تمتد للأسفل'),
      ExerciseDef(name: 'Incline DB Row', primary: true, warmupSets: '1~2', sets: 2, reps: '8~10', rest: '3~5', muscle: 'ظهر علوي', alt1: 'T Bar Row', alt2: 'Cable Row'),
      ExerciseDef(name: 'Lying Leg Curl', primary: true, warmupSets: '1~2', sets: 2, reps: '10~12', rest: '2~3', muscle: 'هامسترينج', alt1: 'Seated Leg Curl'),
      ExerciseDef(name: 'Overhead Extension', primary: false, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'ترايسبس', alt1: 'DB Skull Crusher'),
      ExerciseDef(name: 'SA Rear Delt Flies', primary: false, warmupSets: '0', sets: 2, reps: '12~15', rest: '2~3', muscle: 'كتف خلفي', alt1: 'Reverse Pec Dec'),
      ExerciseDef(name: 'Cable Shrugs', primary: false, warmupSets: '1', sets: 2, reps: '8~10', rest: '2~3', muscle: 'ترابيس', alt1: 'Smith Kelso Shrugs'),
    ],

    // ── FB: Full Body ────────────────────────────────────────────────
    'Full Body #1': [
      ExerciseDef(name: 'Smith High Incline Press', primary: true, warmupSets: '1~2', sets: 1, reps: '4~6', rest: '3~5', muscle: 'صدر عالي', alt1: 'DB High Incline Press'),
      ExerciseDef(name: 'T Bar Row', primary: true, warmupSets: '1~2', sets: 1, reps: '5~7', rest: '3~5', muscle: 'ظهر علوي', alt1: 'Incline DB Row', alt2: 'Cable Row'),
      ExerciseDef(name: 'Machine Lateral Raises', primary: false, warmupSets: '0', sets: 1, reps: '6~8', rest: '2~3', muscle: 'كتف جانبي', alt1: 'Cable Lateral Raises'),
      ExerciseDef(name: 'Machine Wide Grip Lat Pulldown', primary: true, warmupSets: '1~3', sets: 1, reps: '6~8', rest: '3~5', muscle: 'لاتس', alt1: 'Cable Wide Grip Lat'),
      ExerciseDef(name: 'DB Preacher Curl', primary: true, warmupSets: '0', sets: 1, reps: '6~10', rest: '2~3', muscle: 'بايسبس', alt1: 'Face Away Curl'),
      ExerciseDef(name: 'SA Tricep Pushdown', primary: true, warmupSets: '0', sets: 1, reps: '6~10', rest: '2~3', muscle: 'ترايسبس', alt1: 'Double Rope Pushdown'),
      ExerciseDef(name: 'Seated Leg Curl', primary: true, warmupSets: '1~2', sets: 1, reps: '8~12', rest: '2~3', muscle: 'رجل خلفيه', alt1: 'Lying Leg Curl'),
      ExerciseDef(name: 'Leg Extension', primary: true, warmupSets: '1~2', sets: 1, reps: '8~12', rest: '2~3', muscle: 'رجل أماميه'),
      ExerciseDef(name: 'Leg Press Calf Raises', primary: false, warmupSets: '1~2', sets: 2, reps: '5~7', rest: '1~2', muscle: 'سمانة', alt1: 'Smith Calf Raises'),
    ],
    'Full Body #2': [
      ExerciseDef(name: 'Chest Press Machine', primary: true, warmupSets: '1~2', sets: 1, reps: '5~7', rest: '3~5', muscle: 'صدر مستوي', alt1: 'DB Flat Press', alt2: 'Smith Flat Press'),
      ExerciseDef(name: 'Hack Squat', primary: true, warmupSets: '1~3', sets: 1, reps: '6~8', rest: '3~5', muscle: 'كوادز', alt1: 'Leg Press', alt2: 'Smith Squat'),
      ExerciseDef(name: 'SA Lat Row', primary: true, warmupSets: '1~2', sets: 1, reps: '6~8', rest: '3~5', muscle: 'لاتس', alt1: 'Cable Row', alt2: 'DB SA Lat Row'),
      ExerciseDef(name: 'Romanian Deadlift', primary: true, warmupSets: '1~2', sets: 1, reps: '6~8', rest: '3~5', muscle: 'هامسترينج', alt1: 'Stiff Leg Deadlift'),
      ExerciseDef(name: 'Machine Lateral Raises', primary: false, warmupSets: '0', sets: 1, reps: '8~12', rest: '2~3', muscle: 'كتف جانبي', alt1: 'Cable Lateral Raises'),
      ExerciseDef(name: 'Face Away Curl', primary: true, warmupSets: '0', sets: 1, reps: '8~10', rest: '2~3', muscle: 'بايسبس', alt1: 'DB Preacher Curl'),
      ExerciseDef(name: 'Overhead Extension', primary: true, warmupSets: '0', sets: 1, reps: '8~10', rest: '2~3', muscle: 'ترايسبس', alt1: 'DB Skull Crusher'),
      ExerciseDef(name: 'Smith Calf Raises', primary: false, warmupSets: '1', sets: 2, reps: '6~8', rest: '1~2', muscle: 'سمانة', alt1: 'Leg Press Calf Raises'),
    ],
    'Full Body #3': [
      ExerciseDef(name: 'Incline Chest Press Machine', primary: true, warmupSets: '1~2', sets: 1, reps: '6~8', rest: '3~5', muscle: 'صدر عالي', alt1: 'DB Incline Press'),
      ExerciseDef(name: 'Leg Press', primary: true, warmupSets: '1~3', sets: 1, reps: '8~12', rest: '3~5', muscle: 'كوادز / جلوتس', alt1: 'Hack Squat'),
      ExerciseDef(name: 'Machine Wide Grip Lat Pulldown', primary: true, warmupSets: '1~2', sets: 1, reps: '6~8', rest: '3~5', muscle: 'لاتس', alt1: 'Cable Wide Grip Lat'),
      ExerciseDef(name: 'Lying Leg Curl', primary: true, warmupSets: '1~2', sets: 1, reps: '8~12', rest: '2~3', muscle: 'هامسترينج', alt1: 'Seated Leg Curl'),
      ExerciseDef(name: 'Incline DB Row', primary: true, warmupSets: '1~2', sets: 1, reps: '6~8', rest: '3~5', muscle: 'ظهر علوي', alt1: 'T Bar Row'),
      ExerciseDef(name: 'SA Rear Delt Flies', primary: false, warmupSets: '0', sets: 1, reps: '10~15', rest: '2~3', muscle: 'كتف خلفي', alt1: 'Reverse Pec Dec'),
      ExerciseDef(name: 'DB Preacher Curl', primary: false, warmupSets: '0', sets: 1, reps: '8~12', rest: '2~3', muscle: 'بايسبس', alt1: 'Face Away Curl'),
      ExerciseDef(name: 'SA Tricep Pushdown', primary: false, warmupSets: '0', sets: 1, reps: '8~12', rest: '2~3', muscle: 'ترايسبس', alt1: 'Double Rope Pushdown'),
      ExerciseDef(name: 'Leg Press Calf Raises', primary: false, warmupSets: '1', sets: 2, reps: '6~8', rest: '1~2', muscle: 'سمانة'),
    ],

    // ── Arnold Classic ───────────────────────────────────────────────
    'Chest & Back': [
      ExerciseDef(name: 'Smith High Incline Press', primary: true, warmupSets: '1~2', sets: 3, reps: '6~8', rest: '3~5', muscle: 'صدر عالي', alt1: 'DB Incline Press', note: 'الطريقة الكلاسيكية — ضغط ثم عقلة'),
      ExerciseDef(name: 'Machine Wide Grip Lat Pulldown', primary: true, warmupSets: '1~3', sets: 3, reps: '6~8', rest: '3~5', muscle: 'لاتس', alt1: 'Wide Pull-ups', note: 'سحب عريض — ضم الكتف للحوض'),
      ExerciseDef(name: 'Chest Press Machine', primary: false, warmupSets: '1', sets: 2, reps: '8~10', rest: '3~5', muscle: 'صدر مستوي', alt1: 'DB Flat Press'),
      ExerciseDef(name: 'T Bar Row', primary: true, warmupSets: '1~2', sets: 3, reps: '5~7', rest: '3~5', muscle: 'ظهر علوي', alt1: 'Barbell Row', note: 'أرنولد كان يفضل حركات الشريط'),
      ExerciseDef(name: 'Cable Crossover', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'صدر وسط', alt1: 'Pec Dec Flies'),
      ExerciseDef(name: 'SA Lat Row', primary: false, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'لاتس', alt1: 'Cable Row'),
      ExerciseDef(name: 'Cable Shrugs', primary: false, warmupSets: '1', sets: 2, reps: '6~8', rest: '2~3', muscle: 'ترابيس', alt1: 'Smith Kelso Shrugs'),
    ],
    'Shoulders & Arms': [
      ExerciseDef(name: 'Smith OHP', primary: true, warmupSets: '1~3', sets: 3, reps: '6~8', rest: '3~5', muscle: 'كتف أمامي', alt1: 'DB OHP', alt2: 'Machine OHP', note: 'الضغط العلوي الأساسي في يوم الكتف والأذرع'),
      ExerciseDef(name: 'Machine Lateral Raises', primary: true, warmupSets: '1~2', sets: 3, reps: '8~12', rest: '2~3', muscle: 'كتف جانبي', alt1: 'Cable Lateral Raises', alt2: 'DB Lateral Raises'),
      ExerciseDef(name: 'SA Rear Delt Flies', primary: true, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'كتف خلفي', alt1: 'Reverse Pec Dec'),
      ExerciseDef(name: 'DB Preacher Curl', primary: true, warmupSets: '0', sets: 3, reps: '6~10', rest: '2~3', muscle: 'بايسبس', alt1: 'Barbell Curl', note: 'بايسبس ضخمة = علامة أرنولد'),
      ExerciseDef(name: 'Face Away Curl', primary: false, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'بايسبس', alt1: 'Hammer Curl'),
      ExerciseDef(name: 'SA Tricep Pushdown', primary: true, warmupSets: '0', sets: 3, reps: '8~12', rest: '2~3', muscle: 'ترايسبس', alt1: 'Overhead Extension'),
      ExerciseDef(name: 'Overhead Extension', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'ترايسبس رأس طويل', alt1: 'DB Skull Crusher'),
      ExerciseDef(name: 'Reverse Grip Curls', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '1~2', muscle: 'ساعد أمامي', alt1: 'Hammer Curl'),
    ],

    // ── PPL: Push / Pull / Legs ──────────────────────────────────────
    'PUSH': [
      ExerciseDef(name: 'Smith High Incline Press', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '3~5', muscle: 'صدر عالي', alt1: 'DB High Incline Press'),
      ExerciseDef(name: 'Chest Press Machine', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '3~5', muscle: 'صدر مستوي', alt1: 'DB Flat Press'),
      ExerciseDef(name: 'Smith OHP', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '3~5', muscle: 'كتف أمامي', alt1: 'DB OHP', alt2: 'Machine OHP'),
      ExerciseDef(name: 'Machine Lateral Raises', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'كتف جانبي', alt1: 'Cable Lateral Raises'),
      ExerciseDef(name: 'SA Tricep Pushdown', primary: true, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'ترايسبس', alt1: 'Double Rope Pushdown'),
      ExerciseDef(name: 'Overhead Extension', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'ترايسبس رأس طويل', alt1: 'DB Skull Crusher'),
      ExerciseDef(name: 'Incline Chest Press Machine', primary: false, warmupSets: '0', sets: 1, reps: '8~12', rest: '2~3', muscle: 'صدر عالي', alt1: 'Cable Crossover'),
    ],
    'PULL': [
      ExerciseDef(name: 'Machine Wide Grip Lat Pulldown', primary: true, warmupSets: '1~3', sets: 2, reps: '6~8', rest: '3~5', muscle: 'لاتس', alt1: 'Cable Wide Grip Lat', alt2: 'Wide Pull-ups'),
      ExerciseDef(name: 'T Bar Row', primary: true, warmupSets: '1~2', sets: 2, reps: '5~7', rest: '3~5', muscle: 'ظهر علوي', alt1: 'Incline DB Row', alt2: 'Cable Row'),
      ExerciseDef(name: 'SA Lat Row', primary: false, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'لاتس', alt1: 'Cable SA Lat Row'),
      ExerciseDef(name: 'SA Rear Delt Flies', primary: false, warmupSets: '0', sets: 2, reps: '12~15', rest: '2~3', muscle: 'كتف خلفي', alt1: 'Reverse Pec Dec'),
      ExerciseDef(name: 'DB Preacher Curl', primary: true, warmupSets: '0', sets: 2, reps: '6~10', rest: '2~3', muscle: 'بايسبس', alt1: 'Face Away Curl'),
      ExerciseDef(name: 'Face Away Curl', primary: false, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'بايسبس', alt1: 'Hammer Curl'),
      ExerciseDef(name: 'Cable Shrugs', primary: false, warmupSets: '1', sets: 2, reps: '6~8', rest: '2~3', muscle: 'ترابيس', alt1: 'Smith Kelso Shrugs'),
      ExerciseDef(name: 'Reverse Grip Curls', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '1~2', muscle: 'ساعد أمامي', alt1: 'DB Reverse Curl'),
    ],

    // ── Shared Upper/Lower sessions (Arnold & PPL) ───────────────────
    'Upper': [
      ExerciseDef(name: 'Chest Press Machine', primary: true, warmupSets: '1~2', sets: 2, reps: '6~8', rest: '3~5', muscle: 'صدر مستوي', alt1: 'DB Flat Press', alt2: 'Smith Flat Press'),
      ExerciseDef(name: 'Machine Wide Grip Lat Pulldown', primary: true, warmupSets: '1~3', sets: 2, reps: '6~8', rest: '3~5', muscle: 'لاتس', alt1: 'Cable Wide Grip Lat'),
      ExerciseDef(name: 'Smith High Incline Press', primary: false, warmupSets: '1', sets: 1, reps: '8~10', rest: '3~5', muscle: 'صدر عالي', alt1: 'DB Incline Press'),
      ExerciseDef(name: 'Incline DB Row', primary: false, warmupSets: '0', sets: 1, reps: '8~10', rest: '2~3', muscle: 'ظهر علوي', alt1: 'T Bar Row'),
      ExerciseDef(name: 'Machine Lateral Raises', primary: false, warmupSets: '0', sets: 2, reps: '10~15', rest: '2~3', muscle: 'كتف جانبي', alt1: 'Cable Lateral Raises'),
      ExerciseDef(name: 'Face Away Curl', primary: true, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'بايسبس', alt1: 'DB Preacher Curl'),
      ExerciseDef(name: 'SA Tricep Pushdown', primary: true, warmupSets: '0', sets: 2, reps: '8~12', rest: '2~3', muscle: 'ترايسبس', alt1: 'Overhead Extension'),
      ExerciseDef(name: 'Cable Shrugs', primary: false, warmupSets: '0', sets: 2, reps: '8~10', rest: '2~3', muscle: 'ترابيس', alt1: 'Smith Kelso Shrugs'),
    ],
  };

  static List<ExerciseDef> getExercises(String sessionName) {
    return exercises[sessionName] ?? [];
  }
}
