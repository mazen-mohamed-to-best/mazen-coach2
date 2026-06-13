import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/data/training_config.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/workout_log_model.dart';
import 'package:to_best/providers/app_providers.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});
  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<WorkoutLogModel> _history = [];
  bool _loading = true;
  int _selectedProgIdx = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final logs = await ref.read(workoutServiceProvider).getWorkoutHistory(user.uid);
    if (mounted) setState(() { _history = logs; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.workout),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [Tab(text: 'البرنامج'), Tab(text: 'السجل')],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildProgramTab(context, loc, user),
          _buildHistoryTab(context, loc),
        ],
      ),
    );
  }

  Widget _buildProgramTab(BuildContext context, AppLocalizations loc, dynamic user) {
    final programId = user?.programId ?? 'UL';
    final days = user?.programDays ?? 4;
    final sessions = TrainingConfig.getSessions(programId, days);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_special_outlined, color: Colors.white70, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TrainingConfig.programName(programId, AppLocalizations.of(context)!), style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('$days ${loc.daysPerWeek}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          // Warmup section
          _buildSection(loc.warmupProtocol, Icons.local_fire_department_rounded, AppColors.warning),
          const SizedBox(height: 8),
          ...TrainingConfig.warmup.asMap().entries.map((e) {
            final wu = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(wu.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600))),
                  Text(wu.reps, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 30 * e.key)).fadeIn();
          }),
          const SizedBox(height: 20),
          // Sessions
          _buildSection('جلسات الأسبوع', Icons.calendar_today_outlined, AppColors.primary),
          const SizedBox(height: 8),
          ...sessions.asMap().entries.map((e) {
            final session = e.value;
            final exCount = TrainingConfig.getExercises(session).length;
            return GestureDetector(
              onTap: () => context.go('/workout/session', extra: {'sessionName': session, 'programId': programId}),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700)),
                        Text('$exCount ${loc.workout.toLowerCase()}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
                      ],
                    )),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textGrey),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: 50 * e.key)).fadeIn().slideX(begin: 0.1);
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, AppLocalizations loc) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_rounded, size: 60, color: AppColors.textGrey),
            const SizedBox(height: 16),
            Text(loc.recentSessions, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.textGrey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (ctx, i) {
        final log = _history[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(log.sessionName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700))),
                  if (log.hasPR) const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textGrey),
                  const SizedBox(width: 4),
                  Text(log.date, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
                  const SizedBox(width: 14),
                  const Icon(Icons.fitness_center, size: 14, color: AppColors.textGrey),
                  const SizedBox(width: 4),
                  Text('${log.exercises.length} تمارين', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
                  if (log.durationMinutes != null) ...[
                    const SizedBox(width: 14),
                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text('${log.durationMinutes} دق', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
                  ],
                ],
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 30 * i)).fadeIn();
      },
    );
  }

  Widget _buildSection(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
