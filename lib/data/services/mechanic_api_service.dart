import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class MechanicApiService {
  MechanicApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl =
            (baseUrl ?? ApiConstants.usersBaseUrl).trim().replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> updateAvailability({
    required String accessToken,
    required String availability, // ONLINE | OFFLINE
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiConstants.usersMeAvailabilityPath}');
    final res = await _client.patch(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'availability': availability,
        'lastKnownLocation': {
          'coordinates': [longitude, latitude],
        },
      }),
    );
    return _decodeOrThrow(res, defaultMessage: 'Failed to update availability');
  }

  Map<String, dynamic> _decodeOrThrow(http.Response res, {required String defaultMessage}) {
    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(res.body);
      body = (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
    } catch (_) {
      body = <String, dynamic>{};
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = (body['message'] is String && (body['message'] as String).trim().isNotEmpty)
          ? body['message'] as String
          : '$defaultMessage (HTTP ${res.statusCode})';
      throw MechanicApiException(msg);
    }
    return body;
  }
}

class MechanicApiException implements Exception {
  MechanicApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

