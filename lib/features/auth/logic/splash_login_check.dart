import '../../../data/models/session.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../routes/app_routes.dart';

/// Maps an authenticated session to the role home route.
String homeRouteForSession(Session session) => switch (session.role) {
      UserRole.fleet => AppRoutes.fleetHome,
      UserRole.mechanic => AppRoutes.mechanicHome,
      UserRole.company => AppRoutes.companyHome,
      UserRole.employee => AppRoutes.employeeHome,
    };

/// After intro/splash, returns login or role home based on stored session.
Future<String> resolvePostSplashLocation(AuthRepository auth) async {
  final session = await auth.getSession();
  if (session == null) return AppRoutes.splash;
  return homeRouteForSession(session);
}
