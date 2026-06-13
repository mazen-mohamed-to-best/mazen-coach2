import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/providers/app_providers.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final _promoCtrl = TextEditingController();
  bool _checkingPromo = false;
  String? _promoMsg;
  bool _promoOk = false;
  double _promoDiscount = 0;
  String _selectedPlan = '';
  String _paymentMethod = 'bank';
  bool _submitting = false;
  bool _submitted = false;
  List<Map<String, dynamic>> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    final res = await ref.read(apiServiceProvider).call({'action': 'SUB_CONFIG'});
    if (mounted) {
      setState(() {
        _plans = List<Map<String, dynamic>>.from(res?['plans'] ?? [
          {'id': 'monthly', 'name': 'شهري', 'price': 150, 'currency': 'SAR', 'days': 30},
          {'id': 'quarterly', 'name': 'ربع سنوي', 'price': 400, 'currency': 'SAR', 'days': 90},
          {'id': 'yearly', 'name': 'سنوي', 'price': 1200, 'currency': 'SAR', 'days': 365},
        ]);
        if (_plans.isNotEmpty) _selectedPlan = _plans.first['id']?.toString() ?? '';
        _loading = false;
      });
    }
  }

  Future<void> _checkPromo() async {
    if (_promoCtrl.text.isEmpty) return;
    setState(() { _checkingPromo = true; _promoMsg = null; });
    try {
      final res = await ref.read(apiServiceProvider).call({'action': 'PROMO_CHECK', 'code': _promoCtrl.text.trim()});
      if (res?['ok'] == true) {
        setState(() { _promoOk = true; _promoDiscount = (res!['discount'] as num?)?.toDouble() ?? 0; _promoMsg = 'كود صالح! خصم ${_promoDiscount.toStringAsFixed(0)}%'; });
      } else {
        setState(() { _promoOk = false; _promoDiscount = 0; _promoMsg = 'كود غير صالح أو منتهي'; });
      }
    } finally {
      if (mounted) setState(() => _checkingPromo = false);
    }
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _selectedPlan.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final plan = _plans.firstWhere((p) => p['id'] == _selectedPlan, orElse: () => {});
      final res = await ref.read(apiServiceProvider).call({
        'action': 'SUB_REQUEST',
        'uid': user.uid,
        'userName': user.displayName,
        'userEmail': user.email,
        'planId': _selectedPlan,
        'planName': plan['name'] ?? '',
        'amount': plan['price'] ?? 0,
        'currency': plan['currency'] ?? 'SAR',
        'paymentMethod': _paymentMethod,
        if (_promoOk) 'promoCode': _promoCtrl.text.trim(),
        if (_promoOk) 'discount': _promoDiscount,
      });
      if (res?['ok'] == true && mounted) setState(() => _submitted = true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('الاشتراك')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 80).animate().scale(curve: Curves.elasticOut),
              const SizedBox(height: 24),
              const Text('تم إرسال طلب الاشتراك!', style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w700)).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              const Text('سيتواصل معك المدرب لتأكيد الاشتراك', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textGrey)).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('الاشتراك')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current subscription
                  if (user?.subscriptionInfo != null) _buildCurrentSubCard(user!),

                  // Plans
                  Text('اختر الباقة', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(),
                  const SizedBox(height: 12),
                  ..._plans.asMap().entries.map((e) => _buildPlanCard(e.key, e.value)),

                  const SizedBox(height: 20),

                  // Payment method
                  Text('طريقة الدفع', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 8),
                  _buildPaymentMethods(),

                  const SizedBox(height: 20),

                  // Promo code
                  Text('كود خصم (اختياري)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextFormField(controller: _promoCtrl, decoration: const InputDecoration(hintText: 'PROMO2024', prefixIcon: Icon(Icons.discount_outlined)), textCapitalization: TextCapitalization.characters)),
                    const SizedBox(width: 8),
                    SizedBox(height: 52, child: ElevatedButton(onPressed: _checkingPromo ? null : _checkPromo, child: _checkingPromo ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('تحقق', style: TextStyle(fontFamily: 'Cairo')))),
                  ]).animate().fadeIn(delay: 220.ms),
                  if (_promoMsg != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: (_promoOk ? AppColors.success : AppColors.error).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        Icon(_promoOk ? Icons.check_circle_outline : Icons.cancel_outlined, color: _promoOk ? AppColors.success : AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Text(_promoMsg!, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: _promoOk ? AppColors.success : AppColors.error)),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Submit
                  SizedBox(
                    width: double.infinity, height: 54,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('إرسال طلب الاشتراك', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentSubCard(dynamic user) {
    final sub = user.subscriptionInfo as Map<String, dynamic>? ?? {};
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppGradients.primaryGradient, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.verified_rounded, color: Colors.white70, size: 18), SizedBox(width: 8), Text('اشتراكك الحالي', style: TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 13))]),
        const SizedBox(height: 8),
        Text(sub['plan']?.toString() ?? 'فعّال', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        if (sub['expiry'] != null) Text('ينتهي: ${sub['expiry']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70)),
      ]),
    ).animate().fadeIn();
  }

  Widget _buildPlanCard(int i, Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == plan['id']?.toString();
    final price = (plan['price'] as num?)?.toDouble() ?? 0;
    final discounted = _promoOk ? price * (1 - _promoDiscount / 100) : price;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan['id']?.toString() ?? ''),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withOpacity(0.5), width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? AppColors.primary : AppColors.textGrey),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(plan['name']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700)),
            Text('${plan['days']} يوم', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textGrey)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (_promoOk) Text('${price.toStringAsFixed(0)} ${plan['currency'] ?? 'SAR'}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, decoration: TextDecoration.lineThrough, color: AppColors.textGrey)),
            Text('${discounted.toStringAsFixed(0)} ${plan['currency'] ?? 'SAR'}', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: isSelected ? AppColors.primary : null)),
          ]),
        ]),
      ),
    ).animate(delay: Duration(milliseconds: 50 * i)).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'id': 'bank', 'name': 'تحويل بنكي', 'icon': Icons.account_balance_outlined},
      {'id': 'stc', 'name': 'STC Pay', 'icon': Icons.phone_iphone_outlined},
      {'id': 'cash', 'name': 'كاش', 'icon': Icons.payments_outlined},
    ];
    return Row(children: methods.map((m) {
      final isSelected = _paymentMethod == m['id'];
      return Expanded(child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = m['id'] as String),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withOpacity(0.5), width: isSelected ? 1.5 : 1),
          ),
          child: Column(children: [
            Icon(m['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.textGrey, size: 22),
            const SizedBox(height: 4),
            Text(m['name'] as String, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.textGrey)),
          ]),
        ),
      ));
    }).toList());
  }
}
