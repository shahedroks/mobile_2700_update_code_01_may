import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

/// Company-role API calls (same host as mechanic; Bearer identifies company user).
class CompanyApiService {
  CompanyApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl =
            (baseUrl ?? ApiConstants.usersBaseUrl).trim().replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  /// Dashboard summary (`GET /api/v1/company/dashboard`).
  Future<Map<String, dynamic>> fetchDashboard({required String accessToken}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/company/dashboard');
    final res = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    return _decodeOrThrow(res, defaultMessage: 'Failed to fetch company dashboard');
  }

  /// Published jobs visible to companies (`GET /api/v1/company/feed`).
  Future<Map<String, dynamic>> fetchCompanyFeed({
    required String accessToken,
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/company/feed').replace(
      queryParameters: {'page': '$page', 'limit': '$limit'},
    );
    final res = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    return _decodeOrThrow(res, defaultMessage: 'Failed to fetch company feed');
  }

  /// Provider quotes submitted by this company (`GET /api/v1/quotes/me`).
  Future<Map<String, dynamic>> fetchMyQuotes({
    required String accessToken,
    int page = 1,
    int limit = 100,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/quotes/me').replace(
      queryParameters: {'page': '$page', 'limit': '$limit'},
    );
    final res = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    return _decodeOrThrow(res, defaultMessage: 'Failed to fetch quotes');
  }

  Map<String, dynamic> _decodeOrThrow(http.Response res, {required String defaultMessage}) {
    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(res.body);
      body = (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
    } catch (_) {
      body = <String, dynamic>{};
    }

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (!ok) {
      final msg = (body['message'] as String?) ?? defaultMessage;
      throw Exception(msg);
    }
    return body;
  }
}
