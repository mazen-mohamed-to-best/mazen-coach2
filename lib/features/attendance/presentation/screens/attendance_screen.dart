import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/providers/app_providers.dart';
import 'package:to_best/services/attendance_service.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});
  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _currentMonth = DateTime.now();
  List<AttendanceRecord> _records = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get _monthKey => '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final attSvc = ref.read(attendanceServiceProvider);
    final [records, stats] = await Future.wait([
      attSvc.getMonthAttendance(user.uid, _monthKey),
      attSvc.getMonthStats(user.uid, _monthKey),
    ]);
    if (mounted) {
      setState(() {
        _records = records as List<AttendanceRecord>;
        _stats = stats as Map<String, dynamic>;
        _loading = false;
      });
    }
  }

  String? _getAttendanceForDay(int day) {
    final dateStr = '$_monthKey-${day.toString().padLeft(2, '0')}';
    final record = _records.where((r) => r.date == dateStr).firstOrNull;
    return record?.type;
  }

  Future<void> _markDay(int day) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final dateStr = '$_monthKey-${day.toString().padLeft(2, '0')}';
    final current = _getAttendanceForDay(day);
    String? next;
    if (current == null) next = AppConstants.attendanceGym;
    else if (current == AppConstants.attendanceGym) next = AppConstants.attendanceAbsent;
    else if (current == AppConstants.attendanceAbsent) next = AppConstants.attendanceRest;
    else next = null;
    if (next != null) {
      await ref.read(attendanceServiceProvider).markAttendance(user.uid, dateStr, next);
    } else {
      // Unmark — just mark as rest (no delete endpoint)
      await ref.read(attendanceServiceProvider).markAttendance(user.uid, dateStr, AppConstants.attendanceRest);
    }
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;

    return Scaffold(
      appBar: AppBar(title: Text(loc.attendance)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month nav
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () { setState(() { _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1); _loading = true; }); _loadData(); }),
                Text(_monthName(_currentMonth.month) + ' ${_currentMonth.year}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: () { setState(() { _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1); _loading = true; }); _loadData(); }),
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                Expanded(child: _statCard(loc.gymDays, '${_stats['gym'] ?? 0}', AppColors.success, Icons.fitness_center)),
                const SizedBox(width: 8),
                Expanded(child: _statCard(loc.absentDays, '${_stats['absent'] ?? 0}', AppColors.error, Icons.cancel_outlined)),
                const SizedBox(width: 8),
                Expanded(child: _statCard(loc.restDays, '${_stats['rest'] ?? 0}', AppColors.info, Icons.hotel_rounded)),
                const SizedBox(width: 8),
                Expanded(child: _statCard(loc.commitment, '${_stats['commitment'] ?? 0}%', AppColors.warning, Icons.star_rounded)),
              ],
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            // Weekday headers
            _buildWeekdayHeader(loc),
            const SizedBox(height: 8),
            // Calendar grid
            _buildCalendar(daysInMonth, firstDay),
            const SizedBox(height: 16),
            // Legend
            _buildLegend(loc),
            const SizedBox(height: 12),
            Text(loc.tapToMark, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader(AppLocalizations loc) {
    final days = [loc.monS, loc.tueS, loc.wedS, loc.thuS, loc.friS, loc.satS, loc.sunS];
    return Row(
      children: days.map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey))))).toList(),
    );
  }

  Widget _buildCalendar(int daysInMonth, int firstDay) {
    // firstDay: 1=Mon..7=Sun → offset 0..6
    final offset = firstDay - 1;
    final total = offset + daysInMonth;
    final rows = (total / 7).ceil();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
      itemCount: rows * 7,
      itemBuilder: (_, i) {
        final dayIdx = i - offset + 1;
        if (dayIdx < 1 || dayIdx > daysInMonth) return const SizedBox();
        final type = _getAttendanceForDay(dayIdx);
        final isToday = _currentMonth.year == DateTime.now().year && _currentMonth.month == DateTime.now().month && dayIdx == DateTime.now().day;
        return GestureDetector(
          onTap: () => _markDay(dayIdx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _dayColor(type),
              shape: BoxShape.circle,
              border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Center(child: Text('$dayIdx', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: isToday ? FontWeight.w800 : FontWeight.w500, color: type != null ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color))),
          ),
        );
      },
    ).animate().fadeIn(delay: 150.ms);
  }

  Color _dayColor(String? type) {
    switch (type) {
      case AppConstants.attendanceGym: return AppColors.success;
      case AppConstants.attendanceAbsent: return AppColors.error;
      case AppConstants.attendanceRest: return AppColors.info;
      default: return Colors.transparent;
    }
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildLegend(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(AppColors.success, loc.gym),
        const SizedBox(width: 16),
        _legendItem(AppColors.error, loc.absent),
        const SizedBox(width: 16),
        _legendItem(AppColors.info, loc.restMark),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGrey)),
    ]);
  }

  String _monthName(int m) {
    const names = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return names[m];
  }
}
