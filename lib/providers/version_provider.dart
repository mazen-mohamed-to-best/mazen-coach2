import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/models/version_model.dart';
import 'package:to_best/services/version_service.dart';
import 'package:to_best/providers/app_providers.dart';

// ── Service provider ─────────────────────────────────────────────────────────
final versionServiceProvider = Provider<VersionService>((ref) {
  return VersionService(ref.read(apiServiceProvider));
});

// ── Check result data class ──────────────────────────────────────────────────
class VersionCheckResult {
  final UpdateState state;
  final VersionInfo info;
  final String currentVersion;

  const VersionCheckResult({
    required this.state,
    required this.info,
    required this.currentVersion,
  });

  bool get needsAction => state != UpdateState.upToDate;
  bool get isBlocking =>
      state == UpdateState.required ||
      state == UpdateState.blocked ||
      state == UpdateState.maintenance;
  bool get isOptional => state == UpdateState.optional;
}

// ── Async provider — called once on startup ──────────────────────────────────
final versionCheckProvider =
    FutureProvider.autoDispose<VersionCheckResult>((ref) async {
  final svc = ref.read(versionServiceProvider);
  final result = await svc.checkFull();
  return VersionCheckResult(
    state: result.state,
    info: result.info,
    currentVersion: result.current,
  );
});

// ── Dismissed flag — user tapped "Later" on optional update ─────────────────
final updateDismissedProvider = StateProvider<bool>((ref) => false);
