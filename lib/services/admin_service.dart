import 'package:to_best/core/constants/api_actions.dart';
import 'package:to_best/core/network/api_service.dart';
import 'package:to_best/models/user_model.dart';
import 'package:to_best/models/subscription_model.dart';

class AdminService {
  final ApiService _api;
  AdminService(this._api);

  // ── Users ──
  Future<List<UserModel>> fetchAllUsers() async {
    final res = await _api.call({'action': ApiActions.fetchAllUsers});
    if (res?['ok'] != true) return [];
    final users = res!['users'] as List? ?? [];
    return users.map((u) => UserModel.fromMap(u as Map<String, dynamic>)).toList();
  }

  Future<bool> approveUser(String uid, bool approved) async {
    final res = await _api.call({'action': ApiActions.adminApprove, 'uid': uid, 'approved': approved});
    return res?['ok'] == true;
  }

  Future<bool> updateUser(String uid, Map<String, dynamic> fields) async {
    final res = await _api.call({'action': ApiActions.adminUpdateUser, 'uid': uid, 'fields': fields});
    return res?['ok'] == true;
  }

  Future<bool> deleteUser(String uid) async {
    final res = await _api.call({'action': ApiActions.adminDeleteUser, 'uid': uid});
    return res?['ok'] == true;
  }

  Future<bool> approveProgram(String uid, String programId, int days) async {
    final res = await _api.call({'action': ApiActions.approveProgram, 'uid': uid, 'programId': programId, 'programDays': days});
    return res?['ok'] == true;
  }

  // ── Force Logout ──
  Future<bool> forceLogoutUser(String uid) async {
    final res = await _api.call({'action': ApiActions.forceLogoutUser, 'uid': uid, 'token': DateTime.now().millisecondsSinceEpoch.toString()});
    return res?['ok'] == true;
  }

  Future<bool> forceLogoutAll() async {
    final res = await _api.call({'action': ApiActions.forceLogoutAll, 'token': DateTime.now().millisecondsSinceEpoch.toString()});
    return res?['ok'] == true;
  }

  // ── Ban ──
  Future<bool> banIdentity(Map<String, dynamic> banEntry) async {
    final res = await _api.call({'action': ApiActions.banIdentity, 'banEntry': banEntry});
    return res?['ok'] == true;
  }

  Future<bool> unbanIdentity(String banId) async {
    final res = await _api.call({'action': ApiActions.unbanIdentity, 'banId': banId});
    return res?['ok'] == true;
  }

  Future<List<Map<String, dynamic>>> listBanned() async {
    final res = await _api.call({'action': ApiActions.listBanned});
    if (res?['ok'] != true) return [];
    return List<Map<String, dynamic>>.from(res!['list'] ?? []);
  }

  // ── Subscriptions ──
  Future<List<SubscriptionRequestModel>> getSubscriptionRequests() async {
    final res = await _api.call({'action': ApiActions.getSubRequests});
    if (res?['ok'] != true) return [];
    final list = res!['requests'] as List? ?? [];
    return list.map((r) => SubscriptionRequestModel.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<bool> updateSubscriptionRequest(String id, String status, Map<String, dynamic> fields) async {
    final res = await _api.call({'action': ApiActions.updateSubRequest, 'id': id, 'status': status, 'fields': fields});
    return res?['ok'] == true;
  }

  Future<bool> saveSubscriptionConfig(Map<String, dynamic> cfg) async {
    final res = await _api.call({'action': ApiActions.subConfig, 'data': cfg});
    return res?['ok'] == true;
  }

  // ── Promo Codes ──
  Future<bool> createPromo(String code, double discount, int maxUses) async {
    final res = await _api.call({'action': ApiActions.promoCreate, 'code': code, 'discount': discount, 'maxUses': maxUses});
    return res?['ok'] == true;
  }

  Future<List<Map<String, dynamic>>> listPromos() async {
    final res = await _api.call({'action': ApiActions.promoList});
    if (res?['ok'] != true) return [];
    return List<Map<String, dynamic>>.from(res!['codes'] ?? []);
  }

  Future<bool> deletePromo(String code) async {
    final res = await _api.call({'action': ApiActions.promoDelete, 'code': code});
    return res?['ok'] == true;
  }

  // ── Guest Codes ──
  Future<bool> createGuestCode(String code) async {
    final res = await _api.call({'action': ApiActions.guestCreate, 'code': code});
    return res?['ok'] == true;
  }

  Future<List<Map<String, dynamic>>> listGuestCodes() async {
    final res = await _api.call({'action': ApiActions.guestList});
    if (res?['ok'] != true) return [];
    return List<Map<String, dynamic>>.from(res!['codes'] ?? []);
  }

  Future<bool> deleteGuestCode(String code) async {
    final res = await _api.call({'action': ApiActions.guestDelete, 'code': code});
    return res?['ok'] == true;
  }

  // ── Chat moderation ──
  Future<bool> banUserFromChat(String uid, bool ban) async {
    final res = await _api.call({'action': ApiActions.chatBan, 'uid': uid, 'ban': ban});
    return res?['ok'] == true;
  }

  Future<bool> muteUserInChat(String uid, int muteUntil) async {
    final res = await _api.call({'action': ApiActions.chatMute, 'uid': uid, 'muteUntil': muteUntil});
    return res?['ok'] == true;
  }

  // ── Referral stats ──
  Future<Map<String, dynamic>?> getReferralStats(String code) async {
    final res = await _api.call({'action': ApiActions.getReferralStats, 'code': code});
    if (res?['ok'] != true) return null;
    return res;
  }

  // ── Profile picture ──
  Future<Map<String, dynamic>> saveProfilePicture(String uid, String imageData) async {
    final res = await _api.call({'action': ApiActions.saveProfilePic, 'uid': uid, 'imageData': imageData});
    return res ?? {'ok': false};
  }
}
