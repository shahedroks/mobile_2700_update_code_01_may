abstract final class ApiConstants {
  /// Backend root URL.
  ///
  /// From your Postman screenshot:
  /// POST http://192.168.10.251:6000/api/v1/auth/login
  static const String baseUrl = 'http://192.168.10.251:6000';

  static const String authLoginPath = '/api/v1/auth/login';
  static const String authLogoutPath = '/api/v1/auth/logout';
}
