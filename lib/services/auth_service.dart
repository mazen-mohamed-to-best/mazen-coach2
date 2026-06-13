import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_best/core/constants/api_actions.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/network/api_service.dart';
import 'package:to_best/core/local_db/database_helper.dart';
import 'package:to_best/models/user_model.dart';

class AuthResult {
  final bool ok;
  final String? error;
  final UserModel? user;
  final String? sessionToken;

  const AuthResult({required this.ok, this.error, this.user, this.sessionToken});
}

class AuthService {
  final ApiService _api;
  final DatabaseHelper _db;

  AuthService(this._api, this._db);

  Future<AuthResult> login(String email, String password) async {
    if (!_api.isConfigured) {
      return const AuthResult(ok: false, error: 'not_configured');
    }
    final res = await _api.call({
      'action': ApiActions.login,
      'email': email,
      'password': password,
    });
    if (res == null) return const AuthResult(ok: false, error: 'network');
    if (res['ok'] != true) {
      return AuthResult(ok: false, error: res['err']?.toString() ?? 'unknown');
    }

    final userData = res['user'] as Map<String, dynamic>? ?? {};
    final user = UserModel.fromMap(userData);
    final token = res['sessionToken']?.toString() ?? '';

    // Cache user locally
    await _db.upsertUser(user.uid, userData);

    // Persist session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrentUserId, user.uid);
    if (token.isNotEmpty) {
      await prefs.setString(AppConstants.keySessionToken, token);
      _api.updateSessionToken(token);
    }

    return AuthResult(ok: true, user: user, sessionToken: token);
  }

  Future<AuthResult> register(Map<String, dynamic> userData) async {
    if (!_api.isConfigured) {
      return const AuthResult(ok: false, error: 'not_configured');
    }
    final res = await _api.call({
      'action': ApiActions.register,
      ...userData,
    });
    if (res == null) return const AuthResult(ok: false, error: 'network');
    if (res['ok'] != true) {
      return AuthResult(ok: false, error: res['err']?.toString() ?? 'unknown');
    }
    return const AuthResult(ok: true);
  }

  Future<bool> changePassword(String uid, String oldPwd, String newPwd) async {
    final res = await _api.call({
      'action': ApiActions.changePassword,
      'uid': uid,
      'oldPwd': oldPwd,
      'newPwd': newPwd,
    });
    return res?['ok'] == true;
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(AppConstants.keyCurrentUserId);
    if (uid == null || uid.isEmpty) return null;
    final userData = await _db.getUser(uid);
    if (userData == null) return null;
    return UserModel.fromMap(userData);
  }

  Future<String?> getStoredSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keySessionToken);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyCurrentUserId);
    await prefs.remove(AppConstants.keySessionToken);
    _api.clearSessionToken();
    await _db.clearAll();
  }

  Future<bool> checkForceLogout(String uid, String? knownToken) async {
    final userData = await _db.getUser(uid);
    if (userData == null) return false;
    final serverToken = userData['forceLogoutToken']?.toString() ?? '';
    if (serverToken.isEmpty) return false;
    return serverToken != (knownToken ?? '');
  }

  Future<bool> checkBan(String email, String phone) async {
    final res = await _api.call({
      'action': ApiActions.checkBan,
      'email': email,
      'phone': phone,
    });
    return res?['banned'] == true;
  }

  Future<bool> testConnection() async {
    final res = await _api.call({'action': ApiActions.ping});
    return res?['ok'] == true;
  }
}
