import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/utils/secure_settings.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
    receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
    sendTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
    contentType: Headers.formUrlEncodedContentType,
    responseType: ResponseType.plain,
    followRedirects: true,
    validateStatus: (status) => status != null && status >= 200 && status < 500,
  ));

  String _webAppUrl = '';
  String _sessionToken = '';
  String? _lastError;

  String? get lastError => _lastError;

  void configure(String url, String sessionToken) {
    _webAppUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    _sessionToken = sessionToken;
    _lastError = null;
  }

  bool get isConfigured => _webAppUrl.isNotEmpty;

  String _computeHmac(String secret, String payloadJson) {
    final hmac = crypto.Hmac(crypto.sha256, utf8.encode(secret));
    return hmac.convert(utf8.encode(payloadJson)).toString();
  }

  Map<String, dynamic>? _decodeResponse(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return null;
      final parsed = jsonDecode(trimmed);
      if (parsed is Map<String, dynamic>) return parsed;
      if (parsed is Map) return Map<String, dynamic>.from(parsed);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _postPayload(
    Map<String, dynamic> payload, {
    bool includeSecret = true,
  }) async {
    if (!isConfigured) {
      _lastError = 'WebApp URL غير مضبوط';
      return null;
    }

    try {
      final secretKey = includeSecret ? await SecureSettings.instance.getSecretKey() : '';
      final basePayload = Map<String, dynamic>.from(payload);

      if (_sessionToken.isNotEmpty) {
        basePayload['sessionToken'] = _sessionToken;
      }
      if (includeSecret && secretKey.isNotEmpty) {
        basePayload['secret'] = secretKey;
      }

      final baseJson = jsonEncode(basePayload);
      final fullPayload = Map<String, dynamic>.from(basePayload);

      if (includeSecret && secretKey.isNotEmpty) {
        fullPayload['hmac'] = _computeHmac(secretKey, baseJson);
      }

      final response = await _dio.post(
        _webAppUrl,
        data: <String, dynamic>{
          'payload': jsonEncode(fullPayload),
        },
      );

      final decoded = _decodeResponse(response.data);
      if (response.statusCode == 200 && decoded != null) {
        _lastError = null;
        return decoded;
      }

      _lastError = decoded?['err']?.toString() ??
          decoded?['error']?.toString() ??
          'HTTP ${response.statusCode}';
      return decoded;
    } on DioException catch (e) {
      _lastError = e.message ?? e.type.toString();
      if (e.response?.data != null) {
        final decoded = _decodeResponse(e.response?.data);
        if (decoded != null) {
          _lastError = decoded['err']?.toString() ??
              decoded['error']?.toString() ??
              _lastError;
          return decoded;
        }
      }
      if (kDebugMode) print('[API] Error: $_lastError');
    } on FormatException catch (e) {
      _lastError = 'رد غير صالح من الخادم: ${e.message}';
      if (kDebugMode) print('[API] Format error: $_lastError');
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) print('[API] Unexpected: $_lastError');
    }
    return null;
  }

  Future<Map<String, dynamic>?> call(Map<String, dynamic> payload) async {
    return _postPayload(payload, includeSecret: true);
  }

  Future<Map<String, dynamic>?> callPublic(Map<String, dynamic> payload) async {
    return _postPayload(payload, includeSecret: false);
  }

  void updateSessionToken(String token) {
    _sessionToken = token;
  }

  void clearSessionToken() {
    _sessionToken = '';
  }
}
