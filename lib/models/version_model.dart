enum UpdateState {
  upToDate,
  optional,
  required,
  blocked,
  maintenance,
}

class VersionInfo {
  final String minVersion;
  final String requiredVersion;
  final String latestVersion;
  final String downloadUrl;
  final String messageAr;
  final String messageEn;
  final bool maintenanceMode;
  final String maintenanceAr;
  final String maintenanceEn;
  final String contactUrl;

  const VersionInfo({
    required this.minVersion,
    required this.requiredVersion,
    required this.latestVersion,
    required this.downloadUrl,
    this.messageAr = '',
    this.messageEn = '',
    this.maintenanceMode = false,
    this.maintenanceAr = 'التطبيق تحت الصيانة، يرجى المحاولة لاحقاً.',
    this.maintenanceEn = 'App is under maintenance, please try again later.',
    this.contactUrl = '',
  });

  factory VersionInfo.fromMap(Map<String, dynamic> m) {
    return VersionInfo(
      minVersion: m['minVersion']?.toString() ?? '1.0.0',
      requiredVersion: m['requiredVersion']?.toString() ?? '1.0.0',
      latestVersion: m['latestVersion']?.toString() ?? '1.0.0',
      downloadUrl: m['downloadUrl']?.toString() ?? '',
      messageAr: m['messageAr']?.toString() ?? '',
      messageEn: m['messageEn']?.toString() ?? '',
      maintenanceMode: m['maintenanceMode'] == true,
      maintenanceAr: m['maintenanceAr']?.toString() ?? 'التطبيق تحت الصيانة.',
      maintenanceEn: m['maintenanceEn']?.toString() ?? 'Under maintenance.',
      contactUrl: m['contactUrl']?.toString() ?? '',
    );
  }

  /// Fallback when offline — treat as up-to-date so app still works offline.
  factory VersionInfo.offline() {
    return const VersionInfo(
      minVersion: '0.0.0',
      requiredVersion: '0.0.0',
      latestVersion: '0.0.0',
      downloadUrl: '',
    );
  }

  UpdateState evaluateState(String currentVersion) {
    if (maintenanceMode) return UpdateState.maintenance;
    final current = _parse(currentVersion);
    final min = _parse(minVersion);
    final required = _parse(requiredVersion);
    final latest = _parse(latestVersion);

    if (_less(current, min)) return UpdateState.blocked;
    if (_less(current, required)) return UpdateState.required;
    if (_less(current, latest)) return UpdateState.optional;
    return UpdateState.upToDate;
  }

  static List<int> _parse(String v) {
    final parts = v.split('.').map((p) => int.tryParse(p.trim()) ?? 0).toList();
    while (parts.length < 3) parts.add(0);
    return parts;
  }

  static bool _less(List<int> a, List<int> b) {
    for (int i = 0; i < 3; i++) {
      if (a[i] < b[i]) return true;
      if (a[i] > b[i]) return false;
    }
    return false;
  }
}
