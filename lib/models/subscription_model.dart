class SubscriptionRequestModel {
  final String id;
  final String uid;
  final String userName;
  final String userEmail;
  final String planName;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? proofUrl;
  final String status;
  final String? promoCode;
  final double? discountPercent;
  final DateTime createdAt;
  final DateTime? processedAt;

  const SubscriptionRequestModel({
    required this.id,
    required this.uid,
    required this.userName,
    required this.userEmail,
    required this.planName,
    required this.amount,
    this.currency = 'SAR',
    required this.paymentMethod,
    this.proofUrl,
    required this.status,
    this.promoCode,
    this.discountPercent,
    required this.createdAt,
    this.processedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory SubscriptionRequestModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionRequestModel(
      id: map['id']?.toString() ?? '',
      uid: map['uid']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userEmail: map['userEmail']?.toString() ?? '',
      planName: map['planName']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      currency: map['currency']?.toString() ?? 'SAR',
      paymentMethod: map['paymentMethod']?.toString() ?? '',
      proofUrl: map['proofUrl']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      promoCode: map['promoCode']?.toString(),
      discountPercent: (map['discount'] as num?)?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as num).toInt())
          : DateTime.now(),
      processedAt: map['processedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['processedAt'] as num).toInt())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'userName': userName,
        'userEmail': userEmail,
        'planName': planName,
        'amount': amount,
        'currency': currency,
        'paymentMethod': paymentMethod,
        if (proofUrl != null) 'proofUrl': proofUrl,
        'status': status,
        if (promoCode != null) 'promoCode': promoCode,
        if (discountPercent != null) 'discount': discountPercent,
        'createdAt': createdAt.millisecondsSinceEpoch,
        if (processedAt != null) 'processedAt': processedAt!.millisecondsSinceEpoch,
      };
}

class SubscriptionPlanModel {
  final String id;
  final String name;
  final String nameEn;
  final double price;
  final String currency;
  final int durationDays;
  final String? description;
  final bool isActive;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.price,
    this.currency = 'SAR',
    required this.durationDays,
    this.description,
    this.isActive = true,
  });

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      nameEn: map['nameEn']?.toString() ?? map['name']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      currency: map['currency']?.toString() ?? 'SAR',
      durationDays: (map['days'] as num?)?.toInt() ?? 30,
      description: map['description']?.toString(),
      isActive: map['active'] != false,
    );
  }
}
