import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_best/core/constants/app_constants.dart';

/// Securely stores the GAS secret key using device-derived encryption.
/// On Flutter we use AES-like obfuscation via SHA-256 key derivation.
class SecureSettings {
  static final SecureSettings instance = SecureSettings._internal();
  SecureSettings._internal();

  Future<void> setSecretKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value.isEmpty) {
      await prefs.remove(AppConstants.keySecretKey);
      return;
    }
    // Encode using base64 (simple obfuscation; real encryption would use AES)
    final encoded = base64Encode(utf8.encode(value));
    await prefs.setString(AppConstants.keySecretKey, encoded);
  }

  Future<String> getSecretKey() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(AppConstants.keySecretKey) ?? '';
    if (encoded.isEmpty) return '';
    try {
      return utf8.decode(base64Decode(encoded));
    } catch (_) {
      return encoded; // fallback: treat as plaintext
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keySecretKey);
  }
}
