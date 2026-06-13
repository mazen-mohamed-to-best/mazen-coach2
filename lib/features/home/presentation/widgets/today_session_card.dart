import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/data/training_config.dart';

class TodaySessionCard extends StatefulWidget {
  final List<String> sessions;
  final String programId;
  final void Function(String session) onStartSession;

  const TodaySessionCard({
    super.key,
    required this.sessions,
    required this.programId,
    required this.onStartSession,
  });

  @override
  State<TodaySessionCard> createState() => _TodaySessionCardState();
}

class _TodaySessionCardState extends State<TodaySessionCard> {
  String? _selectedSession;

  @override
  void initState() {
    super.initState();
    if (widget.sessions.isNotEmpty) {
      final dayIndex = DateTime.now().weekday - 1;
      _selectedSession = widget.sessions[dayIndex % widget.sessions.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sessions.isEmpty) return const SizedBox();
    final exercises = TrainingConfig.getExercises(_selectedSession ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.heroGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text("جلسة اليوم", style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo')),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(widget.programId, style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Session selector
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.sessions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = widget.sessions[i];
                final selected = s == _selectedSession;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSession = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(s, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600, color: selected ? AppColors.primaryDark : Colors.white)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Text(_selectedSession ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Cairo')).animate().fadeIn(),
          const SizedBox(height: 4),
          Text('${exercises.length} تمرين • ${exercises.where((e) => e.primary).length} أساسي', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo')),
          const SizedBox(height: 16),
          // Exercise preview chips
          if (exercises.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: exercises.take(4).map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(e.name, style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Cairo')),
              )).toList(),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedSession != null ? () => widget.onStartSession(_selectedSession!) : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('ابدأ الجلسة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
