import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/providers/app_providers.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const List<_NavItem> _items = [
    _NavItem(route: '/', icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    _NavItem(route: '/workout', icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center),
    _NavItem(route: '/nutrition', icon: Icons.restaurant_menu_outlined, activeIcon: Icons.restaurant_menu),
    _NavItem(route: '/attendance', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month),
    _NavItem(route: '/progress', icon: Icons.show_chart_outlined, activeIcon: Icons.show_chart),
    _NavItem(route: '/chat', icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final location = GoRouterState.of(context).matchedLocation;

    final labels = [loc.home, loc.workout, loc.nutrition, loc.attendance, loc.progress, loc.chat];

    int selectedIndex = 0;
    for (int i = 0; i < _items.length; i++) {
      if (location.startsWith(_items[i].route) && _items[i].route != '/' || location == _items[i].route) {
        selectedIndex = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) => context.go(_items[i].route),
          items: List.generate(_items.length, (i) => BottomNavigationBarItem(
            icon: Icon(_items[i].icon),
            activeIcon: Icon(_items[i].activeIcon),
            label: labels[i],
          )),
        ),
      ),
      drawer: _buildDrawer(context, ref, loc, user),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, AppLocalizations loc, dynamic user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      child: Container(
        color: isDark ? AppColors.darkSurface : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Cairo'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user?.displayName ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                  Text(user?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo')),
                ],
              ),
            ),
            _drawerTile(context, Icons.person_outline, loc.profile, '/profile'),
            _drawerTile(context, Icons.card_membership_outlined, 'الاشتراك', '/subscription'),
            _drawerTile(context, Icons.settings_outlined, loc.settings, '/settings'),
            if (user?.isAdmin == true) ...[
              const Divider(),
              _drawerTile(context, Icons.admin_panel_settings_outlined, loc.admin, '/admin', color: AppColors.warning),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(loc.logout, style: const TextStyle(color: AppColors.error, fontFamily: 'Cairo')),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authServiceProvider).logout();
                ref.read(currentUserProvider.notifier).state = null;
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerTile(BuildContext context, IconData icon, String label, String route, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(label, style: TextStyle(fontFamily: 'Cairo', color: color)),
      onTap: () { Navigator.pop(context); context.go(route); },
    );
  }
}

class _NavItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem({required this.route, required this.icon, required this.activeIcon});
}
