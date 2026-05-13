import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../models/session.dart';
import 'app_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConstants.baseUrl)
            .trim()
            .replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  Session? _session;
  static const _kSessionKey = 'truckfix.session.v1';

  @override
  Future<void> clearSession() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionKey);
  }

  @override
  Future<Session?> getSession() async {
    if (_session != null) return _session;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessionKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final role = _parseRole(decoded['role']) ?? UserRole.fleet;
      final email = (decoded['email'] as String?) ?? '';
      if (email.trim().isEmpty) return null;
      final session = Session(
        email: email,
        role: role,
        displayName: decoded['displayName'] as String?,
        accessToken: decoded['accessToken'] as String?,
        refreshToken: decoded['refreshToken'] as String?,
      );
      _session = session;
      return session;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSession(Session session) async {
    _session = session;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kSessionKey,
      jsonEncode({
        'email': session.email,
        'role': session.role.name,
        'displayName': session.displayName,
        'accessToken': session.accessToken,
        'refreshToken': session.refreshToken,
      }),
    );
  }

  static UserRole? _parseRole(dynamic value) {
    final raw = (value is String) ? value.toLowerCase().trim() : null;
    return switch (raw) {
      'fleet' => UserRole.fleet,
      'mechanic' => UserRole.mechanic,
      'company' => UserRole.company,
      'employee' => UserRole.employee,
      _ => null,
    };
  }

  static String? _pickString(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  static Map<String, dynamic> _pickObject(
      Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v is Map<String, dynamic>) return v;
    }
    return const {};
  }

  @override
  Future<Session> login({
    required String email,
    required String password,
    required UserRole roleHint,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiConstants.authLoginPath}');
    final res = await _client.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(res.body);
      body = (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
    } catch (_) {
      body = <String, dynamic>{};
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = _pickString(body, ['message', 'error', 'msg']) ??
          'Login failed (HTTP ${res.statusCode}).';
      throw AuthException(msg);
    }

    // Support common API shapes:
    // - { token: "...", user: { email, role, name } }
    // - { data: { token, user: {...} } }
    // - { accessToken: "...", role: "fleet", email: "..." }
    final data = _pickObject(body, ['data', 'result', 'payload', 'response']);
    final rootOrData = data.isNotEmpty ? data : body;
    final user = _pickObject(rootOrData, ['user', 'account', 'profile']);
    final mechanicProfile = _pickObject(user, ['mechanicProfile', 'mechanic_profile']);
    final fleetProfile = _pickObject(user, ['fleetProfile', 'fleet_profile']);
    final companyProfile = _pickObject(user, ['companyProfile', 'company_profile']);
    final employeeProfile = _pickObject(user, ['employeeProfile', 'employee_profile']);

    final accessToken = _pickString(
        rootOrData, ['accessToken', 'token', 'access_token', 'jwt']);
    final refreshToken = _pickString(rootOrData, ['refreshToken', 'refresh_token']) ??
        _pickString(body, ['refreshToken', 'refresh_token']);
    final role = _parseRole(rootOrData['role']) ??
        _parseRole(user['role']) ??
        _parseRole(mechanicProfile['role']) ??
        _parseRole(fleetProfile['role']) ??
        _parseRole(companyProfile['role']) ??
        _parseRole(employeeProfile['role']) ??
        roleHint;
    final resolvedEmail = _pickString(rootOrData, ['email']) ??
        _pickString(user, ['email']) ??
        email;
    final name = _pickString(rootOrData, ['name', 'displayName']) ??
        _pickString(user, ['name', 'displayName']);

    final session = Session(
      email: resolvedEmail,
      role: role,
      displayName: name ?? resolvedEmail.split('@').first,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await saveSession(session);
    return session;
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    final uri = Uri.parse('$_baseUrl${ApiConstants.authLogoutPath}');
    try {
      await _client.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );
    } catch (_) {
      // Best-effort; still clear locally below.
    } finally {
      await clearSession();
    }
  }

  @override
  Future<void> registerFleetOperator({
    required String companyName,
    required String contactPerson,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiConstants.authRegisterPath}');
    final res = await _client.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'role': 'FLEET',
        'companyName': companyName,
        'contactPerson': contactPerson,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );

    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(res.body);
      body = (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
    } catch (_) {
      body = <String, dynamic>{};
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = _pickString(body, ['message', 'error', 'msg']) ??
          'Registration failed (HTTP ${res.statusCode}).';
      throw AuthException(msg);
    }
  }

  @override
  Future<void> registerServiceProvider({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required String phone,
    required String businessType,
    String? displayName,
    String? businessName,
    String? companyName,
    String? baseLocationText,
    String? basePostcode,
    num? hourlyRate,
    num? emergencyRate,
    num? emergencySurcharge,
    num? callOutFee,
    String? rateCurrency,
    num? coverageRadius,
    String? profilePhotoUrl,
    List<String>? skills,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiConstants.authRegisterPath}');

    // Sole traders register as MECHANIC; companies register as COMPANY.
    final role = businessType == 'COMPANY' ? 'COMPANY' : 'MECHANIC';

    final payload = <String, dynamic>{
      'role': role,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'fullName': fullName,
      'displayName': displayName,
      'phone': phone,
      'businessType': businessType,
      'businessName': businessName,
      'companyName': companyName,
      'baseLocationText': baseLocationText,
      'basePostcode': basePostcode,
      'hourlyRate': hourlyRate,
      'emergencyRate': emergencyRate,
      'emergencySurcharge': emergencySurcharge,
      'callOutFee': callOutFee,
      'rateCurrency': rateCurrency,
      'coverageRadius': coverageRadius,
      'profilePhotoUrl': profilePhotoUrl,
      'skills': skills,
    }..removeWhere((_, v) => v == null);

    final res = await _client.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(res.body);
      body = (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
    } catch (_) {
      body = <String, dynamic>{};
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = _pickString(body, ['message', 'error', 'msg']) ??
          'Registration failed (HTTP ${res.statusCode}).';
      throw AuthException(msg);
    }
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
