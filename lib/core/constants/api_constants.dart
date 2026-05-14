abstract final class ApiConstants {
  /// Backend root URL.
  ///
  /// From your Postman screenshots:
  /// - Auth:  POST http://192.168.10.251:6000/api/v1/auth/login
  /// - Users: PATCH http://192.168.10.251:7000/api/v1/users/me/availability
  ///
  /// Kept for backward-compat with existing services.
  static const String baseUrl = authBaseUrl;

  static const String authBaseUrl = 'http://192.168.10.251:5000';
  static const String usersBaseUrl = 'http://192.168.10.251:5000';

  static const String authLoginPath = '/api/v1/auth/login';
  static const String authLogoutPath = '/api/v1/auth/logout';
  static const String authRegisterPath = '/api/v1/auth/register';

  static const String usersMeAvailabilityPath = '/api/v1/users/me/availability';
  static const String usersMePath = '/api/v1/users/me';
  static const String supportTicketsPath = '/api/v1/support/tickets';
  static const String jobsPath = '/api/v1/jobs';

  /// Fleet submits mechanic review: `POST /api/v1/fleet/reviews`
  static const String fleetReviewsPath = '/api/v1/fleet/reviews';

  /// Fleet vehicle list (`GET`) for My Fleet overlay.
  static const String fleetVehiclesPath = '/api/v1/fleet/vehicles';

  /// Fleet billing: saved cards & bank methods.
  static const String billingPaymentMethodsPath = '/api/v1/billing/payment-methods';

  /// Google Maps / Places / Geocoding (restrict in Cloud Console for production).
  static const String googleMapsApiKey =
      'AIzaSyCXbW6lUF1nBJiJQILPlS4fkVGRi1SZlxw';
}
