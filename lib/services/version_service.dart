import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_best/core/constants/api_actions.dart';
import 'package:to_best/core/network/api_service.dart';
import 'package:to_best/models/version_model.dart';

class VersionService {
  final ApiService _api;

  VersionService(this._api);

  static const _cacheKey = 'cached_version_info';
  static const _cacheExpiry = Duration(hours: 6);
  static const _cacheTimeKey = 'cached_version_ts';

  Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  Future<VersionInfo> fetchVersionInfo() async {
    // 1. Try server
    if (_api.isConfigured) {
      try {
        final res = await _api
            .call({'action': ApiActions.versionCheck})
            .timeout(const Duration(seconds: 8));
        if (res?['ok'] == true && res?['version'] != null) {
          final info = VersionInfo.fromMap(
              res!['version'] as Map<String, dynamic>);
          await _cache(res['version'] as Map<String, dynamic>);
          return info;
        }
      } catch (_) {}
    }

    // 2. Try cached
    final cached = await _loadCache();
    if (cached != null) return cached;

    // 3. Fully offline — allow app to run
    return VersionInfo.offline();
  }

  Future<UpdateState> checkUpdate() async {
    final current = await getCurrentVersion();
    final info = await fetchVersionInfo();
    return info.evaluateState(current);
  }

  /// Full result: both the state and the VersionInfo (needed for download URL etc.)
  Future<({UpdateState state, VersionInfo info, String current})>
      checkFull() async {
    final current = await getCurrentVersion();
    final info = await fetchVersionInfo();
    return (state: info.evaluateState(current), info: info, current: current);
  }

  Future<void> _cache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = data.entries
        .map((e) => '${e.key}=${e.value}')
        .join('||');
    await prefs.setString(_cacheKey, encoded);
    await prefs.setInt(
        _cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<VersionInfo?> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_cacheTimeKey) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > _cacheExpiry.inMilliseconds) return null;
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final map = Map<String, dynamic>.fromEntries(
        raw.split('||').map((e) {
          final idx = e.indexOf('=');
          if (idx < 0) return MapEntry(e, '');
          return MapEntry(e.substring(0, idx), e.substring(idx + 1));
        }),
      );
      return VersionInfo.fromMap(map);
    } catch (_) {
      return null;
    }
  }
}
