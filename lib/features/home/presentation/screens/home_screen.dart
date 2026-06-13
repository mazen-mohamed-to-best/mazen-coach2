import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/data/training_config.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/user_model.dart';
import 'package:to_best/providers/app_providers.dart';
import 'package:to_best/features/home/presentation/widgets/home_stat_card.dart';
import 'package:to_best/features/home/presentation/widgets/today_session_card.dart';
import 'package:to_best/features/home/presentation/widgets/pr_list_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final db = ref.read(databaseHelperProvider);
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      final monthStr = '${today.year}-${today.month.toString().padLeft(2,'0')}';

      final [workoutLogs, foodLogs, attendance] = await Future.wait([
        db.getWorkoutLogs(user.uid),
        db.getFoodLogs(user.uid, date: todayStr),
        db.getAttendance(user.uid, month: monthStr),
      ]);

      final totalCalories = (foodLogs as List).fold<double>(0, (sum, f) => sum + ((f['calories'] as num?)?.toDouble() ?? 0));
      final gymCount = (attendance as List).where((a) => a['type'] == 'gym').length;
      final workoutCount = (workoutLogs as List).length;

      if (mounted) {
        setState(() {
          _stats = {
            'todayCalories': totalCalories.toInt(),
            'monthGym': gymCount,
            'totalWorkouts': workoutCount,
          };
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadStats,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, loc, user, isDark),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGreeting(loc, user, isDark).animate().fadeIn().slideY(begin: -0.2),
                  const SizedBox(height: 20),
                  _buildTodayCard(context, loc, user).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 20),
                  _buildStatsRow(loc).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 20),
                  _buildPRSection(loc, user).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 20),
                  _buildQuickActions(context, loc, user).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppLocalizations loc, UserModel? user, bool isDark) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
      title: Row(
        children: [
          Image.asset('assets/icons/icon_light.png', width: 28, height: 28, errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: Colors.white, size: 26)),
          const SizedBox(width: 10),
          const Text('TO Best', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white, fontSize: 20)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
        IconButton(
          icon: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text((user?.displayName ?? 'U').substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Cairo')),
          ),
          onPressed: () => context.go('/profile'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGreeting(AppLocalizations loc, UserModel? user, bool isDark) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) greeting = 'صباح الخير';
    else if (hour < 17) greeting = 'مساء الخير';
    else greeting = 'مساء النور';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: TextStyle(fontSize: 14, color: AppColors.textGrey, fontFamily: 'Cairo')),
        Text(user?.displayName ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Cairo', color: isDark ? Colors.white : AppColors.textDark)),
        if (user?.subscriptionInfo != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(user!.subscriptionInfo?['planName']?.toString() ?? 'مشترك', style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget _buildTodayCard(BuildContext context, AppLocalizations loc, UserModel? user) {
    final programId = user?.programId;
    final programDays = user?.programDays ?? 4;
    if (programId == null || programId.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.assignment_outlined, size: 48, color: AppColors.textGrey),
              const SizedBox(height: 12),
              const Text('لم يتم تعيين برنامج تدريبي بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.textGrey)),
              const SizedBox(height: 8),
              TextButton.icon(icon: const Icon(Icons.add_circle_outline), label: const Text('طلب برنامج'), onPressed: () => context.go('/subscription')),
            ],
          ),
        ),
      );
    }
    final sessions = TrainingConfig.getSessions(programId, programDays);
    return TodaySessionCard(sessions: sessions, programId: programId, onStartSession: (session) {
      context.go('/workout/session', extra: {'sessionName': session, 'programId': programId});
    });
  }

  Widget _buildStatsRow(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(child: HomeStatCard(label: 'سعرات اليوم', value: '${_stats['todayCalories'] ?? 0}', unit: 'kcal', icon: Icons.local_fire_department_outlined, color: AppColors.warning, loading: _loading)),
        const SizedBox(width: 10),
        Expanded(child: HomeStatCard(label: 'حضور الشهر', value: '${_stats['monthGym'] ?? 0}', unit: 'يوم', icon: Icons.calendar_today_outlined, color: AppColors.info, loading: _loading)),
        const SizedBox(width: 10),
        Expanded(child: HomeStatCard(label: 'إجمالي التمارين', value: '${_stats['totalWorkouts'] ?? 0}', unit: 'جلسة', icon: Icons.fitness_center_outlined, color: AppColors.primary, loading: _loading)),
      ],
    );
  }

  Widget _buildPRSection(AppLocalizations loc, UserModel? user) {
    if (user == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(loc.prs, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
            TextButton(onPressed: () => context.go('/progress'), child: Text(loc.seeAll, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12))),
          ],
        ),
        const SizedBox(height: 8),
        PRListWidget(uid: user.uid),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations loc, UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الوصول السريع', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _quickTile(context, Icons.restaurant_menu_outlined, loc.nutrition, '/nutrition', AppColors.warning),
            _quickTile(context, Icons.show_chart_outlined, loc.progress, '/progress', AppColors.info),
            _quickTile(context, Icons.calendar_month_outlined, loc.attendance, '/attendance', AppColors.success),
            _quickTile(context, Icons.chat_bubble_outline, loc.chat, '/chat', AppColors.primary),
            _quickTile(context, Icons.person_outline, loc.profile, '/profile', AppColors.textGrey),
            if (user?.isAdmin == true)
              _quickTile(context, Icons.admin_panel_settings_outlined, loc.admin, '/admin', AppColors.gold)
            else
              _quickTile(context, Icons.card_membership_outlined, 'الاشتراك', '/subscription', AppColors.accent),
          ],
        ),
      ],
    );
  }

  Widget _quickTile(BuildContext context, IconData icon, String label, String route, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textDark), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
