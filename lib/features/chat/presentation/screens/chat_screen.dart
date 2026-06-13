import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/providers/app_providers.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    final rooms = [
      _RoomDef(id: AppConstants.chatGeneral, title: loc.chatGeneral, subtitle: loc.chatGeneralDesc, icon: Icons.group_rounded, color: AppColors.primary),
      _RoomDef(id: AppConstants.chatAnnouncements, title: loc.chatAnnouncements, subtitle: loc.chatAnnouncementsDesc, icon: Icons.campaign_rounded, color: AppColors.warning),
      _RoomDef(id: AppConstants.chatCoach, title: loc.chatCoach, subtitle: loc.chatCoachDesc, icon: Icons.fitness_center, color: AppColors.info),
      _RoomDef(id: AppConstants.chatSupport, title: loc.chatSupport, subtitle: loc.chatSupportDesc, icon: Icons.support_agent_rounded, color: const Color(0xFF9C27B0)),
      _RoomDef(id: AppConstants.chatAI, title: loc.chatAI, subtitle: loc.chatAIDesc, icon: Icons.smart_toy_rounded, color: const Color(0xFF00BCD4)),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(loc.chat)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (ctx, i) {
          final room = rooms[i];
          return GestureDetector(
            onTap: () => context.go('/chat/room', extra: {'roomId': room.id, 'title': room.title}),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: room.color.withOpacity(0.2), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: room.color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(room.icon, color: room.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(room.subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textGrey),
                ],
              ),
            ),
          ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn().slideX(begin: 0.1);
        },
      ),
    );
  }
}

class _RoomDef {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _RoomDef({required this.id, required this.title, required this.subtitle, required this.icon, required this.color});
}
