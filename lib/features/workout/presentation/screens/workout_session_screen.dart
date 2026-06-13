import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/data/training_config.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/workout_log_model.dart';
import 'package:to_best/providers/app_providers.dart';
import 'package:uuid/uuid.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final String sessionName;
  final String programId;
  const WorkoutSessionScreen({super.key, required this.sessionName, required this.programId});

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  final _uuid = const Uuid();
  late final List<ExerciseDef> _exercises;
  late final List<List<Map<String, TextEditingController>>> _setControllers;
  bool _warmupDone = false;
  bool _saving = false;
  int _restSeconds = 0;
  Timer? _restTimer;
  bool _restActive = false;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _exercises = TrainingConfig.getExercises(widget.sessionName);
    _setControllers = _exercises.map((ex) {
      return List.generate(ex.sets, (_) => {
        'weight': TextEditingController(),
        'reps': TextEditingController(text: _defaultReps(ex.reps)),
      });
    }).toList();
    _startTime = DateTime.now();
    final settings = ref.read(settingsProvider);
    if (settings.wakeLock) WakelockPlus.enable();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    WakelockPlus.disable();
    for (final s in _setControllers) {
      for (final ctrls in s) {
        ctrls['weight']!.dispose();
        ctrls['reps']!.dispose();
      }
    }
    super.dispose();
  }

  String _defaultReps(String repsRange) {
    final parts = repsRange.split('~');
    return parts.isNotEmpty ? parts.first : '8';
  }

  void _startRest(int minutes) {
    _restTimer?.cancel();
    setState(() { _restSeconds = minutes * 60; _restActive = true; });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSeconds <= 0) {
        t.cancel();
        if (mounted) setState(() { _restActive = false; });
      } else {
        if (mounted) setState(() => _restSeconds--);
      }
    });
  }

  void _stopRest() {
    _restTimer?.cancel();
    setState(() { _restActive = false; _restSeconds = 0; });
  }

  Future<void> _finishSession() async {
    setState(() => _saving = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final duration = DateTime.now().difference(_startTime).inMinutes;
      final exerciseLogs = <ExerciseLog>[];
      for (int i = 0; i < _exercises.length; i++) {
        final ex = _exercises[i];
        final sets = <WorkoutSetLog>[];
        for (int s = 0; s < _setControllers[i].length; s++) {
          final w = double.tryParse(_setControllers[i][s]['weight']!.text) ?? 0;
          final r = int.tryParse(_setControllers[i][s]['reps']!.text) ?? 0;
          if (w > 0 || r > 0) {
            sets.add(WorkoutSetLog(setNumber: s + 1, weight: w, reps: r, epley1RM: r > 1 ? w * (1 + r / 30) : w));
          }
        }
        if (sets.isNotEmpty) {
          exerciseLogs.add(ExerciseLog(name: ex.name, sets: sets));
        }
      }
      if (exerciseLogs.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لم تسجل أي بيانات'), backgroundColor: AppColors.warning));
        return;
      }
      final today = _dateStr(DateTime.now());
      final log = WorkoutLogModel(
        id: _uuid.v4(),
        uid: user.uid,
        date: today,
        sessionName: widget.sessionName,
        programId: widget.programId,
        exercises: exerciseLogs,
        durationMinutes: duration,
        timestamp: DateTime.now(),
      );
      await ref.read(workoutServiceProvider).saveWorkoutLog(user.uid, log);
      if (mounted) {
        _showCompletionDialog(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎉 أحسنت!', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('تم حفظ الجلسة بنجاح. كمّل هكذا!', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          ElevatedButton(onPressed: () { Navigator.pop(context); context.go('/workout'); }, child: const Text('موافق')),
        ],
      ),
    );
  }

  String _dateStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTimer(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionName),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _confirmExit(context)),
        actions: [
          StreamBuilder(stream: Stream.periodic(const Duration(seconds: 1)), builder: (_, __) {
            final elapsed = DateTime.now().difference(_startTime);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text('${elapsed.inHours > 0 ? "${elapsed.inHours}:" : ""}${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600))),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          if (_restActive) _buildRestBanner(loc),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warmup
                  _buildWarmupSection(loc),
                  const SizedBox(height: 20),
                  // Exercises
                  ..._exercises.asMap().entries.map((e) => _buildExerciseCard(context, e.key, e.value, settings, loc)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _finishSession,
        backgroundColor: AppColors.success,
        icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_rounded),
        label: Text(loc.finishSession),
      ),
    );
  }

  Widget _buildRestBanner(AppLocalizations loc) {
    return Container(
      color: AppColors.warning.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text('${loc.rest}: ${_formatTimer(_restSeconds)}', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          const Spacer(),
          TextButton(onPressed: _stopRest, child: Text(loc.stopRest, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildWarmupSection(AppLocalizations loc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(loc.warmupProtocol, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.warning)),
                const Spacer(),
                if (!_warmupDone)
                  TextButton(
                    onPressed: () => setState(() => _warmupDone = true),
                    child: Text(loc.warmupDone, style: const TextStyle(color: AppColors.success, fontFamily: 'Cairo', fontSize: 12)),
                  )
                else
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              ],
            ),
            if (!_warmupDone) ...[
              const SizedBox(height: 8),
              ...TrainingConfig.warmup.map((wu) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.warning),
                    const SizedBox(width: 10),
                    Text(wu.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                    const Spacer(),
                    Text(wu.reps, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, int idx, ExerciseDef ex, AppSettings settings, AppLocalizations loc) {
    final restParts = ex.rest.split('~');
    final restMin = int.tryParse(restParts.first) ?? 3;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (ex.primary) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: const Text('أساسي', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700))),
                if (ex.primary) const SizedBox(width: 8),
                Expanded(child: Text(ex.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8, runSpacing: 4,
              children: [
                _chip(Icons.fitness_center, ex.muscle, AppColors.primary),
                _chip(Icons.repeat, '${ex.sets} × ${ex.reps}', AppColors.info),
                _chip(Icons.timer_outlined, '${ex.rest} دق', AppColors.warning),
              ],
            ),
            if (ex.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(ex.note, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey, fontStyle: FontStyle.italic)),
            ],
            if (ex.alt1.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('بديل: ${ex.alt1}${ex.alt2.isNotEmpty ? " / ${ex.alt2}" : ""}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGrey)),
            ],
            const Divider(height: 20),
            // Sets
            Row(
              children: [
                const SizedBox(width: 36),
                Expanded(child: Text(loc.weight, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey))),
                const SizedBox(width: 8),
                Expanded(child: Text(loc.reps, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey))),
              ],
            ),
            const SizedBox(height: 6),
            ..._setControllers[idx].asMap().entries.map((se) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 36, child: Text('${se.key + 1}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    Expanded(child: _setField(se.value['weight']!, '0.0', suffixText: loc.kg)),
                    const SizedBox(width: 8),
                    Expanded(child: _setField(se.value['reps']!, ex.reps.split('~').first)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _startRest(restMin),
                  icon: const Icon(Icons.timer_outlined, size: 16),
                  label: Text('${loc.startRest} (${ex.rest})', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 8)),
                )),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 40 * idx)).fadeIn().slideY(begin: 0.1);
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color, fontWeight: FontWeight.w600))]),
    );
  }

  Widget _setField(TextEditingController ctrl, String hint, {String? suffixText}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffixText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إنهاء الجلسة؟', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل تريد الخروج بدون حفظ؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لا')),
          ElevatedButton(onPressed: () { Navigator.pop(context); context.go('/workout'); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('نعم، اخرج')),
        ],
      ),
    );
  }
}
