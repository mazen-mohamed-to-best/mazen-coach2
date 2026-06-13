import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/workout_log_model.dart';
import 'package:to_best/providers/app_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});
  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  List<WorkoutLogModel> _logs = [];
  Map<String, double> _prs = {};
  bool _loading = true;
  String? _selectedExercise;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final workoutSvc = ref.read(workoutServiceProvider);
    final [logs, prs] = await Future.wait([
      workoutSvc.getWorkoutHistory(user.uid),
      workoutSvc.getPersonalRecords(user.uid),
    ]);
    if (mounted) {
      setState(() {
        _logs = logs as List<WorkoutLogModel>;
        _prs = prs as Map<String, double>;
        _loading = false;
        if (_prs.isNotEmpty) _selectedExercise = _prs.keys.first;
      });
    }
  }

  List<FlSpot> _getChartData() {
    if (_selectedExercise == null) return [];
    final exerciseLogs = <DateTime, double>{};
    for (final log in _logs.reversed) {
      for (final ex in log.exercises) {
        if (ex.name == _selectedExercise) {
          final dateTime = DateTime.tryParse(log.date) ?? DateTime.now();
          exerciseLogs[dateTime] = ex.best1RM;
        }
      }
    }
    final sorted = exerciseLogs.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).take(20).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(loc.progress)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview stats
            _buildOverviewStats(loc),
            const SizedBox(height: 20),
            // Exercise progress chart
            if (_prs.isNotEmpty) ...[
              Text('منحنى التقدم', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(),
              const SizedBox(height: 10),
              _buildExercisePicker(),
              const SizedBox(height: 12),
              _buildChart(),
              const SizedBox(height: 20),
            ],
            // PRs list
            Text(loc.latestPRs, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 10),
            _buildPRsList(),
            const SizedBox(height: 20),
            // Recent sessions
            Text(loc.recentSessions, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 10),
            _buildRecentSessions(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStats(AppLocalizations loc) {
    final totalSessions = _logs.length;
    final totalVolume = _logs.fold(0.0, (s, l) => s + l.totalVolume);
    final totalPRs = _logs.where((l) => l.hasPR).length;
    return Row(
      children: [
        Expanded(child: _statCard(loc.totalSessions, '$totalSessions', AppColors.primary, Icons.bar_chart_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('أرقام قياسية', '$totalPRs', AppColors.gold, Icons.emoji_events_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('حجم كلي', '${(totalVolume / 1000).toStringAsFixed(1)}K', AppColors.info, Icons.fitness_center)),
      ],
    ).animate().fadeIn();
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textGrey), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildExercisePicker() {
    final exercises = _prs.keys.toList();
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exercises.length,
        itemBuilder: (_, i) {
          final ex = exercises[i];
          final isSelected = ex == _selectedExercise;
          return GestureDetector(
            onTap: () => setState(() => _selectedExercise = ex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(ex, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.primary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    final spots = _getChartData();
    if (spots.length < 2) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(16)),
        child: const Text('تحتاج على الأقل جلستين لعرض الرسم البياني', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textGrey), textAlign: TextAlign.center),
      );
    }
    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(16)),
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.textGrey.withOpacity(0.1), strokeWidth: 1)),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('${v.toInt()}kg', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textGrey)))),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.08)),
          dotData: FlDotData(getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: AppColors.primary, strokeWidth: 2, strokeColor: Colors.white)),
        )],
      )),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildPRsList() {
    if (_prs.isEmpty) return const Center(child: Text('لا توجد أرقام قياسية بعد', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)));
    final sorted = _prs.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: sorted.asMap().entries.map((e) {
        final i = e.key;
        final pr = e.value;
        final medals = [const Icon(Icons.emoji_events, color: AppColors.gold, size: 22), const Icon(Icons.emoji_events, color: AppColors.silver, size: 22), const Icon(Icons.emoji_events, color: AppColors.bronze, size: 22)];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
          child: Row(children: [
            i < 3 ? medals[i] : Text('${i + 1}.', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Expanded(child: Text(pr.key, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('${pr.value.toStringAsFixed(1)} kg', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ]),
        ).animate(delay: Duration(milliseconds: 30 * i)).fadeIn();
      }).toList(),
    );
  }

  Widget _buildRecentSessions() {
    final recent = _logs.take(5).toList();
    if (recent.isEmpty) return const Text('لا يوجد سجل تدريبي بعد', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey));
    return Column(
      children: recent.asMap().entries.map((e) {
        final log = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            if (log.hasPR) const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 18),
            if (!log.hasPR) const Icon(Icons.fitness_center, color: AppColors.primary, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(log.sessionName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
              Text(log.date, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGrey)),
            ])),
            Text('${log.exercises.length} تم', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
          ]),
        ).animate(delay: Duration(milliseconds: 30 * e.key)).fadeIn();
      }).toList(),
    );
  }
}
