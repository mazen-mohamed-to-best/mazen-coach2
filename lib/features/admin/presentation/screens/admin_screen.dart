import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/user_model.dart';
import 'package:to_best/providers/app_providers.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});
  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<UserModel> _users = [];
  List<Map<String, dynamic>> _subRequests = [];
  List<Map<String, dynamic>> _promos = [];
  List<Map<String, dynamic>> _banned = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final adminSvc = ref.read(adminServiceProvider);
      final [users, subs, promos, banned] = await Future.wait([
        adminSvc.fetchAllUsers(),
        adminSvc.getSubscriptionRequests(),
        adminSvc.listPromos(),
        adminSvc.listBanned(),
      ]);
      if (mounted) {
        setState(() {
          _users = users as List<UserModel>;
          _subRequests = (subs as List).map((s) => s.toMap()).toList();
          _promos = promos as List<Map<String, dynamic>>;
          _banned = banned as List<Map<String, dynamic>>;
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
    final currentUser = ref.watch(currentUserProvider);
    if (!(currentUser?.isAdmin ?? false)) {
      return Scaffold(appBar: AppBar(title: Text(loc.admin)), body: const Center(child: Text('لا تملك صلاحية الوصول', style: TextStyle(fontFamily: 'Cairo'))));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.admin),
        actions: [IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _loadData)],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: [
            Tab(text: '${loc.users} (${_users.length})'),
            Tab(text: 'الاشتراكات (${_subRequests.length})'),
            Tab(text: 'البروموكود'),
            Tab(text: 'الحظر'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildUsersTab(),
                _buildSubsTab(),
                _buildPromosTab(context),
                _buildBanTab(context),
              ],
            ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _users.length,
      itemBuilder: (ctx, i) {
        final user = _users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _roleColor(user.role).withOpacity(0.15),
              child: Text(user.displayName.isNotEmpty ? user.displayName[0] : '?', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: _roleColor(user.role))),
            ),
            title: Text(user.displayName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('${user.email}\n${user.role} • ${user.status}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
            isThreeLine: true,
            trailing: _buildUserActions(ctx, user),
          ),
        ).animate(delay: Duration(milliseconds: 20 * i)).fadeIn();
      },
    );
  }

  Widget _buildUserActions(BuildContext context, UserModel user) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => [
        if (user.isPending) ...[
          const PopupMenuItem(value: 'approve', child: Text('موافقة', style: TextStyle(fontFamily: 'Cairo'))),
          const PopupMenuItem(value: 'reject', child: Text('رفض', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error))),
        ],
        const PopupMenuItem(value: 'force_logout', child: Text('إخراج إجباري', style: TextStyle(fontFamily: 'Cairo'))),
        const PopupMenuItem(value: 'ban_chat', child: Text('حظر الشات', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error))),
        if (!user.isSuperAdmin) const PopupMenuItem(value: 'delete', child: Text('حذف الحساب', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error))),
      ],
      onSelected: (v) async {
        final adminSvc = ref.read(adminServiceProvider);
        switch (v) {
          case 'approve': await adminSvc.approveUser(user.uid, true); break;
          case 'reject': await adminSvc.approveUser(user.uid, false); break;
          case 'force_logout': await adminSvc.forceLogoutUser(user.uid); break;
          case 'ban_chat': await adminSvc.banUserFromChat(user.uid, !user.chatBanned); break;
          case 'delete': await adminSvc.deleteUser(user.uid); break;
        }
        await _loadData();
      },
    );
  }

  Widget _buildSubsTab() {
    if (_subRequests.isEmpty) return const Center(child: Text('لا توجد طلبات', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _subRequests.length,
      itemBuilder: (ctx, i) {
        final sub = _subRequests[i];
        final status = sub['status']?.toString() ?? 'pending';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(sub['userName']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: _statusColor(status), fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 4),
              Text('${sub['planName']} • ${sub['amount']} ${sub['currency']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
              Text(sub['paymentMethod']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
              if (status == 'pending') ...[
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: ElevatedButton(onPressed: () async { await ref.read(adminServiceProvider).updateSubscriptionRequest(sub['id'].toString(), 'approved', {}); await _loadData(); }, style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36)), child: const Text('قبول', style: TextStyle(fontFamily: 'Cairo')))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () async { await ref.read(adminServiceProvider).updateSubscriptionRequest(sub['id'].toString(), 'rejected', {}); await _loadData(); }, style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), minimumSize: const Size(0, 36)), child: const Text('رفض', style: TextStyle(fontFamily: 'Cairo')))),
                ]),
              ],
            ]),
          ),
        ).animate(delay: Duration(milliseconds: 30 * i)).fadeIn();
      },
    );
  }

  Widget _buildPromosTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () => _showCreatePromoDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('إنشاء كود'),
          ),
        ),
        Expanded(
          child: _promos.isEmpty
              ? const Center(child: Text('لا توجد أكواد', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _promos.length,
                  itemBuilder: (_, i) {
                    final p = _promos[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(p['code']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                        subtitle: Text('خصم: ${p['discount']}% • استخدامات: ${p['usedCount']}/${p['maxUses']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () async { await ref.read(adminServiceProvider).deletePromo(p['code'].toString()); await _loadData(); }),
                      ),
                    ).animate(delay: Duration(milliseconds: 20 * i)).fadeIn();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBanTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: OutlinedButton.icon(
            onPressed: () async { final ok = await ref.read(adminServiceProvider).forceLogoutAll(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'تم إخراج الجميع' : 'فشل'), backgroundColor: ok ? AppColors.success : AppColors.error)); },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('إخراج الجميع إجباراً'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
          ),
        ),
        Expanded(
          child: _banned.isEmpty
              ? const Center(child: Text('لا يوجد محظورون', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _banned.length,
                  itemBuilder: (_, i) {
                    final b = _banned[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.block, color: AppColors.error),
                        title: Text(b['email']?.toString() ?? b['phone']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text(b['reason']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                        trailing: TextButton(onPressed: () async { await ref.read(adminServiceProvider).unbanIdentity(b['id'].toString()); await _loadData(); }, child: const Text('رفع الحظر', style: TextStyle(fontFamily: 'Cairo', fontSize: 11))),
                      ),
                    ).animate(delay: Duration(milliseconds: 20 * i)).fadeIn();
                  },
                ),
        ),
      ],
    );
  }

  void _showCreatePromoDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    final discCtrl = TextEditingController(text: '10');
    final maxCtrl = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('كود جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'الكود'), textCapitalization: TextCapitalization.characters),
          const SizedBox(height: 8),
          TextField(controller: discCtrl, decoration: const InputDecoration(labelText: 'نسبة الخصم %'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: maxCtrl, decoration: const InputDecoration(labelText: 'أقصى استخدام'), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(onPressed: () async {
            await ref.read(adminServiceProvider).createPromo(codeCtrl.text.trim(), double.tryParse(discCtrl.text) ?? 10, int.tryParse(maxCtrl.text) ?? 100);
            if (context.mounted) Navigator.pop(context);
            await _loadData();
          }, child: const Text('إنشاء', style: TextStyle(fontFamily: 'Cairo'))),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'superadmin': return AppColors.gold;
      case 'admin': return AppColors.warning;
      case 'coach': return AppColors.info;
      default: return AppColors.primary;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.warning;
    }
  }
}
