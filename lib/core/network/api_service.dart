import 'dart:convert';
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
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  ));

  String _webAppUrl = '';
  String _sessionToken = '';

  void configure(String url, String sessionToken) {
    _webAppUrl = url;
    _sessionToken = sessionToken;
  }

  bool get isConfigured => _webAppUrl.isNotEmpty;

  Future<Map<String, dynamic>?> call(Map<String, dynamic> payload) async {
    if (!isConfigured) return null;
    try {
      final secretKey = await SecureSettings.instance.getSecretKey();
      final fullPayload = {
        ...payload,
        'secret': secretKey,
        if (_sessionToken.isNotEmpty) 'sessionToken': _sessionToken,
      };
      final body = 'payload=${Uri.encodeComponent(jsonEncode(fullPayload))}';
      final response = await _dio.post(_webAppUrl, data: body);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is String) return jsonDecode(data) as Map<String, dynamic>;
        if (data is Map<String, dynamic>) return data;
      }
    } on DioException catch (e) {
      if (kDebugMode) print('[API] Error: ${e.message}');
    } catch (e) {
      if (kDebugMode) print('[API] Unexpected: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> callPublic(
      Map<String, dynamic> payload) async {
    if (!isConfigured) return null;
    try {
      final body = 'payload=${Uri.encodeComponent(jsonEncode(payload))}';
      final response = await _dio.post(_webAppUrl, data: body);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is String) return jsonDecode(data) as Map<String, dynamic>;
        if (data is Map<String, dynamic>) return data;
      }
    } catch (e) {
      if (kDebugMode) print('[API] Public Error: $e');
    }
    return null;
  }

  void updateSessionToken(String token) {
    _sessionToken = token;
  }

  void clearSessionToken() {
    _sessionToken = '';
  }
}
