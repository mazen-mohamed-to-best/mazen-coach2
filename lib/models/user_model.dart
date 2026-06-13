import 'package:to_best/core/constants/app_constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String status;
  final String? programId;
  final int? programDays;
  final String? pictureUrl;
  final String? referralCode;
  final int referralCoins;
  final Map<String, dynamic>? subscriptionInfo;
  final Map<String, dynamic>? nutritionTargets;
  final List<String> gymDays;
  final String? forceLogoutToken;
  final bool chatBanned;
  final int? chatMuteUntil;
  final Map<String, dynamic> raw;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.status,
    this.programId,
    this.programDays,
    this.pictureUrl,
    this.referralCode,
    this.referralCoins = 0,
    this.subscriptionInfo,
    this.nutritionTargets,
    this.gymDays = const [],
    this.forceLogoutToken,
    this.chatBanned = false,
    this.chatMuteUntil,
    this.raw = const {},
  });

  bool get isAdmin =>
      role == AppConstants.roleAdmin || role == AppConstants.roleSuperAdmin;
  bool get isSuperAdmin => role == AppConstants.roleSuperAdmin;
  bool get isCoach => role == AppConstants.roleCoach;
  bool get isTrainee => role == AppConstants.roleTrainee;
  bool get isActive => status == AppConstants.statusActive;
  bool get isPending => status == AppConstants.statusPending;
  bool get isRejected => status == AppConstants.statusRejected;

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? map['fullName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? AppConstants.roleTrainee,
      status: map['status']?.toString() ?? AppConstants.statusPending,
      programId: map['programId']?.toString() ?? map['program']?.toString(),
      programDays: _parseInt(map['programDays']),
      pictureUrl: map['picture']?.toString() ?? map['pictureUrl']?.toString(),
      referralCode: map['referralCode']?.toString(),
      referralCoins: _parseInt(map['referralCoins']) ?? 0,
      subscriptionInfo: map['subscription'] as Map<String, dynamic>?,
      nutritionTargets: map['nutritionTargets'] as Map<String, dynamic>?,
      gymDays: _parseList(map['gymDays']),
      forceLogoutToken: map['forceLogoutToken']?.toString(),
      chatBanned: map['chatBanned'] == true || map['chatBanned'] == 'true',
      chatMuteUntil: _parseInt(map['chatMuteUntil']),
      raw: map,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'status': status,
      if (programId != null) 'programId': programId,
      if (programDays != null) 'programDays': programDays,
      if (pictureUrl != null) 'picture': pictureUrl,
      if (referralCode != null) 'referralCode': referralCode,
      'referralCoins': referralCoins,
      if (subscriptionInfo != null) 'subscription': subscriptionInfo,
      if (nutritionTargets != null) 'nutritionTargets': nutritionTargets,
      'gymDays': gymDays,
      if (forceLogoutToken != null) 'forceLogoutToken': forceLogoutToken,
      'chatBanned': chatBanned,
      if (chatMuteUntil != null) 'chatMuteUntil': chatMuteUntil,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? status,
    String? programId,
    int? programDays,
    String? pictureUrl,
    String? referralCode,
    int? referralCoins,
    Map<String, dynamic>? subscriptionInfo,
    Map<String, dynamic>? nutritionTargets,
    List<String>? gymDays,
    String? forceLogoutToken,
    bool? chatBanned,
    int? chatMuteUntil,
    Map<String, dynamic>? raw,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      programId: programId ?? this.programId,
      programDays: programDays ?? this.programDays,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      referralCode: referralCode ?? this.referralCode,
      referralCoins: referralCoins ?? this.referralCoins,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
      nutritionTargets: nutritionTargets ?? this.nutritionTargets,
      gymDays: gymDays ?? this.gymDays,
      forceLogoutToken: forceLogoutToken ?? this.forceLogoutToken,
      chatBanned: chatBanned ?? this.chatBanned,
      chatMuteUntil: chatMuteUntil ?? this.chatMuteUntil,
      raw: raw ?? this.raw,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, role: $role)';
}
