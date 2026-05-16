import 'package:flutter/foundation.dart';

import '../../../data/models/session.dart';
import '../../../data/repositories/app_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authRepository);

  final AuthRepository _authRepository;

  bool _bootstrapped = false;
  bool get bootstrapped => _bootstrapped;

  Session? _session;
  Session? get session => _session;
  bool get isAuthenticated => _session != null;

  /// Selected role before completing registration (terms flow).
  UserRole? registrationRole;

  Future<void> loadSession() async {
    _session = await _authRepository.getSession();
    _bootstrapped = true;
    notifyListeners();
  }

  Future<void> loginAs(String email, String password, UserRole role) async {
    final s = await _authRepository.login(email: email, password: password, roleHint: role);
    _session = s;
    notifyListeners();
  }

  /// Dev-friendly sign-in matching prototype “Sign In” without backend.
  Future<void> quickLogin(UserRole role) async {
    await loginAs('driver@fleetco.co.uk', '', role);
  }

  Future<void> logout() async {
    if (_session != null) {
      await _authRepository.logout(
        accessToken: _session!.accessToken,
        refreshToken: _session!.refreshToken,
      );
    } else {
      await _authRepository.clearSession();
    }
    _session = null;
    registrationRole = null;
    notifyListeners();
  }

  Future<void> completeRegistration(UserRole role, {String email = 'new@truckfix.app'}) async {
    await loginAs(email, '', role);
    registrationRole = null;
    notifyListeners();
  }

  void setRegistrationRole(UserRole role) {
    registrationRole = role;
    notifyListeners();
  }

  void clearRegistrationRole() {
    registrationRole = null;
    notifyListeners();
  }
}
